#!/usr/bin/env bash
# PASS when: confirms a check run applies nothing and a broken commit fails a check run.
set -uo pipefail

# run_pipeline NAME MODE: starts one pipeline run (MODE empty = no variable) and prints Complete or Failed.
run_pipeline() {
  local name="$1" mode="${2:-}" state=""
  kubectl -n dac delete job "$name" --ignore-not-found >/dev/null
  if [ -n "$mode" ]; then
    kubectl -n dac create job "$name" --from=cronjob/dashboards-pipeline --dry-run=client -o json \
      | kubectl patch --local -f - --type=json -o json \
        -p "[{\"op\":\"add\",\"path\":\"/spec/template/spec/containers/0/env/-\",\"value\":{\"name\":\"MODE\",\"value\":\"$mode\"}}]" \
      | kubectl apply -f - >/dev/null
  else
    kubectl -n dac create job "$name" --from=cronjob/dashboards-pipeline >/dev/null
  fi
  for _ in $(seq 1 180); do
    if [ "$(kubectl -n dac get job "$name" -o jsonpath="{.status.succeeded}")" = "1" ]; then state=Complete; break; fi
    if [ -n "$(kubectl -n dac get job "$name" -o jsonpath="{.status.failed}")" ]; then state=Failed; break; fi
    sleep 5
  done
  echo "${state:-Timeout}"
}

in_runner() { kubectl -n dac exec -i deploy/dac-runner -- sh -s; }
in_runner <<'GRADE'
set -u
. /opt/dac/grader-lib.sh
curl -sS -X DELETE "$PERSES_URL/api/v1/projects/$PROJECT/dashboards/mode-probe" >/dev/null || true
repo_change "Remove leftovers" "git rm -q --ignore-unmatch dashboards/cue/broken.cue"
repo_change "Add the mode probe dashboard" "sed 's/#name:\\( *\\)\"prometheus-overview\"/#name:\\1\"mode-probe\"/' dashboards/cue/prometheus-overview.cue > dashboards/cue/mode-probe.cue"
GRADE

state="$(run_pipeline grade-check check)"
[ "$state" = Complete ] || { echo "FAIL: a run with MODE=check on a good commit ended $state, not Complete."; exit 1; }
in_runner <<'GRADE'
set -u
. /opt/dac/grader-lib.sh
if server_json mode-probe >/dev/null 2>&1; then fail "a run with MODE=check applied the dashboard mode-probe to the server."; fi
repo_change "Add a broken dashboard" "printf 'package dashboards\n\nbroken: {\n' > dashboards/cue/broken.cue"
GRADE

state="$(run_pipeline grade-check-broken check)"
in_runner <<'GRADE'
set -u
. /opt/dac/grader-lib.sh
repo_change "Remove the broken dashboard" "git rm -q --ignore-unmatch dashboards/cue/broken.cue"
GRADE
[ "$state" = Failed ] || { echo "FAIL: a run with MODE=check on a broken commit ended $state, not Failed."; exit 1; }
echo "PASS: check mode applies nothing and still fails on a broken commit."
