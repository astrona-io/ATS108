#!/usr/bin/env bash
# Creates the starting state for ats-108-lab-020-01: pushes the repository and
# prepares anything the task starts from. It never does the task itself.
set -euo pipefail

LOG="[lab]"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANIFEST_DIR=""
for candidate in "$SCRIPT_DIR/../manifests" "./manifests" "$SCRIPT_DIR/manifests"; do
  [ -d "$candidate" ] && { MANIFEST_DIR="$candidate"; break; }
done

runner() { kubectl -n dac exec -i deploy/dac-runner -- "$@"; }
dac_run() { runner dac-run "$@"; }

echo "$LOG Pushing the starting state of gitops/dashboards..."
COPYFILE_DISABLE=1 tar -C "$MANIFEST_DIR/repo" -cf - . | runner sh -c '
  set -eu
  rm -rf /tmp/seed && mkdir /tmp/seed && cd /tmp/seed && tar -xf -
  git init -q -b main && git add -A
  git -c user.name=gitops -c user.email=gitops@example.com commit -qm "Seed the dashboards repository"
  git push -q -f http://gitops:gitops-password@gitea.localtest.me:3000/gitops/dashboards.git main'

echo "$LOG Downloading the Go and CUE dependencies once (this can take a few minutes)..."
dac_run sh -c 'go mod download && cue mod tidy >/dev/null'

echo "$LOG Starting state ready."
