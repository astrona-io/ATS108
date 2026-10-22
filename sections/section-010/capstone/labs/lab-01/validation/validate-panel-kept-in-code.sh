#!/usr/bin/env bash
# PASS when: confirms scrape-health.cue builds the Head series panel in the Prometheus group.
set -uo pipefail

in_runner() { kubectl -n dac exec -i deploy/dac-runner -- sh -s; }
in_runner <<'GRADE'
set -u
. /opt/dac/grader-lib.sh
built="$(build_json dashboards/cue/scrape-health.cue)" || fail "dashboards/cue/scrape-health.cue does not build."
printf '%s' "$built" | jq -e '
  (.spec.layouts[0].spec.display.title == "Prometheus")
  and ([.spec.layouts[0].spec.items[].content["$ref"]] | length == 3)
  and ([.spec.panels[] | select(.spec.display.name == "Head series")
        | .spec.queries[0].spec.plugin.spec.query] == ["prometheus_tsdb_head_series{job=\"prometheus\"}"])
' >/dev/null || fail "the code does not build a Head series panel for job prometheus as the third panel of the Prometheus group."
pass "the Head series panel is part of the code."
GRADE
