# Reusable Functions And Tests

The same "targets up" panel appears in many dashboards. In Go, the answer is a function that returns the panel, in a package every dashboard imports. A function can also be tested, so a wrong query is caught by `go test` before any dashboard is built. This part reads the repository's library, adds a test, and shows where tests must live.

## A library package

Look at the library:

<!-- astrona:playground:renew -->

```sh
dac() { kubectl -n dac exec -i deploy/dac-runner -- dac-run "$@"; }
dac cat lib/boards/boards.go
```

The package `boards` is not `main`, so `percli dac build` never runs it; it only compiles as part of the dashboards that import it. `TargetsUp(job string)` returns a `panelgroup.Option`: the result of `panelgroup.AddPanel("Targets up", ...)` with a Stat chart and a query built with `fmt.Sprintf` from the job. A dashboard uses it inside `dashboard.AddPanelGroup`, as in `boards.TargetsUp("$job")`. `HeadSeries` and `SamplesAppended` follow the same pattern, and `PromQuery` holds the one place where the datasource name `prometheus` is written.

Because these functions return options, Go code can build whole parts of a dashboard in a loop. A function that takes a list of job names can return one `dashboard.AddPanelGroup` option per job, and the dashboard program passes them all to `dashboard.New`.

## Test the library

The library has a test in `lib/boards/boards_test.go`. It builds a small dashboard with one `TargetsUp` panel and checks that the dashboard holds exactly one panel. The builder exposes the dashboard it built in the field `Dashboard`, so a test reads `builder.Dashboard.Spec.Panels` and `builder.Dashboard.Spec.Layouts` directly. Run the tests in the runner:

```sh
dac go test ./lib/...
```

`go test` reports `ok` for `example.com/dashboards/lib/boards`. Now add a test of your own that checks the query, not only the number of panels. In your clone, add this function at the end of `lib/boards/boards_test.go`, and add `"encoding/json"` and `"strings"` to its imports:

```go
func TestTargetsUpQueriesTheJob(t *testing.T) {
	builder, err := dashboard.New("test",
		dashboard.ProjectName("inventory"),
		dashboard.AddPanelGroup("Scrape health", panelgroup.PanelsPerLine(1), TargetsUp("perses")),
	)
	if err != nil {
		t.Fatal(err)
	}
	panelJSON, err := json.Marshal(builder.Dashboard.Spec.Panels["0_0"])
	if err != nil {
		t.Fatal(err)
	}
	if !strings.Contains(string(panelJSON), `sum(up{job=\"perses\"})`) {
		t.Fatalf("unexpected query in %s", panelJSON)
	}
}
```

The test turns the panel into JSON, the same JSON Perses will store, and looks for the expected query in it. The quotes in the query are escaped in JSON, which is why the test looks for `\"`. Push and run the tests again:

```sh
git commit -am "Test the Targets up query" && git push
dac go test ./lib/...
```

Both tests pass.

## Where tests must not live

`percli dac build -d dashboards` runs every Go file of package `main` under `dashboards`. A file called `main_test.go` next to a `main.go` is also in package `main`, so `percli` passes it to `go run`, and `go run` refuses to run test files. The whole folder build then reports a failure, even though the dashboard itself is fine. Keep dashboard programs short, keep logic in `lib/boards`, and test it there.

You now know how to share panels between Go dashboards with functions, how to test them, and where tests belong. That is everything the graded lab needs.

## Common pitfalls

> [!WARNING]
> - **Testing only that the build succeeds.** A wrong job name builds fine. Test the query or the titles the dashboard must have.
> - **A test file next to `main.go` under `dashboards`.** `percli dac build -d` tries to `go run` it and fails.
> - **Writing the datasource name in every function.** Keep it in one place, like `PromQuery`, so a rename is one change.

## Your mission: Port A CUE Dashboard To The Go SDK

You can now write a Go dashboard with the builders and the shared functions, and test the shared code. The graded lab gives you a CUE dashboard, `team-overview`, and asks you to write a Go program that builds the same variable, groups, panels and queries.

The lab runs in its own cluster, so first pause your playground. Nothing in it is lost:

```sh
astrona stop ats-108-playground-030-01
```

Then start the lab:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS108.git -c sections/section-030/module-01/labs/lab-01
```

The task is on the next page. Solve it on your own first. When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-030/module-01/labs/lab-01
```

When the lab is done, remove it and start your playground again:

```sh
astrona destroy ats-108-lab-030-01
astrona start ats-108-playground-030-01
```
