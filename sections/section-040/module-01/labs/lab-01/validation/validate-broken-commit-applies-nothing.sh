#!/usr/bin/env bash
# PASS when: pushes a broken commit and confirms the run fails and applies nothing.
set -uo pipefail

in_runner() { kubectl -n dac exec -i deploy/dac-runner -- sh -s; }
in_runner <<'GRADE'
set -u
. /opt/dac/grader-lib.sh
repo_change "Retitle the overview and add a broken dashboard" "
  sed -i 's/#display: name: \"Prometheus Overview\"/#display: name: \"Prometheus Overview (pipeline check)\"/' dashboards/cue/prometheus-overview.cue
  printf 'package dashboards\n\nbroken: {\n' > dashboards/cue/broken.cue
"
GRADE

# run_pipeline NAME: starts one pipeline run and prints Complete or Failed.
run_pipeline() {
  local name="$1" state=""
  kubectl -n dac delete job "$name" --ignore-not-found >/dev/null
  kubectl -n dac create job "$name" --from=cronjob/dashboards-pipeline >/dev/null
  for _ in $(seq 1 180); do
    if [ "$(kubectl -n dac get job "$name" -o jsonpath='{.status.succeeded}')" = "1" ]; then state=Complete; break; fi
    if [ -n "$(kubectl -n dac get job "$name" -o jsonpath='{.status.failed}')" ]; then state=Failed; break; fi
    sleep 5
  done
  echo "${state:-Timeout}"
}
state="$(run_pipeline grade-broken)"
[ "$state" = Failed ] || { echo "FAIL: the run for a commit with a broken dashboard ended $state, not Failed."; exit 1; }
in_runner() { kubectl -n dac exec -i deploy/dac-runner -- sh -s; }
in_runner <<'GRADE'
set -u
. /opt/dac/grader-lib.sh
title="$(server_json prometheus-overview 2>/dev/null | jq -r '.spec.display.name // empty')"
[ "$title" != "Prometheus Overview (pipeline check)" ] || fail "the failed run still applied the retitled overview dashboard."
pass "the broken commit failed the run and nothing from it was applied."
GRADE
