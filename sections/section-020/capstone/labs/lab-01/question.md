# Question

Solve this question on: `terminal`

**Time:** about 35 minutes · **Topic:** CUE for dashboards

## Scenario

A colleague changed the shared panel library `lib/panels` in the repository `gitops/dashboards` and pushed it late on Friday. Since then, no CUE dashboard builds, and none of `prometheus-overview`, `team-overview` and `scrape-health` is on the Perses server. Two of the dashboards also had faults of their own before the library broke them.

## Your task

1. Build every dashboard in the runner and read the errors.
2. Fix the library and the dashboards so that every file in `dashboards` builds. The intended content is:
   - every `Targets up` panel shows the **latest** value of the series;
   - `team-overview` has the groups `Selected job` and `Perses`, in that order;
   - the `Perses` group of `scrape-health` shows the targets that are up for the job `perses`.
3. Push the fixes to `main`, build everything and apply every dashboard to the project `inventory`.

Run every `percli` command in the runner with this helper:

```sh
dac() { kubectl -n dac exec -i deploy/dac-runner -- dac-run "$@"; }
```

## Constraints

- Keep the plugin schemas in force: the Stat panel must still be unified with the StatChart schema.
- Do not remove a panel group, a panel or a dashboard to make the build pass.

## Done when

- `percli dac build -d dashboards` succeeds at the head of `main`.
- Every Stat panel in every dashboard uses the calculation `last`, through the StatChart schema.
- `team-overview` has the groups `Selected job` and `Perses`, and `scrape-health`'s `Perses` group runs `sum(up{job="perses"})`.
- The server holds exactly what each of the three files builds.
