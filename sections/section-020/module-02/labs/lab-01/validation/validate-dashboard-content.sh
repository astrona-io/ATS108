#!/usr/bin/env bash
# PASS when: confirms the built dashboard has one group per job with the shared panels.
set -uo pipefail

in_runner() { kubectl -n dac exec -i deploy/dac-runner -- sh -s; }
in_runner <<'GRADE'
set -u
. /opt/dac/grader-lib.sh
built="$(build_json dashboards/cue/jobs-overview.cue | norm)" || fail "jobs-overview.cue does not build."
printf '%s' "$built" | jq -e '
  .name == "jobs-overview" and .project == "inventory" and .display == "Jobs Overview"
  and ([.groups[].title] == ["prometheus", "perses"])
  and ([.groups[].panels | length] == [2, 2])
  and ([.panels[] | [.name, .kind, .queries[0]]] == [
        ["Targets up", "StatChart", "sum(up{job=\"prometheus\"})"],
        ["Head series", "TimeSeriesChart", "prometheus_tsdb_head_series{job=\"prometheus\"}"],
        ["Targets up", "StatChart", "sum(up{job=\"perses\"})"],
        ["Head series", "TimeSeriesChart", "prometheus_tsdb_head_series{job=\"perses\"}"]])
' >/dev/null || fail "the built dashboard does not match the task. Built: $built"
pass "jobs-overview has one group per job with the two shared panels each."
GRADE
