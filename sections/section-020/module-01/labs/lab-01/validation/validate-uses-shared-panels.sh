#!/usr/bin/env bash
# PASS when: confirms team-overview.cue takes every panel from the shared package.
set -uo pipefail

in_runner() { kubectl -n dac exec -i deploy/dac-runner -- sh -s; }
in_runner <<'GRADE'
set -u
. /opt/dac/grader-lib.sh
dac-run test -f dashboards/cue/team-overview.cue || fail "dashboards/cue/team-overview.cue is not on main."
dac-run grep -q '"example.com/dashboards/lib/panels"' dashboards/cue/team-overview.cue \
  || fail "team-overview.cue does not import example.com/dashboards/lib/panels."
if dac-run grep -qE 'PrometheusTimeSeriesQuery|prometheus-time-series-query|query:' dashboards/cue/team-overview.cue; then
  fail "team-overview.cue writes its own queries; take every panel from the shared package."
fi
pass "team-overview.cue builds its panels from the shared package."
GRADE
