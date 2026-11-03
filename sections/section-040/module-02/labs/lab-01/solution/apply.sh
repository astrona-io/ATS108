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
    # MODE=check stops before the apply step. Any other value deploys.
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

    if [ "${MODE:-deploy}" = "check" ]; then
      echo "== check mode: nothing applied"
      exit 0
    fi

    echo "== apply"
    percli apply -d built
YAML
