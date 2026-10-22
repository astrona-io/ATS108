#!/usr/bin/env bash
# PASS when: confirms the query changed in the browser is back to what the code says.
set -uo pipefail

in_runner() { kubectl -n dac exec -i deploy/dac-runner -- sh -s; }
in_runner <<'GRADE'
set -u
. /opt/dac/grader-lib.sh
query="$(server_json scrape-health | jq -r '.spec.panels["0_0"].spec.queries[0].spec.plugin.spec.query')"
[ "$query" = 'sum(up{job="prometheus"})' ] || fail "the first panel still runs '$query'; the code says sum(up{job=\"prometheus\"})."
pass "the first panel runs the query from the code again."
GRADE
