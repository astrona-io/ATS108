#!/usr/bin/env bash
# PASS when: confirms the library tests pass and include a test of JobGroup.
set -uo pipefail

in_runner() { kubectl -n dac exec -i deploy/dac-runner -- sh -s; }
in_runner <<'GRADE'
set -u
. /opt/dac/grader-lib.sh
dac-run grep -q 'func JobGroup(' lib/boards/boards.go || fail "lib/boards/boards.go does not define JobGroup."
dac-run grep -q 'JobGroup(' lib/boards/boards_test.go || fail "lib/boards/boards_test.go does not test JobGroup."
out="$(dac-run go test -v ./lib/boards 2>&1)" || { printf '%s\n' "$out"; fail "go test ./lib/... fails."; }
passed="$(printf '%s\n' "$out" | grep -c '^--- PASS' || true)"
[ "${passed:-0}" -ge 2 ] || fail "expected at least 2 passing tests in lib/boards (the existing one and yours), got ${passed:-0}."
pass "the library tests pass and JobGroup has a test."
GRADE
