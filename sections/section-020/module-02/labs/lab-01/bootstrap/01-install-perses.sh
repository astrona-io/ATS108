#!/usr/bin/env bash
# Installs Helm, Perses v0.54.0, Prometheus, Gitea and the DaC runner, and
# creates the project inventory, its datasource and the Git repository.
#
# Graded lab bootstrap: this prepares the environment ONLY.
set -euo pipefail
# grep -q stops reading at the first match; under pipefail the command
# writing into the pipe then fails with SIGPIPE and a match looks like a
# failure. This wrapper reads all input instead and keeps grep's exit status.
grep() {
  local arg quiet=0 args=()
  for arg in "$@"; do
    case "$arg" in
      --quiet|--silent) quiet=1 ;;
      --*) args+=("$arg") ;;
      -*q*) quiet=1; [ "$arg" = "-q" ] || args+=("${arg//q/}") ;;
      *) args+=("$arg") ;;
    esac
  done
  if [ "$quiet" = 1 ]; then command grep "${args[@]}" >/dev/null; else command grep "$@"; fi
}

LOG="[lab]"

HELM_VERSION="3.22.1"
PERSES_CHART_VERSION="0.23.3"
GIT_USER="gitops"
GIT_PASSWORD="gitops-password"
REPO="dashboards"

BIN_DIR="/usr/local/bin"
[ -w "$BIN_DIR" ] || BIN_DIR="$HOME/.local/bin"
mkdir -p "$BIN_DIR"
export PATH="$BIN_DIR:$PATH"

# Pin Helm rather than accepting whatever is on the machine.
have_helm=""
command -v helm >/dev/null 2>&1 && have_helm=$(helm version --template '{{.Version}}' 2>/dev/null | sed 's/^v//')
if [ "$have_helm" != "$HELM_VERSION" ]; then
  OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
  ARCH="$(uname -m)"
  case "$ARCH" in x86_64) ARCH=amd64 ;; aarch64|arm64) ARCH=arm64 ;; esac
  WORK="$(mktemp -d)"
  trap 'rm -rf "$WORK"' EXIT
  echo "$LOG Downloading Helm ${HELM_VERSION} (${OS}/${ARCH})..."
  curl -fsSL "https://get.helm.sh/helm-v${HELM_VERSION}-${OS}-${ARCH}.tar.gz" | tar -xz -C "$WORK"
  install -m 0755 "$WORK/${OS}-${ARCH}/helm" "$BIN_DIR/helm"
fi
helm version --short

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANIFEST_DIR=""
for candidate in "$SCRIPT_DIR/../manifests" "./manifests" "$SCRIPT_DIR/manifests"; do
  [ -d "$candidate" ] && { MANIFEST_DIR="$candidate"; break; }
done

# One address for the reader's machine and the cluster for each service:
# NAME.localtest.me resolves to 127.0.0.1 on the machine (reached through a
# port-forward), and a CoreDNS rewrite sends the same name to the Service in
# the cluster. The answer is rewritten back to the asked name: Go programs
# ignore DNS answers whose name differs from the question.
add_coredns_rewrite() {
  # add_coredns_rewrite NAME FQDN: NAME.localtest.me -> FQDN, once.
  local name="$1" fqdn="$2" corefile
  corefile="$(kubectl -n kube-system get configmap coredns -o jsonpath='{.data.Corefile}')"
  printf '%s' "$corefile" | grep -qF "${name}\\.localtest\\.me" && return 0
  echo "$LOG Adding the CoreDNS rewrite for ${name}.localtest.me..."
  # Passed through the environment: awk -v would eat the backslashes.
  corefile="$(printf '%s\n' "$corefile" | REWRITE_NAME="$name" REWRITE_FQDN="$fqdn" \
    REWRITE_EFQDN="$(printf '%s' "$fqdn" | sed 's/\./\\./g')" awk '
    /^[[:space:]]*kubernetes / && !done {
      print "    rewrite stop {"
      print "        name regex " ENVIRON["REWRITE_NAME"] "\\.localtest\\.me " ENVIRON["REWRITE_FQDN"]
      print "        answer name " ENVIRON["REWRITE_EFQDN"] " " ENVIRON["REWRITE_NAME"] ".localtest.me"
      print "    }"
      done=1
    } {print}')"
  kubectl -n kube-system create configmap coredns --from-literal=Corefile="$corefile" \
    --dry-run=client -o yaml | kubectl apply -f -
  COREDNS_CHANGED=1
}
COREDNS_CHANGED=0
add_coredns_rewrite perses perses.perses.svc.cluster.local
add_coredns_rewrite gitea gitea-http.gitea.svc.cluster.local
if [ "$COREDNS_CHANGED" = 1 ]; then
  kubectl -n kube-system rollout restart deployment/coredns
  kubectl -n kube-system rollout status deployment/coredns --timeout=120s
fi

# lab-start.yaml is also listed under bootstrap.manifests in config.yaml, so it
# may already be applied. kubectl apply is idempotent.
echo "$LOG Starting Prometheus, Gitea and the DaC runner..."
kubectl apply -f "$MANIFEST_DIR/lab-start.yaml"

echo "$LOG Installing Perses (chart ${PERSES_CHART_VERSION})..."
helm repo add perses https://perses.github.io/helm-charts >/dev/null 2>&1 || true
helm repo update perses >/dev/null
helm upgrade --install perses perses/perses --version "$PERSES_CHART_VERSION" \
  --namespace perses --create-namespace \
  --values "$MANIFEST_DIR/perses-values.yaml" \
  --wait --timeout 10m

kubectl -n observability rollout status deployment/prometheus --timeout=300s
kubectl -n gitea rollout status deployment/gitea --timeout=300s
kubectl -n dac rollout status deployment/dac-runner --timeout=600s

runner() { kubectl -n dac exec -i deploy/dac-runner -- "$@"; }

for _ in $(seq 1 60); do
  runner sh -c 'command -v git >/dev/null && test -x /tools/percli && test -x /tools/cue' 2>/dev/null && break
  sleep 5
done

echo "$LOG Creating the Gitea user ${GIT_USER} and the repository ${GIT_USER}/${REPO}..."
# Gitea can refuse the first commands while it finishes starting, so retry
# until the user exists; fail here rather than later at the first clone.
gitea_user_ready=false
for _ in $(seq 1 30); do
  kubectl -n gitea exec deploy/gitea -- gitea admin user create \
    --username "$GIT_USER" --password "$GIT_PASSWORD" --email gitops@example.com \
    --admin --must-change-password=false >/dev/null 2>&1 && { gitea_user_ready=true; break; }
  kubectl -n gitea exec deploy/gitea -- gitea admin user list 2>/dev/null \
    | awk 'NR > 1 {print $2}' | grep -x "$GIT_USER" >/dev/null && { gitea_user_ready=true; break; }
  sleep 2
done
[ "$gitea_user_ready" = true ] || { echo "ERROR: could not create the Gitea user $GIT_USER." >&2; exit 1; }
runner sh -c "curl -fsS -u $GIT_USER:$GIT_PASSWORD http://gitea.localtest.me:3000/api/v1/repos/$GIT_USER/$REPO >/dev/null 2>&1 || \
  curl -fsS -u $GIT_USER:$GIT_PASSWORD -X POST -H 'Content-Type: application/json' \
    -d '{\"name\":\"$REPO\",\"auto_init\":false,\"default_branch\":\"main\",\"private\":true}' \
    http://gitea.localtest.me:3000/api/v1/user/repos >/dev/null"

echo "$LOG Creating the Perses project inventory and its datasource prometheus..."
runner sh -s <<'EOS'
set -eu
URL=http://perses.localtest.me:8080
for _ in $(seq 1 60); do curl -fsS "$URL/api/v1/health" >/dev/null 2>&1 && break; sleep 5; done
curl -sS -o /dev/null -X POST -H 'Content-Type: application/json' "$URL/api/v1/projects" \
  -d '{"kind":"Project","metadata":{"name":"inventory"},"spec":{"display":{"name":"inventory"}}}'
curl -sS -o /dev/null -X POST -H 'Content-Type: application/json' "$URL/api/v1/projects/inventory/datasources" \
  -d '{"kind":"Datasource","metadata":{"name":"prometheus","project":"inventory"},"spec":{"default":true,"plugin":{"kind":"PrometheusDatasource","spec":{"proxy":{"kind":"HTTPProxy","spec":{"url":"http://prometheus.observability:9090"}}}}}}'
curl -fsS "$URL/api/v1/projects/inventory/datasources/prometheus" >/dev/null
EOS

echo "$LOG Environment ready."
