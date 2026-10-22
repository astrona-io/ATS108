#!/usr/bin/env bash
# PASS when: fixes the commit and confirms the run succeeds and applies everything.
set -uo pipefail

in_runner() { kubectl -n dac exec -i deploy/dac-runner -- sh -s; }
in_runner <<'GRADE'
set -u
. /opt/dac/grader-lib.sh
repo_change "Remove the broken dashboard" "git rm -q --ignore-unmatch dashboards/cue/broken.cue"
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
state="$(run_pipeline grade-good)"
[ "$state" = Complete ] || { echo "FAIL: the run for a good commit ended $state, not Complete."; exit 1; }
in_runner() { kubectl -n dac exec -i deploy/dac-runner -- sh -s; }
in_runner <<'GRADE'
set -u
. /opt/dac/grader-lib.sh
title="$(server_json prometheus-overview | jq -r '.spec.display.name')"
[ "$title" = "Prometheus Overview (pipeline check)" ] || fail "the overview dashboard on the server is titled '$title' after a successful run."
build_json dashboards/go/storage/main.go > /tmp/want.json 2>/tmp/build.err || { cat /tmp/build.err; fail "dashboards/go/storage/main.go does not build."; }
server_json prometheus-storage > /tmp/got.json 2>/dev/null || fail "dashboard prometheus-storage is not on the server in project inventory."
want="$(norm < /tmp/want.json)"; got="$(norm < /tmp/got.json)"
[ -n "$want" ] && [ "$want" = "$got" ] || fail "dashboard prometheus-storage on the server differs from what dashboards/go/storage/main.go builds. Build it and apply it again."

build_json dashboards/go/per-job/main.go > /tmp/want.json 2>/tmp/build.err || { cat /tmp/build.err; fail "dashboards/go/per-job/main.go does not build."; }
server_json per-job > /tmp/got.json 2>/dev/null || fail "dashboard per-job is not on the server in project inventory."
want="$(norm < /tmp/want.json)"; got="$(norm < /tmp/got.json)"
[ -n "$want" ] && [ "$want" = "$got" ] || fail "dashboard per-job on the server differs from what dashboards/go/per-job/main.go builds. Build it and apply it again."
pass "the server holds exactly what the code builds for: prometheus-storage, per-job."
GRADE
