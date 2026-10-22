#!/usr/bin/env bash
# PASS when: confirms the pipeline lints the built dashboards against the server.
set -uo pipefail

script="$(kubectl -n dac get configmap dashboards-pipeline -o jsonpath='{.data.pipeline\.sh}')"
printf '%s\n' "$script" | grep -qE 'percli lint .*--online' || { echo "FAIL: the pipeline does not run percli lint with --online."; exit 1; }
echo "PASS: the pipeline lints against the server."
