#!/usr/bin/env bash
# PASS when: confirms the program loops over the jobs and uses boards.JobGroup.
set -uo pipefail

in_runner() { kubectl -n dac exec -i deploy/dac-runner -- sh -s; }
in_runner <<'GRADE'
set -u
. /opt/dac/grader-lib.sh
dac-run grep -q '"example.com/dashboards/lib/boards"' dashboards/go/jobs/main.go \
  || fail "main.go does not import example.com/dashboards/lib/boards."
dac-run grep -q 'boards.JobGroup(' dashboards/go/jobs/main.go \
  || fail "main.go does not call boards.JobGroup."
dac-run grep -qE '(^|[^A-Za-z_])for[[:space:]].*range' dashboards/go/jobs/main.go \
  || fail "main.go does not loop over the jobs with for ... range."
if dac-run grep -qE 'query\.PromQL\(|AddPanelGroup\(' dashboards/go/jobs/main.go; then
  fail "main.go writes its own queries or groups; use boards.JobGroup."
fi
pass "the Go program loops over the jobs and uses boards.JobGroup."
GRADE
