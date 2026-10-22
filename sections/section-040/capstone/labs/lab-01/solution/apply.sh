#!/usr/bin/env bash
# Reference solution, applied only by `astrona test` (the `testing:` block).
# `astrona run` never runs this. Taken from solution.md - if one changes,
# change the other.
set -euo pipefail

in_runner() { kubectl -n dac exec -i deploy/dac-runner -- sh -s; }
in_runner <<'GRADE'
set -u
. /opt/dac/grader-lib.sh
repo_change "Keep the storage dashboard output clean" "mkdir -p dashboards/go/storage && printf '%s' 'Ly8gVGhlIHN0b3JhZ2UgZGFzaGJvYXJkOiBob3cgbXVjaCBkYXRhIHRoZSBQcm9tZXRoZXVzIHNlcnZlciBob2xkcy4KLy8gQnVpbGQgaXQgd2l0aDogcGVyY2xpIGRhYyBidWlsZCAtZiBkYXNoYm9hcmRzL2dvL3N0b3JhZ2UvbWFpbi5nbyAtb2pzb24KcGFja2FnZSBtYWluCgppbXBvcnQgKAoJImZsYWciCgkidGltZSIKCgkiZ2l0aHViLmNvbS9wZXJzZXMvcGVyc2VzL2dvLXNkayIKCSJnaXRodWIuY29tL3BlcnNlcy9wZXJzZXMvZ28tc2RrL2Rhc2hib2FyZCIKCXBhbmVsZ3JvdXAgImdpdGh1Yi5jb20vcGVyc2VzL3BlcnNlcy9nby1zZGsvcGFuZWwtZ3JvdXAiCgl0aW1lc2VyaWVzICJnaXRodWIuY29tL3BlcnNlcy9wbHVnaW5zL3RpbWVzZXJpZXNjaGFydC9zZGsvZ28iCgoJImV4YW1wbGUuY29tL2Rhc2hib2FyZHMvbGliL2JvYXJkcyIKKQoKZnVuYyBtYWluKCkgewoJZmxhZy5QYXJzZSgpCglleGVjIDo9IHNkay5OZXdFeGVjKCkKCWJ1aWxkZXIsIGJ1aWxkRXJyIDo9IGRhc2hib2FyZC5OZXcoInByb21ldGhldXMtc3RvcmFnZSIsCgkJZGFzaGJvYXJkLlByb2plY3ROYW1lKCJpbnZlbnRvcnkiKSwKCQlkYXNoYm9hcmQuTmFtZSgiUHJvbWV0aGV1cyBTdG9yYWdlIiksCgkJZGFzaGJvYXJkLkR1cmF0aW9uKHRpbWUuSG91ciksCgkJZGFzaGJvYXJkLkFkZFBhbmVsR3JvdXAoIlN0b3JhZ2UiLAoJCQlwYW5lbGdyb3VwLlBhbmVsc1BlckxpbmUoMiksCgkJCWJvYXJkcy5IZWFkU2VyaWVzKCJwcm9tZXRoZXVzIiksCgkJCXBhbmVsZ3JvdXAuQWRkUGFuZWwoIkNodW5rcyBpbiB0aGUgaGVhZCBibG9jayIsCgkJCQl0aW1lc2VyaWVzLkNoYXJ0KCksCgkJCQlib2FyZHMuUHJvbVF1ZXJ5KGBwcm9tZXRoZXVzX3RzZGJfaGVhZF9jaHVua3N7am9iPSJwcm9tZXRoZXVzIn1gKSwKCQkJKSwKCQkpLAoJKQoJZXhlYy5CdWlsZERhc2hib2FyZChidWlsZGVyLCBidWlsZEVycikKfQo=' | base64 -d > dashboards/go/storage/main.go"
GRADE

kubectl apply -f - <<'YAML'
apiVersion: v1
kind: ConfigMap
metadata:
  name: dashboards-pipeline
  namespace: dac
data:
  pipeline.sh: |
    #!/bin/sh
    # The dashboard pipeline: fetch the repository, build every dashboard, lint
    # the results against the server, show the differences, then apply.
    # `set -eu` stops the run at the first failing step, so a broken commit
    # applies nothing.
    set -eu
    REPO_URL="http://gitops:gitops-password@gitea.localtest.me:3000/gitops/dashboards.git"
    PERSES_URL="http://perses.localtest.me:8080"

    echo "== fetch"
    git clone -q --depth 1 "$REPO_URL" /work/repo
    cd /work/repo
    percli login "$PERSES_URL" >/dev/null

    echo "== dependencies"
    cue mod tidy
    go mod download

    echo "== build"
    percli dac build -d dashboards -ojson

    echo "== lint"
    percli lint -d built --online

    echo "== diff"
    percli dac diff -d built

    echo "== apply"
    percli apply -d built
YAML

# run_pipeline NAME: starts one pipeline run and prints Complete or Failed.
run_pipeline() {
  local name="$1" state=""
  kubectl -n dac delete job "$name" --ignore-not-found >/dev/null
  kubectl -n dac create job "$name" --from=cronjob/dashboards-pipeline >/dev/null
  for _ in $(seq 1 180); do
    if [ "$(kubectl -n dac get job "$name" -o jsonpath='{.status.succeeded}')" = "1" ]; then state=Complete; break; fi
    if [ -n "$(kubectl -n dac get job "$name" -o jsonpath='{.status.failed}')" ]; then state=Failed; break; fi
    sleep 5
  done
  echo "${state:-Timeout}"
}
run_pipeline pipeline-solution
