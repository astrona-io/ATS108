# Data-Driven Dashboards

A list of jobs should be the only thing you change when a job is added. In Go, a loop turns the list into options, and `dashboard.New` takes any number of options. This part builds a dashboard program that loops over jobs and uses the function from the library.

## Collect options in a slice

`dashboard.New` is a variadic function: it takes a name and then any number of options. A slice of options can be passed in the same place by writing three dots after it. Save this as `dashboards/go/jobs/main.go`:

<!-- astrona:playground:renew -->

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

The slice starts with the options that every dashboard needs. The loop appends one group option per job. The last line passes the slice with `options...`. The program prints nothing else, because standard output carries the dashboard.

## Build it

Push the file and build it to standard output:

```sh
git add dashboards/go/jobs/main.go && git commit -m "Add the jobs overview dashboard" && git push
dac() { kubectl -n dac exec -i deploy/dac-runner -- dac-run "$@"; }
dac sh -c 'percli dac build -f dashboards/go/jobs/main.go -ojson -m stdout | jq "[.spec.layouts[].spec.display.title], (.spec.panels | keys)"'
```

The group titles are `prometheus` and `perses`, and the panel keys are `0_0`, `0_1`, `1_0` and `1_1`: two panels in each of the two groups. Add a job to the list in the loop and build again to see a third group appear.

## Where the list should come from

A list written in `main.go` is fine for a small team. A larger setup can read the jobs from a file, an environment variable or a flag. A flag needs a declaration before `flag.Parse()` runs, and `percli dac build` passes everything after `--` to the program. Keep the choice small: each source of input is something a reviewer has to trust, and a build must give the same result every time for the same commit.

You now know how to build options in a loop and pass them to the builder. The open question is how to be sure that the function builds what you intend.

## Common pitfalls

> [!WARNING]
> - **Passing the slice without the three dots.** Go reports that a slice cannot be used as a single option.
> - **Printing the job list for debugging.** Standard output carries the dashboard. Print to standard error.
> - **Reading the list from a changing source.** A build must give the same result for the same commit.
