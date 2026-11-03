# Testing Dashboard Functions

A function that builds a panel group can fail in quiet ways: a wrong panel count, a missing layout or a query for the wrong job. A test finds these in less than a second, before any dashboard is built. This part writes a table-driven test for `JobGroup`. A table-driven test lists the cases in a slice and runs the same checks for each of them.

## What the builder exposes

After `dashboard.New` succeeds, the builder holds the finished dashboard in its field `Dashboard`. A test reads `builder.Dashboard.Spec.Panels`, a map from panel key to panel, and `builder.Dashboard.Spec.Layouts`, a list with one layout for each group. The number of panels and the number of layouts are two facts a group must get right.

## A table-driven test

Add this test at the end of `lib/boards/boards_test.go`:

<!-- astrona:playground:renew -->

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

This test checks one job. To run the same checks for several jobs, put the names in a slice and use `t.Run`, which gives each case its own name in the report:

```go
func TestJobGroupForEachJob(t *testing.T) {
	for _, job := range []string{"prometheus", "perses", "tester"} {
		t.Run(job, func(t *testing.T) {
			builder, err := dashboard.New("test",
				dashboard.ProjectName("inventory"),
				JobGroup(job),
			)
			if err != nil {
				t.Fatal(err)
			}
			if got := len(builder.Dashboard.Spec.Panels); got != 2 {
				t.Fatalf("expected 2 panels, got %d", got)
			}
		})
	}
}
```

A failing case is reported as `TestJobGroupForEachJob/tester`, so you see which input broke.

## Run the tests

Push the change and run the tests in the runner:

```sh
git commit -am "Test JobGroup" && git push
dac() { kubectl -n dac exec -i deploy/dac-runner -- dac-run "$@"; }
dac go test -v ./lib/...
```

The report lists each test and each subtest as passed. Change the expected count in one test to `3`, push and run again to read a real failure message, then change it back.

Tests belong in `lib/boards`, in package `boards`. A test file in package `main` next to a dashboard program breaks the folder build, because `go run` refuses test files.

You now know how to test a library function that builds a group. The open question is when to write a dashboard in Go at all, instead of in CUE.

## Common pitfalls

> [!WARNING]
> - **Testing only that the function does not fail.** Check a count or a query as well.
> - **Putting a test next to `main.go`.** It breaks `percli dac build -d`.
> - **Loop variable capture.** Pass the job into the subtest by using it inside `t.Run`, as shown; recent Go versions give each loop pass its own variable.

## Your mission: Add A Reusable Job Group To The Go Library

You can now write a function that returns a panel group, test it, and use it in a loop. The graded lab asks you to add `JobGroup` to the library with a test, and to write a Go dashboard that uses it for two jobs.

The lab runs in its own cluster, so first pause your playground. Nothing in it is lost:

```sh
astrona stop ats-108-playground-030-02
```

Then start the lab:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS108.git -c sections/section-030/module-02/labs/lab-01
```

The task is on the next page. Solve it on your own first. When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-030/module-02/labs/lab-01
```

When the lab is done, remove it and start your playground again:

```sh
astrona destroy ats-108-lab-030-02
astrona start ats-108-playground-030-02
```
