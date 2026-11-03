# Solution: Add A Reusable Job Group To The Go Library

Work the task yourself first. Running `astrona submit -c sections/section-030/module-02/labs/lab-01` after a step tells you which checks pass.

The grader checks four things: the library tests pass and test `JobGroup`, the program loops and uses `boards.JobGroup`, the build has the required groups and panels, and the server equals the build of `main`.

## Step 1: Clone the repository

Start the Gitea port-forward in a second terminal (`kubectl -n gitea port-forward svc/gitea-http 3000:3000`), then clone and define the helper:

```sh
git clone http://gitops:gitops-password@gitea.localtest.me:3000/gitops/dashboards.git
cd dashboards
dac() { kubectl -n dac exec -i deploy/dac-runner -- dac-run "$@"; }
```

## Step 2: Add JobGroup to the library

In `lib/boards/boards.go`, add `"github.com/perses/perses/go-sdk/dashboard"` to the imports and add this function at the end:

```go
// JobGroup is a panel group named after a job, with the job's two main panels.
func JobGroup(job string) dashboard.Option {
	return dashboard.AddPanelGroup(job,
		panelgroup.PanelsPerLine(2),
		TargetsUp(job),
		SamplesAppended(job),
	)
}
```

## Step 3: Test it

Add this function at the end of `lib/boards/boards_test.go`:

```go
func TestJobGroupHasTwoPanels(t *testing.T) {
	builder, err := dashboard.New("test",
		dashboard.ProjectName("inventory"),
		JobGroup("perses"),
	)
	if err != nil {
		t.Fatal(err)
	}
	if got := len(builder.Dashboard.Spec.Panels); got != 2 {
		t.Fatalf("expected 2 panels, got %d", got)
	}
	if got := len(builder.Dashboard.Spec.Layouts); got != 1 {
		t.Fatalf("expected 1 layout, got %d", got)
	}
}
```

## Step 4: Write the dashboard

Save this as `dashboards/go/jobs/main.go`:

```go
// The jobs overview dashboard: one panel group per scrape job.
// Build it with: percli dac build -f dashboards/go/jobs/main.go -ojson
package main

import (
	"flag"
	"time"

	"github.com/perses/perses/go-sdk"
	"github.com/perses/perses/go-sdk/dashboard"

	"example.com/dashboards/lib/boards"
)

func main() {
	flag.Parse()
	exec := sdk.NewExec()
	options := []dashboard.Option{
		dashboard.ProjectName("inventory"),
		dashboard.Name("Jobs Overview (Go)"),
		dashboard.Duration(time.Hour),
	}
	for _, job := range []string{"prometheus", "perses"} {
		options = append(options, boards.JobGroup(job))
	}
	builder, buildErr := dashboard.New("jobs-overview-go", options...)
	exec.BuildDashboard(builder, buildErr)
}
```

## Step 5: Push, test, build and apply

```sh
git add -A && git commit -m "Add JobGroup and the jobs overview dashboard" && git push
dac go test ./lib/...
dac sh -c 'percli dac build -f dashboards/go/jobs/main.go -ojson && percli apply -f built/dashboards/go/jobs/main_output.json'
```

## Step 6: Check the result

```sh
dac sh -c 'percli dac build -f dashboards/go/jobs/main.go -ojson -m stdout | jq "[.spec.layouts[].spec.display.title], (.spec.panels | keys)"'
```

The group titles are `prometheus` and `perses`, and the panel keys are `0_0`, `0_1`, `1_0` and `1_1`. Submit:

```sh
astrona submit -c sections/section-030/module-02/labs/lab-01
```

## Why the obvious shortcuts are wrong

| Shortcut | What happens |
| --- | --- |
| Call `dashboard.AddPanelGroup` twice in `main.go` | The grader rejects a program that does not call `boards.JobGroup` in a loop |
| Skip the test | The grader runs the library tests and looks for a test of `JobGroup` |
| Put the test in `dashboards/go/jobs` | A `_test.go` file in package `main` breaks the folder build |
