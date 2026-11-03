#!/usr/bin/env bash
# Reference solution, applied only by `astrona test` (the `testing:` block).
# `astrona run` never runs this. Taken from solution.md - if one changes,
# change the other.
set -euo pipefail

in_runner() { kubectl -n dac exec -i deploy/dac-runner -- sh -s; }
in_runner <<'GRADE'
set -u
. /opt/dac/grader-lib.sh
repo_change "Put release-health in the inventory project" "sed -i 's/#project: \"staging\"/#project: \"inventory\"/' dashboards/cue/release-health.cue"
dac-run sh -c 'percli dac build -f dashboards/cue/release-health.cue -ojson && percli apply -f built/dashboards/cue/release-health_output.json'
GRADE
