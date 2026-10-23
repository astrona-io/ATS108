#!/usr/bin/env bash
# PASS when: confirms the pipeline lints the built dashboards against the server.
set -uo pipefail
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

script="$(kubectl -n dac get configmap dashboards-pipeline -o jsonpath='{.data.pipeline\.sh}')"
printf '%s\n' "$script" | grep -qE 'percli lint .*--online' || { echo "FAIL: the pipeline does not run percli lint with --online."; exit 1; }
echo "PASS: the pipeline lints against the server."
