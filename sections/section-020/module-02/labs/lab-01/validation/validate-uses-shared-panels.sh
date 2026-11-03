#!/usr/bin/env bash
# PASS when: confirms jobs-overview.cue takes its panels from the shared package and loops with a comprehension.
set -uo pipefail

in_runner() { kubectl -n dac exec -i deploy/dac-runner -- sh -s; }
in_runner <<'GRADE'
set -u
. /opt/dac/grader-lib.sh
dac-run test -f dashboards/cue/jobs-overview.cue || fail "dashboards/cue/jobs-overview.cue is not on main."
dac-run grep -q '"example.com/dashboards/lib/panels"' dashboards/cue/jobs-overview.cue \
  || fail "jobs-overview.cue does not import example.com/dashboards/lib/panels."
if dac-run grep -qE 'PrometheusTimeSeriesQuery|prometheus-time-series-query|query:' dashboards/cue/jobs-overview.cue; then
  fail "jobs-overview.cue writes its own queries; take every panel from the shared package."
fi
dac-run grep -qE '(^|[^A-Za-z_])for[[:space:]]+[A-Za-z_]+[[:space:]]+in[[:space:]]' dashboards/cue/jobs-overview.cue \
  || fail "jobs-overview.cue does not generate its groups with a for comprehension."
pass "jobs-overview.cue builds its panels from the shared package with a comprehension."
GRADE
