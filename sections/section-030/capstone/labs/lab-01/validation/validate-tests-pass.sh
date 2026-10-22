#!/usr/bin/env bash
# PASS when: confirms the Go tests pass and the test file is unchanged.
set -uo pipefail

baseline="$(kubectl -n dac get configmap capstone-baseline -o jsonpath='{.data.jobs-test-sha256}')"
current="$(kubectl -n dac exec deploy/dac-runner -- dac-run sha256sum lib/boards/jobs_test.go | cut -d" " -f1)"
[ -n "$baseline" ] && [ "$baseline" = "$current" ] || { echo "FAIL: lib/boards/jobs_test.go was changed; fix the code, not the test."; exit 1; }
in_runner() { kubectl -n dac exec -i deploy/dac-runner -- sh -s; }
in_runner <<'GRADE'
set -u
. /opt/dac/grader-lib.sh
dac-run go test ./lib/... >/tmp/test.log 2>&1 || { cat /tmp/test.log; fail "go test ./lib/... fails."; }
pass "go test ./lib/... passes with the original test file."
GRADE
