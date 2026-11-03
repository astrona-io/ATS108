#!/usr/bin/env bash
# PASS when: confirms the server holds exactly what jobs-overview.cue builds.
set -uo pipefail

in_runner() { kubectl -n dac exec -i deploy/dac-runner -- sh -s; }
in_runner <<'GRADE'
set -u
. /opt/dac/grader-lib.sh
build_json dashboards/cue/jobs-overview.cue > /tmp/want.json 2>/tmp/build.err || { cat /tmp/build.err; fail "dashboards/cue/jobs-overview.cue does not build."; }
server_json jobs-overview > /tmp/got.json 2>/dev/null || fail "dashboard jobs-overview is not on the server in project inventory."
want="$(norm < /tmp/want.json)"; got="$(norm < /tmp/got.json)"
[ -n "$want" ] && [ "$want" = "$got" ] || fail "dashboard jobs-overview on the server differs from what dashboards/cue/jobs-overview.cue builds. Build it and apply it again."
pass "the server holds exactly what the code builds for: jobs-overview."
GRADE
