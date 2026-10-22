#!/usr/bin/env bash
# PASS when: confirms every dashboard of the repository is on the server as the code builds it.
set -uo pipefail

in_runner() { kubectl -n dac exec -i deploy/dac-runner -- sh -s; }
in_runner <<'GRADE'
set -u
. /opt/dac/grader-lib.sh
build_json dashboards/cue/prometheus-overview.cue > /tmp/want.json 2>/tmp/build.err || { cat /tmp/build.err; fail "dashboards/cue/prometheus-overview.cue does not build."; }
server_json prometheus-overview > /tmp/got.json 2>/dev/null || fail "dashboard prometheus-overview is not on the server in project inventory."
want="$(norm < /tmp/want.json)"; got="$(norm < /tmp/got.json)"
[ -n "$want" ] && [ "$want" = "$got" ] || fail "dashboard prometheus-overview on the server differs from what dashboards/cue/prometheus-overview.cue builds. Build it and apply it again."

build_json dashboards/go/storage/main.go > /tmp/want.json 2>/tmp/build.err || { cat /tmp/build.err; fail "dashboards/go/storage/main.go does not build."; }
server_json prometheus-storage > /tmp/got.json 2>/dev/null || fail "dashboard prometheus-storage is not on the server in project inventory."
want="$(norm < /tmp/want.json)"; got="$(norm < /tmp/got.json)"
[ -n "$want" ] && [ "$want" = "$got" ] || fail "dashboard prometheus-storage on the server differs from what dashboards/go/storage/main.go builds. Build it and apply it again."

build_json dashboards/go/per-job/main.go > /tmp/want.json 2>/tmp/build.err || { cat /tmp/build.err; fail "dashboards/go/per-job/main.go does not build."; }
server_json per-job > /tmp/got.json 2>/dev/null || fail "dashboard per-job is not on the server in project inventory."
want="$(norm < /tmp/want.json)"; got="$(norm < /tmp/got.json)"
[ -n "$want" ] && [ "$want" = "$got" ] || fail "dashboard per-job on the server differs from what dashboards/go/per-job/main.go builds. Build it and apply it again."
pass "the server holds exactly what the code builds for: prometheus-overview, prometheus-storage, per-job."
GRADE
