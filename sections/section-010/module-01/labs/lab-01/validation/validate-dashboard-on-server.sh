#!/usr/bin/env bash
# PASS when: confirms the dashboard scrape-health exists in project inventory.
set -uo pipefail

in_runner() { kubectl -n dac exec -i deploy/dac-runner -- sh -s; }
in_runner <<'GRADE'
set -u
. /opt/dac/grader-lib.sh
server_json scrape-health >/dev/null 2>&1 || fail "there is no dashboard scrape-health in project inventory."
pass "dashboard scrape-health is in project inventory."
GRADE
