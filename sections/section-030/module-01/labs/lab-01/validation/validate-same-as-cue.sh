#!/usr/bin/env bash
# PASS when: confirms the Go and CUE dashboards have the same variable, groups, panels and queries.
set -uo pipefail

in_runner() { kubectl -n dac exec -i deploy/dac-runner -- sh -s; }
in_runner <<'GRADE'
set -u
. /opt/dac/grader-lib.sh
build_json dashboards/cue/team-overview.cue > /tmp/cue.json || fail "team-overview.cue does not build."
build_json dashboards/go/team-overview-go/main.go > /tmp/go.json || fail "team-overview-go does not build."
cue_side="$(norm < /tmp/cue.json | jq -S 'del(.name, .display)')"
go_side="$(norm < /tmp/go.json | jq -S 'del(.name, .display)')"
[ -n "$cue_side" ] || fail "team-overview.cue builds no dashboard."
[ "$cue_side" = "$go_side" ] || fail "the Go dashboard differs from the CUE one. CUE: $cue_side Go: $go_side"
pass "the Go dashboard has the same variable, groups, panels and queries as the CUE one."
GRADE
