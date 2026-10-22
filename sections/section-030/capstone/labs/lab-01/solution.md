# Solution: Generate A Dashboard Per Job

Work the task yourself first. Running `astrona submit -c sections/section-030/capstone/labs/lab-01` after a step tells you which checks pass.

The grader checks three things: the tests pass with the original test file, the build output is a clean dashboard with one group per job, and the server equals the build.

## Step 1: Run the tests

```sh
dac() { kubectl -n dac exec -i deploy/dac-runner -- dac-run "$@"; }
dac go test ./lib/...
```

`TestJobGroupsUsesEachJob` fails: it expects the second group to query the job `beta`, and the message shows a panel that queries `alpha`. Read the function:

```sh
dac cat lib/boards/jobs.go
```

The loop runs over every job and names each group `"Job " + job`, but it builds the panels with `TargetsUp(jobs[0])` and `SamplesAppended(jobs[0])`. Every group gets the panels of the first job. The titles are right, which is why the dashboard looks almost correct.

## Step 2: Read the build output

```sh
dac percli dac build -f dashboards/go/per-job/main.go -ojson -m stdout | head -2
```

The first line is not JSON. It is the text `building the per-job dashboard for ...`, printed by a `fmt.Println` in `main.go` before `exec.BuildDashboard`. `go run` succeeds, so the build reports success, but the output is that line followed by the dashboard, and no JSON reader accepts it.

## Step 3: Fix both faults

Start the Gitea port-forward in a second terminal (`kubectl -n gitea port-forward svc/gitea-http 3000:3000`) and clone the repository. Then:

1. In `lib/boards/jobs.go`, use the loop variable: `TargetsUp(job)` and `SamplesAppended(job)`.
2. In `dashboards/go/per-job/main.go`, remove the `fmt.Println(...)` line and the `"fmt"` import, which Go would otherwise refuse as unused.

Push:

```sh
git commit -am "Use each job, and keep the build output clean" && git push
```

## Step 4: Test, build and apply

```sh
dac go test ./lib/...
dac sh -c 'percli dac build -f dashboards/go/per-job/main.go -ojson && percli apply -f built/dashboards/go/per-job/main_output.json'
dac sh -c 'percli dac build -f dashboards/go/per-job/main.go -ojson -m stdout | jq "[.spec.layouts[].spec.display.title]"'
```

The tests pass, and the groups are `Job prometheus` and `Job perses`. Submit:

```sh
astrona submit -c sections/section-030/capstone/labs/lab-01
```

## Why the obvious shortcuts are wrong

| Shortcut | What happens |
| --- | --- |
| Change the test to expect `alpha` | The test no longer describes the intended behaviour; the grader checks the test file is unchanged |
| Write the two groups by hand in `main.go` | The next job needs another copy; the task keeps `JobGroups` as the source |
| Move the `Println` to after `exec.BuildDashboard` | The line still lands in standard output, after the dashboard; print to standard error if you must print |
