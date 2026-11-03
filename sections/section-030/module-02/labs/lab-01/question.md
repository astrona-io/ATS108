# Question

Solve this question on: `terminal`

**Time:** about 30 minutes · **Topic:** Go SDK

## Scenario

The team that runs the `inventory` services watches two scrape jobs, `prometheus` and `perses`, and expects more later. Every Go dashboard so far repeats the same panel group call for each job. The repository `gitops/dashboards` has the library package `lib/boards` with `TargetsUp`, `SamplesAppended`, `HeadSeries` and `PromQuery`, and one test.

## Your task

1. Add the function `JobGroup(job string) dashboard.Option` to `lib/boards/boards.go`. It returns a panel group titled with the job name, two panels per line, holding `TargetsUp(job)` and then `SamplesAppended(job)`.
2. Add a test of `JobGroup` to `lib/boards/boards_test.go`. It must check the number of panels and the number of layouts of a dashboard built with one group.
3. Write the Go dashboard `dashboards/go/jobs/main.go`, push everything to `main`, build the dashboard and apply it to the project `inventory`. The dashboard must be:

| Field | Value |
| --- | --- |
| Name | `jobs-overview-go` |
| Project | `inventory` |
| Title (display name) | `Jobs Overview (Go)` |
| Duration | one hour |
| Groups | One group per job in the list `prometheus`, `perses`, in that order, each from `boards.JobGroup` |

Run every `percli` and `go` command in the runner with this helper:

```sh
dac() { kubectl -n dac exec -i deploy/dac-runner -- dac-run "$@"; }
```

## Constraints

- Loop over the list of jobs in `main.go` and append one option per job. Do not write the groups out by hand.
- Do not write a query or call `AddPanelGroup` in `main.go`.
- Do not delete the existing test.
- Keep the program in its own folder, and keep tests in `lib/boards`.

## Done when

- `go test ./lib/...` passes and `boards_test.go` tests `JobGroup`.
- `dashboards/go/jobs/main.go` on `main` imports `example.com/dashboards/lib/boards`, loops over the jobs and calls `boards.JobGroup`.
- It builds the two groups and the four panels in the order above.
- The server holds exactly what the program builds at the head of `main`.
