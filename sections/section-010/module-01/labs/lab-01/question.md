# Question

Solve this question on: `terminal`

**Time:** about 15 minutes · **Topic:** The Dashboard-as-Code workflow

## Scenario

The platform team added a new dashboard, `scrape-health`, to the repository `gitops/dashboards` as the CUE file `dashboards/cue/scrape-health.cue`. It shows, for each Prometheus scrape job, how many targets are up. The file is reviewed and merged on `main`, but the dashboard is not on the Perses server yet.

## Your task

1. Build `dashboards/cue/scrape-health.cue` into JSON with `percli dac build`, in the `dac-runner` pod.
2. Apply the built dashboard to the Perses server, in the project `inventory`.
3. Check that the dashboard on the server is exactly what the code builds.

Run every `percli` command in the runner with this helper:

```sh
dac() { kubectl -n dac exec -i deploy/dac-runner -- dac-run "$@"; }
```

## Constraints

- Do not write or edit dashboard JSON by hand. The dashboard on the server must be the build output of the code on `main`.
- Do not change `dashboards/cue/scrape-health.cue`.

## Done when

- The dashboard `scrape-health` exists in the project `inventory`.
- Its groups, panels, plugin kinds and queries are exactly what `dashboards/cue/scrape-health.cue` builds at the head of `main`.
