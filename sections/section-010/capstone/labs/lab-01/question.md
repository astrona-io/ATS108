# Question

Solve this question on: `terminal`

**Time:** about 30 minutes · **Topic:** The Dashboard-as-Code workflow

## Scenario

The dashboard `scrape-health` is built from `dashboards/cue/scrape-health.cue` in the repository `gitops/dashboards`. During an incident, someone changed it directly in the Perses web interface, in the project `inventory`. They made two changes:

- They added a panel to the `Prometheus` group that shows the number of series in the head block of the job `prometheus`. The team wants to keep this panel.
- They changed the query of the first panel. The team does not want this change: the code's query is the right one.

## Your task

1. Find both changes with `percli dac diff`.
2. Move the panel worth keeping into the code: the `Prometheus` group must end with a third panel, built from the shared definition `panels.#HeadSeries` for the job `prometheus`. Commit and push the change to `main`.
3. Make the server hold exactly what the code at the head of `main` builds.

Run every `percli` command in the runner with this helper:

```sh
dac() { kubectl -n dac exec -i deploy/dac-runner -- dac-run "$@"; }
```

## Constraints

- Change the code only through Git commits on `main`.
- Use the shared definition `panels.#HeadSeries`; do not write the panel's query by hand.
- Do not keep the changed query of the first panel.

## Done when

- `dashboards/cue/scrape-health.cue` builds a `Head series` panel for job `prometheus` as the third panel of the `Prometheus` group.
- The first panel on the server runs `sum(up{job="prometheus"})` again.
- The server holds exactly what `dashboards/cue/scrape-health.cue` builds at the head of `main`.
