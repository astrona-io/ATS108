#!/usr/bin/env bash
# Reference solution, applied only by `astrona test` (the `testing:` block).
# `astrona run` never runs this. Taken from solution.md - if one changes,
# change the other.
set -euo pipefail

in_runner() { kubectl -n dac exec -i deploy/dac-runner -- sh -s; }
in_runner <<'GRADE'
set -u
. /opt/dac/grader-lib.sh
repo_change "Add the jobs overview dashboard" "mkdir -p dashboards/cue && printf '%s' 'Ly8gT25lIHBhbmVsIGdyb3VwIHBlciBzY3JhcGUgam9iLCBnZW5lcmF0ZWQgZnJvbSBhIGxpc3QuCnBhY2thZ2UgZGFzaGJvYXJkcwoKaW1wb3J0ICgKCWRhc2hib2FyZEJ1aWxkZXIgImdpdGh1Yi5jb20vcGVyc2VzL3BlcnNlcy9jdWUvZGFjLXV0aWxzL2Rhc2hib2FyZCIKCXBhbmVsR3JvdXBzQnVpbGRlciAiZ2l0aHViLmNvbS9wZXJzZXMvcGVyc2VzL2N1ZS9kYWMtdXRpbHMvcGFuZWxncm91cHMiCgoJImV4YW1wbGUuY29tL2Rhc2hib2FyZHMvbGliL3BhbmVscyIKKQoKX2pvYnM6IFsicHJvbWV0aGV1cyIsICJwZXJzZXMiXQoKZGFzaGJvYXJkQnVpbGRlciAmIHsKCSNuYW1lOiAgICAiam9icy1vdmVydmlldyIKCSNwcm9qZWN0OiAiaW52ZW50b3J5IgoJI2Rpc3BsYXk6IG5hbWU6ICJKb2JzIE92ZXJ2aWV3IgoJI2R1cmF0aW9uOiAiMWgiCgoJI3BhbmVsR3JvdXBzOiBwYW5lbEdyb3Vwc0J1aWxkZXIgJiB7CgkJI2lucHV0OiBbCgkJCWZvciBqb2IgaW4gX2pvYnMgewoJCQkJI3RpdGxlOiBqb2IKCQkJCSNjb2xzOiAgMgoJCQkJI3BhbmVsczogWwoJCQkJCXtwYW5lbHMuI1RhcmdldHNVcCAmIHsjam9iOiBqb2J9fS5wYW5lbCwKCQkJCQl7cGFuZWxzLiNIZWFkU2VyaWVzICYgeyNqb2I6IGpvYn19LnBhbmVsLAoJCQkJXQoJCQl9LAoJCV0KCX0KfQo=' | base64 -d > dashboards/cue/jobs-overview.cue"
dac-run sh -c 'percli dac build -f dashboards/cue/jobs-overview.cue -ojson && percli apply -f built/dashboards/cue/jobs-overview_output.json'
GRADE
