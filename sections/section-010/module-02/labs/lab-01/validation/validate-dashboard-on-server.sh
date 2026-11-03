#!/usr/bin/env bash
# PASS when: confirms the code builds release-health for the project inventory.
set -uo pipefail

in_runner() { kubectl -n dac exec -i deploy/dac-runner -- sh -s; }
in_runner <<'GRADE'
set -u
. /opt/dac/grader-lib.sh
project="$(build_json dashboards/cue/release-health.cue 2>/dev/null | jq -r '.metadata.project // empty')"
[ "$project" = "inventory" ] || fail "release-health.cue builds for the project '${project:-none}', not inventory."
pass "release-health.cue builds for the project inventory."
GRADE
