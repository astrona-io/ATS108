#!/usr/bin/env bash
# Creates the starting state for ats-108-capstone-010: pushes the repository and
# prepares anything the task starts from. It never does the task itself.
set -euo pipefail

LOG="[lab]"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANIFEST_DIR=""
for candidate in "$SCRIPT_DIR/../manifests" "./manifests" "$SCRIPT_DIR/manifests"; do
  [ -d "$candidate" ] && { MANIFEST_DIR="$candidate"; break; }
done

runner() { kubectl -n dac exec -i deploy/dac-runner -- "$@"; }
dac_run() { runner dac-run "$@"; }

echo "$LOG Pushing the starting state of gitops/dashboards..."
COPYFILE_DISABLE=1 tar -C "$MANIFEST_DIR/repo" -cf - . | runner sh -c '
  set -eu
  rm -rf /tmp/seed && mkdir /tmp/seed && cd /tmp/seed && tar -xf -
  git init -q -b main && git add -A
  git -c user.name=gitops -c user.email=gitops@example.com commit -qm "Seed the dashboards repository"
  git push -q -f http://gitops:gitops-password@gitea.localtest.me:3000/gitops/dashboards.git main'

echo "$LOG Downloading the Go and CUE dependencies once (this can take a few minutes)..."
dac_run sh -c 'go mod download && cue mod tidy >/dev/null'
in_runner() { kubectl -n dac exec -i deploy/dac-runner -- sh -s; }
in_runner <<'GRADE'
set -u
. /opt/dac/grader-lib.sh
echo 'Applying scrape-health, then editing it in place the way the web interface would...'
dac-run sh -c 'percli dac build -f dashboards/cue/scrape-health.cue -ojson && percli apply -f built/dashboards/cue/scrape-health_output.json'

server_json scrape-health > /tmp/current.json
jq '
  .spec.panels["0_0"].spec.queries[0].spec.plugin.spec.query = "count(up{job=\"prometheus\"})"
  | .spec.panels["0_2"] = {kind: "Panel", spec: {display: {name: "Head series"},
      plugin: {kind: "TimeSeriesChart", spec: {}},
      queries: [{kind: "TimeSeriesQuery", spec: {plugin: {kind: "PrometheusTimeSeriesQuery",
        spec: {datasource: {kind: "PrometheusDatasource", name: "prometheus"},
               query: "prometheus_tsdb_head_series{job=\"prometheus\"}"}}}}]}}
  | .spec.layouts[0].spec.items += [{x: 0, y: 8, width: 12, height: 8, content: {"$ref": "#/spec/panels/0_2"}}]
' /tmp/current.json > /tmp/edited.json
curl -fsS -X PUT -H 'Content-Type: application/json' --data-binary @/tmp/edited.json \
  "$PERSES_URL/api/v1/projects/inventory/dashboards/scrape-health" >/dev/null
GRADE

echo "$LOG Starting state ready."
