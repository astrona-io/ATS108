#!/usr/bin/env bash
# Runs before the reference solution: waits until the DaC runner has its
# tools and Perses and Gitea answer from inside the cluster.
set -u
for _ in $(seq 1 120); do
  if kubectl -n dac exec deploy/dac-runner -- sh -c '
      test -x /tools/percli && test -x /tools/cue && command -v git >/dev/null &&
      curl -fsS http://perses.localtest.me:8080/api/v1/health >/dev/null &&
      curl -fsS http://gitea.localtest.me:3000/api/healthz >/dev/null' >/dev/null 2>&1; then
    exit 0
  fi
  sleep 5
done
echo "Perses, Gitea or the DaC runner did not become ready in time." >&2
exit 1
