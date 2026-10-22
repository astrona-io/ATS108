#!/usr/bin/env bash
# PASS when: confirms the Go dashboards build to clean JSON.
set -uo pipefail

in_runner() { kubectl -n dac exec -i deploy/dac-runner -- sh -s; }
in_runner <<'GRADE'
set -u
. /opt/dac/grader-lib.sh
for file in dashboards/go/storage/main.go dashboards/go/per-job/main.go; do
  build_json "$file" | jq -e '.kind == "Dashboard"' >/dev/null 2>&1 \
    || fail "$file does not build to a JSON dashboard; something else is printed on standard output."
done
pass "both Go dashboards build to clean JSON."
GRADE
