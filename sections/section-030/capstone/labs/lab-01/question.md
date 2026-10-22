# Question

Solve this question on: `terminal`

**Time:** about 35 minutes · **Topic:** The Go SDK

## Scenario

A new Go dashboard, `per-job`, should show one panel group per Prometheus scrape job, `Job prometheus` and `Job perses`, each with the targets that are up and the samples appended for that job. The groups come from the shared function `JobGroups` in `lib/boards/jobs.go`, which has a test in `lib/boards/jobs_test.go`.

Since the last commit, `go test ./lib/...` fails, and the output of `percli dac build -f dashboards/go/per-job/main.go` cannot be read as a dashboard. The dashboard is not on the server.

## Your task

1. Find why the tests fail and why the build output is not a dashboard.
2. Fix the code. Push the fixes to `main`.
3. Build `per-job` and apply it to the project `inventory`.

Run every `percli` and `go` command in the runner with this helper:

```sh
dac() { kubectl -n dac exec -i deploy/dac-runner -- dac-run "$@"; }
```

## Constraints

- Do not change `lib/boards/jobs_test.go`. The test describes the intended behaviour.
- Keep `JobGroups` as the source of the panel groups; do not write the groups by hand in `main.go`.

## Done when

- `go test ./lib/...` passes, with `lib/boards/jobs_test.go` unchanged.
- `dashboards/go/per-job/main.go` builds to a JSON dashboard with the groups `Job prometheus` and `Job perses`, each querying its own job.
- The server holds exactly what `dashboards/go/per-job/main.go` builds.
