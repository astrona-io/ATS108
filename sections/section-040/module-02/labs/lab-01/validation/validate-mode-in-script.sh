#!/usr/bin/env bash
# PASS when: confirms the script reads MODE, still lints online, and the CronJob is unchanged.
set -uo pipefail

script="$(kubectl -n dac get configmap dashboards-pipeline -o jsonpath='{.data.pipeline\.sh}')"
printf '%s\n' "$script" | grep -q 'MODE' || { echo "FAIL: the pipeline script does not read MODE."; exit 1; }
printf '%s\n' "$script" | grep -q 'check' || { echo "FAIL: the pipeline script has no check mode."; exit 1; }
printf '%s\n' "$script" | grep -qE 'percli lint .*--online' || { echo "FAIL: the pipeline no longer runs percli lint with --online."; exit 1; }
printf '%s\n' "$script" | grep -q 'percli apply' || { echo "FAIL: the pipeline no longer has an apply step."; exit 1; }
cron_env="$(kubectl -n dac get cronjob dashboards-pipeline -o jsonpath='{.spec.jobTemplate.spec.template.spec.containers[0].env[*].name}')"
case " $cron_env " in *" MODE "*) echo "FAIL: the CronJob sets MODE. Leave the CronJob as it is."; exit 1 ;; esac
[ "$(kubectl -n dac get cronjob dashboards-pipeline -o jsonpath='{.spec.suspend}')" = "true" ] || { echo "FAIL: the CronJob must stay suspended."; exit 1; }
echo "PASS: the script reads MODE, lints online, still applies, and the CronJob is unchanged."
