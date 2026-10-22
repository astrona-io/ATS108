#!/usr/bin/env bash
# PASS when: confirms the built dashboard has the required variable, groups and panels.
set -uo pipefail

in_runner() { kubectl -n dac exec -i deploy/dac-runner -- sh -s; }
in_runner <<'GRADE'
set -u
. /opt/dac/grader-lib.sh
built="$(build_json dashboards/cue/team-overview.cue | norm)" || fail "team-overview.cue does not build."
printf '%s' "$built" | jq -e '
  .name == "team-overview" and .project == "inventory" and .display == "Team Overview"
  and (.variables | length == 1) and .variables[0].name == "job"
  and .variables[0].kind == "PrometheusLabelValuesVariable" and .variables[0].label == "job"
  and ([.groups[].title] == ["Selected job", "Perses"])
  and ([.groups[].panels | length] == [2, 1])
  and ([.panels[] | [.name, .kind, .queries[0]]] == [
        ["Targets up", "StatChart", "sum(up{job=\"$job\"})"],
        ["Head series", "TimeSeriesChart", "prometheus_tsdb_head_series{job=\"$job\"}"],
        ["Targets up", "StatChart", "sum(up{job=\"perses\"})"]])
' >/dev/null || fail "the built dashboard does not match the task. Built: $built"
pass "team-overview has the variable, the two groups and the three panels."
GRADE
