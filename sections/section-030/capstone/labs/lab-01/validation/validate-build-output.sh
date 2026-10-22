#!/usr/bin/env bash
# PASS when: confirms per-job builds to clean JSON with one group per job.
set -uo pipefail

in_runner() { kubectl -n dac exec -i deploy/dac-runner -- sh -s; }
in_runner <<'GRADE'
set -u
. /opt/dac/grader-lib.sh
built="$(build_json dashboards/go/per-job/main.go)" || fail "dashboards/go/per-job/main.go does not build."
printf '%s' "$built" | jq -e '.kind == "Dashboard"' >/dev/null 2>&1 \
  || fail "the build output of per-job is not a JSON dashboard; something else is printed on standard output."
printf '%s' "$built" | jq -e '
  [.spec.layouts[].spec.display.title] == ["Job prometheus", "Job perses"]
  and (.spec.panels["0_0"].spec.queries[0].spec.plugin.spec.query == "sum(up{job=\"prometheus\"})")
  and (.spec.panels["1_0"].spec.queries[0].spec.plugin.spec.query == "sum(up{job=\"perses\"})")
' >/dev/null || fail "per-job must have the groups Job prometheus and Job perses, each querying its own job."
pass "per-job builds one group per job."
GRADE
