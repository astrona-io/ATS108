#!/usr/bin/env bash
# PASS when: confirms the group titles and the Perses job are what the task asks.
set -uo pipefail

in_runner() { kubectl -n dac exec -i deploy/dac-runner -- sh -s; }
in_runner <<'GRADE'
set -u
. /opt/dac/grader-lib.sh
titles="$(build_json dashboards/cue/team-overview.cue | jq -c '[.spec.layouts[].spec.display.title]')"
[ "$titles" = '["Selected job","Perses"]' ] || fail "team-overview groups are $titles, not [\"Selected job\",\"Perses\"]."
query="$(build_json dashboards/cue/scrape-health.cue | jq -r '.spec.panels["1_0"].spec.queries[0].spec.plugin.spec.query')"
[ "$query" = 'sum(up{job="perses"})' ] || fail "the Perses group of scrape-health runs '$query', not sum(up{job=\"perses\"})."
pass "the groups are complete and the Perses group watches job perses."
GRADE
