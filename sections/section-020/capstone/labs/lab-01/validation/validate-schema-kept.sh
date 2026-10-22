#!/usr/bin/env bash
# PASS when: confirms Targets up panels use the latest value and the library keeps the plugin schema.
set -uo pipefail

in_runner() { kubectl -n dac exec -i deploy/dac-runner -- sh -s; }
in_runner <<'GRADE'
set -u
. /opt/dac/grader-lib.sh
dac-run grep -q 'statChart & {spec: calculation: "last"}' lib/panels/panels.cue \
  || fail "the Targets up panel in lib/panels/panels.cue must unify the StatChart schema with calculation \"last\"."
for file in dashboards/cue/prometheus-overview.cue dashboards/cue/team-overview.cue dashboards/cue/scrape-health.cue; do
  calcs="$(build_json "$file" | jq -c '[.spec.panels[] | select(.spec.plugin.kind == "StatChart") | .spec.plugin.spec.calculation] | unique')"
  [ "$calcs" = '["last"]' ] || fail "$file builds Stat panels with calculation $calcs, not [\"last\"]."
done
pass "every Targets up panel shows the latest value, through the StatChart schema."
GRADE
