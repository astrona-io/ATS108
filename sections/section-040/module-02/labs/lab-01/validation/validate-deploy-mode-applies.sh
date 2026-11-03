#!/usr/bin/env bash
# PASS when: confirms a run without MODE still deploys everything the code builds.
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
repo_change "Remove leftovers" "git rm -q --ignore-unmatch dashboards/cue/broken.cue"
repo_change "Add the mode probe dashboard" "sed 's/#name:\\( *\\)\"prometheus-overview\"/#name:\\1\"mode-probe\"/' dashboards/cue/prometheus-overview.cue > dashboards/cue/mode-probe.cue"
GRADE

state="$(run_pipeline grade-deploy)"
[ "$state" = Complete ] || { echo "FAIL: a run without MODE on a good commit ended $state, not Complete."; exit 1; }
in_runner <<'GRADE'
set -u
. /opt/dac/grader-lib.sh
for entry in "mode-probe dashboards/cue/mode-probe.cue" "prometheus-overview dashboards/cue/prometheus-overview.cue" "prometheus-storage dashboards/go/storage/main.go" "per-job dashboards/go/per-job/main.go"; do
  name="${entry%% *}"; file="${entry#* }"
  build_json "$file" > /tmp/want.json 2>/tmp/build.err || { cat /tmp/build.err; fail "$file does not build."; }
  server_json "$name" > /tmp/got.json 2>/dev/null || fail "dashboard $name is not on the server in project inventory."
  want="$(norm < /tmp/want.json)"; got="$(norm < /tmp/got.json)"
  [ -n "$want" ] && [ "$want" = "$got" ] || fail "dashboard $name on the server differs from what $file builds."
done
pass "a run without MODE applied every dashboard of the repository."
GRADE
