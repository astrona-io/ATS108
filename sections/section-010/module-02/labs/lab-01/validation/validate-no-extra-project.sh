#!/usr/bin/env bash
# PASS when: confirms the project staging was not created.
set -uo pipefail

in_runner() { kubectl -n dac exec -i deploy/dac-runner -- sh -s; }
in_runner <<'GRADE'
set -u
. /opt/dac/grader-lib.sh
code="$(curl -s -o /dev/null -w '%{http_code}' "$PERSES_URL/api/v1/projects/staging")"
[ "$code" = "404" ] || fail "the project staging exists on the server (HTTP $code). Fix the code instead of creating the project."
pass "no project staging was created."
GRADE
