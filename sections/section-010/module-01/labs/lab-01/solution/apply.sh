#!/usr/bin/env bash
# Reference solution, applied only by `astrona test` (the `testing:` block).
# `astrona run` never runs this. Taken from solution.md - if one changes,
# change the other.
set -euo pipefail

in_runner() { kubectl -n dac exec -i deploy/dac-runner -- sh -s; }
in_runner <<'GRADE'
set -u
. /opt/dac/grader-lib.sh
dac-run sh -c 'percli dac build -f dashboards/cue/scrape-health.cue -ojson && percli apply -f built/dashboards/cue/scrape-health_output.json'
GRADE
