# Question

Solve this question on: `terminal`

**Time:** about 25 minutes · **Topic:** CUE for dashboards

## Scenario

The team that runs the `inventory` services watches two scrape jobs, `prometheus` and `perses`, and expects more jobs later. A teammate wrote the groups by hand in other dashboards, and every new job meant copying a block. The repository `gitops/dashboards` has the shared panel package `lib/panels` with `#TargetsUp`, `#SamplesAppended` and `#HeadSeries`.

## Your task

Write the CUE dashboard `dashboards/cue/jobs-overview.cue`, push it to `main`, build it and apply it to the project `inventory`. The dashboard must be:

| Field | Value |
| --- | --- |
| Name | `jobs-overview` |
| Project | `inventory` |
| Title (display name) | `Jobs Overview` |
| Groups | One group per job in the list `prometheus`, `perses`, in that order. The group title is the job name. |
| Panels in each group | `#TargetsUp` and then `#HeadSeries`, both for that job, in two columns |

Run every `percli` command in the runner with this helper:

```sh
dac() { kubectl -n dac exec -i deploy/dac-runner -- dac-run "$@"; }
```

## Constraints

- Keep the jobs in one list in the file and generate the groups from it with a `for` comprehension. Do not write the groups out by hand.
- Take every panel from the package `example.com/dashboards/lib/panels`. Do not write a query or a plugin in `jobs-overview.cue`.
- Use the Perses builders for the dashboard and the panel groups.
- Do not change `lib/panels/panels.cue`.

## Done when

- `dashboards/cue/jobs-overview.cue` on `main` imports `example.com/dashboards/lib/panels`, uses a `for` comprehension and writes no query of its own.
- It builds the two groups and the four panels in the order above.
- The server holds exactly what the file builds at the head of `main`.
