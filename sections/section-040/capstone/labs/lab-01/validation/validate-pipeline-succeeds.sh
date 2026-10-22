#!/usr/bin/env bash
# PASS when: starts a pipeline run and confirms it completes.
set -uo pipefail

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
state="$(run_pipeline grade-run)"
[ "$state" = Complete ] || { echo "FAIL: the pipeline run ended $state, not Complete. Read its log with kubectl -n dac logs job/grade-run."; exit 1; }
echo "PASS: the pipeline run completed."
