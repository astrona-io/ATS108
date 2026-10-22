#!/usr/bin/env bash
# PASS when: confirms team-overview-go builds with the right name and title.
set -uo pipefail

in_runner() { kubectl -n dac exec -i deploy/dac-runner -- sh -s; }
in_runner <<'GRADE'
set -u
. /opt/dac/grader-lib.sh
built="$(build_json dashboards/go/team-overview-go/main.go)" || fail "dashboards/go/team-overview-go/main.go does not build."
printf '%s' "$built" | jq -e '.kind == "Dashboard" and .metadata.name == "team-overview-go"
  and .metadata.project == "inventory" and .spec.display.name == "Team Overview (Go)"' >/dev/null \
  || fail "the Go program must build dashboard team-overview-go in project inventory with the title \"Team Overview (Go)\"."
pass "team-overview-go builds."
GRADE
