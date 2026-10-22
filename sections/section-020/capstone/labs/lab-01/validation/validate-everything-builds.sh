#!/usr/bin/env bash
# PASS when: confirms every dashboard in the repository builds.
set -uo pipefail

in_runner() { kubectl -n dac exec -i deploy/dac-runner -- sh -s; }
in_runner <<'GRADE'
set -u
. /opt/dac/grader-lib.sh
dac-run sh -c 'rm -rf built && percli dac build -d dashboards -ojson' >/tmp/build.log 2>&1 \
  || { cat /tmp/build.log; fail "percli dac build -d dashboards fails."; }
pass "every dashboard in the repository builds."
GRADE
