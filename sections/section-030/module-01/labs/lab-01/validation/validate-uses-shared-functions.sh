#!/usr/bin/env bash
# PASS when: confirms the Go program uses the shared functions in lib/boards.
set -uo pipefail

in_runner() { kubectl -n dac exec -i deploy/dac-runner -- sh -s; }
in_runner <<'GRADE'
set -u
. /opt/dac/grader-lib.sh
dac-run grep -q '"example.com/dashboards/lib/boards"' dashboards/go/team-overview-go/main.go \
  || fail "main.go does not import example.com/dashboards/lib/boards."
if dac-run grep -q 'query.PromQL(' dashboards/go/team-overview-go/main.go; then
  fail "main.go writes its own queries; use boards.TargetsUp and boards.HeadSeries."
fi
pass "the Go program builds its panels with the shared functions."
GRADE
