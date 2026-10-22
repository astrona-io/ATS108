#!/usr/bin/env bash
# Reference solution, applied only by `astrona test` (the `testing:` block).
# `astrona run` never runs this. Taken from solution.md - if one changes,
# change the other.
set -euo pipefail

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
