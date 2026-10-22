# Question

Solve this question on: `terminal`

**Time:** about 25 minutes · **Topic:** CUE for dashboards

## Scenario

The team that runs the `inventory` services wants one overview dashboard: the job they select at the top, plus a fixed watch on Perses itself. The repository `gitops/dashboards` already has the shared panel package `lib/panels` with `#TargetsUp`, `#SamplesAppended` and `#HeadSeries`.

## Your task

Write the CUE dashboard `dashboards/cue/team-overview.cue`, push it to `main`, build it and apply it to the project `inventory`. The dashboard must be:

| Field | Value |
| --- | --- |
| Name | `team-overview` |
| Project | `inventory` |
| Title (display name) | `Team Overview` |
| Variable | `job`: the values of the label `job` on the metric `up`, from the datasource `prometheus` |
| Group 1 | `Selected job`, two columns: `#TargetsUp` and `#HeadSeries` for the selected job (`$job`) |
| Group 2 | `Perses`, one column: `#TargetsUp` for the job `perses` |

Run every `percli` command in the runner with this helper:

```sh
dac() { kubectl -n dac exec -i deploy/dac-runner -- dac-run "$@"; }
```

## Constraints

- Take every panel from the package `example.com/dashboards/lib/panels`. Do not write a query or a plugin in `team-overview.cue`.
- Use the Perses builders for the dashboard, the panel groups and the variable.
- Do not change `lib/panels/panels.cue`.

## Done when

- `dashboards/cue/team-overview.cue` on `main` imports `example.com/dashboards/lib/panels` and writes no query of its own.
- It builds a dashboard with the variable, the two groups and the three panels in the order above.
- The server holds exactly what the file builds at the head of `main`.
