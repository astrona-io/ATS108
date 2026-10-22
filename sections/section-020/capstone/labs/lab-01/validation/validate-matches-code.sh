#!/usr/bin/env bash
# PASS when: confirms the server holds what each dashboard builds.
set -uo pipefail

in_runner() { kubectl -n dac exec -i deploy/dac-runner -- sh -s; }
in_runner <<'GRADE'
set -u
. /opt/dac/grader-lib.sh
build_json dashboards/cue/prometheus-overview.cue > /tmp/want.json 2>/tmp/build.err || { cat /tmp/build.err; fail "dashboards/cue/prometheus-overview.cue does not build."; }
server_json prometheus-overview > /tmp/got.json 2>/dev/null || fail "dashboard prometheus-overview is not on the server in project inventory."
want="$(norm < /tmp/want.json)"; got="$(norm < /tmp/got.json)"
[ -n "$want" ] && [ "$want" = "$got" ] || fail "dashboard prometheus-overview on the server differs from what dashboards/cue/prometheus-overview.cue builds. Build it and apply it again."

build_json dashboards/cue/team-overview.cue > /tmp/want.json 2>/tmp/build.err || { cat /tmp/build.err; fail "dashboards/cue/team-overview.cue does not build."; }
server_json team-overview > /tmp/got.json 2>/dev/null || fail "dashboard team-overview is not on the server in project inventory."
want="$(norm < /tmp/want.json)"; got="$(norm < /tmp/got.json)"
[ -n "$want" ] && [ "$want" = "$got" ] || fail "dashboard team-overview on the server differs from what dashboards/cue/team-overview.cue builds. Build it and apply it again."

build_json dashboards/cue/scrape-health.cue > /tmp/want.json 2>/tmp/build.err || { cat /tmp/build.err; fail "dashboards/cue/scrape-health.cue does not build."; }
server_json scrape-health > /tmp/got.json 2>/dev/null || fail "dashboard scrape-health is not on the server in project inventory."
want="$(norm < /tmp/want.json)"; got="$(norm < /tmp/got.json)"
[ -n "$want" ] && [ "$want" = "$got" ] || fail "dashboard scrape-health on the server differs from what dashboards/cue/scrape-health.cue builds. Build it and apply it again."
pass "the server holds exactly what the code builds for: prometheus-overview, team-overview, scrape-health."
GRADE
