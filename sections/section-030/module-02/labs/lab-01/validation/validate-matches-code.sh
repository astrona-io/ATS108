#!/usr/bin/env bash
# PASS when: confirms the server holds exactly what jobs/main.go builds.
set -uo pipefail

in_runner() { kubectl -n dac exec -i deploy/dac-runner -- sh -s; }
in_runner <<'GRADE'
set -u
. /opt/dac/grader-lib.sh
build_json dashboards/go/jobs/main.go > /tmp/want.json 2>/tmp/build.err || { cat /tmp/build.err; fail "dashboards/go/jobs/main.go does not build."; }
server_json jobs-overview-go > /tmp/got.json 2>/dev/null || fail "dashboard jobs-overview-go is not on the server in project inventory."
want="$(norm < /tmp/want.json)"; got="$(norm < /tmp/got.json)"
[ -n "$want" ] && [ "$want" = "$got" ] || fail "dashboard jobs-overview-go on the server differs from what dashboards/go/jobs/main.go builds. Build it and apply it again."
pass "the server holds exactly what the code builds for: jobs-overview-go."
GRADE
