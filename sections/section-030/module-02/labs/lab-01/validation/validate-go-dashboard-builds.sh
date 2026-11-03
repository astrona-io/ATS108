#!/usr/bin/env bash
# PASS when: confirms jobs-overview-go builds one group per job with the shared panels.
set -uo pipefail

in_runner() { kubectl -n dac exec -i deploy/dac-runner -- sh -s; }
in_runner <<'GRADE'
set -u
. /opt/dac/grader-lib.sh
built="$(build_json dashboards/go/jobs/main.go | norm)" || fail "dashboards/go/jobs/main.go does not build."
printf '%s' "$built" | jq -e '
  .name == "jobs-overview-go" and .project == "inventory" and .display == "Jobs Overview (Go)"
  and ([.groups[].title] == ["prometheus", "perses"])
  and ([.groups[].panels | length] == [2, 2])
  and ([.panels[] | [.name, .kind, .queries[0]]] == [
        ["Targets up", "StatChart", "sum(up{job=\"prometheus\"})"],
        ["Samples appended per second", "TimeSeriesChart", "rate(prometheus_tsdb_head_samples_appended_total{job=\"prometheus\"}[5m])"],
        ["Targets up", "StatChart", "sum(up{job=\"perses\"})"],
        ["Samples appended per second", "TimeSeriesChart", "rate(prometheus_tsdb_head_samples_appended_total{job=\"perses\"}[5m])"]])
' >/dev/null || fail "the built dashboard does not match the task. Built: $built"
pass "jobs-overview-go has one group per job with the two shared panels each."
GRADE
