#!/usr/bin/env bash
# Reference solution, applied only by `astrona test` (the `testing:` block).
# `astrona run` never runs this. Taken from solution.md - if one changes,
# change the other.
set -euo pipefail

in_runner() { kubectl -n dac exec -i deploy/dac-runner -- sh -s; }
in_runner <<'GRADE'
set -u
. /opt/dac/grader-lib.sh
repo_change "Keep the Head series panel added in the browser" "mkdir -p dashboards/cue && printf '%s' 'Ly8gVGhlIHNjcmFwZSBoZWFsdGggZGFzaGJvYXJkOiBvbmUgcGFuZWwgZ3JvdXAgcGVyIHNjcmFwZSBqb2IuCnBhY2thZ2UgZGFzaGJvYXJkcwoKaW1wb3J0ICgKCWRhc2hib2FyZEJ1aWxkZXIgImdpdGh1Yi5jb20vcGVyc2VzL3BlcnNlcy9jdWUvZGFjLXV0aWxzL2Rhc2hib2FyZCIKCXBhbmVsR3JvdXBzQnVpbGRlciAiZ2l0aHViLmNvbS9wZXJzZXMvcGVyc2VzL2N1ZS9kYWMtdXRpbHMvcGFuZWxncm91cHMiCgoJImV4YW1wbGUuY29tL2Rhc2hib2FyZHMvbGliL3BhbmVscyIKKQoKZGFzaGJvYXJkQnVpbGRlciAmIHsKCSNuYW1lOiAgICAic2NyYXBlLWhlYWx0aCIKCSNwcm9qZWN0OiAiaW52ZW50b3J5IgoJI2Rpc3BsYXk6IG5hbWU6ICJTY3JhcGUgSGVhbHRoIgoJI2R1cmF0aW9uOiAiMWgiCgoJI3BhbmVsR3JvdXBzOiBwYW5lbEdyb3Vwc0J1aWxkZXIgJiB7CgkJI2lucHV0OiBbCgkJCXsKCQkJCSN0aXRsZTogIlByb21ldGhldXMiCgkJCQkjY29sczogIDIKCQkJCSNwYW5lbHM6IFsKCQkJCQl7cGFuZWxzLiNUYXJnZXRzVXAgJiB7I2pvYjogInByb21ldGhldXMifX0ucGFuZWwsCgkJCQkJe3BhbmVscy4jU2FtcGxlc0FwcGVuZGVkICYgeyNqb2I6ICJwcm9tZXRoZXVzIn19LnBhbmVsLAoJCQkJCXtwYW5lbHMuI0hlYWRTZXJpZXMgJiB7I2pvYjogInByb21ldGhldXMifX0ucGFuZWwsCgkJCQldCgkJCX0sCgkJCXsKCQkJCSN0aXRsZTogIlBlcnNlcyIKCQkJCSNjb2xzOiAgMQoJCQkJI3BhbmVsczogWwoJCQkJCXtwYW5lbHMuI1RhcmdldHNVcCAmIHsjam9iOiAicGVyc2VzIn19LnBhbmVsLAoJCQkJXQoJCQl9LAoJCV0KCX0KfQo=' | base64 -d > dashboards/cue/scrape-health.cue"
dac-run sh -c 'percli dac build -f dashboards/cue/scrape-health.cue -ojson && percli apply -f built/dashboards/cue/scrape-health_output.json'
GRADE
