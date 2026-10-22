# Dashboards, Panel Groups, Panels And Queries In Go

The Go SDK builds a dashboard from nested function calls. Each builder takes a name and a list of options, and each option changes one thing: a title, a time range, a panel, a query. This part writes a new dashboard with the builders and the plugin packages, then builds and applies it.

## Builders and options

Every builder in the SDK follows the same pattern. `dashboard.New(name, options...)` returns a builder and an error. The options are functions from the `dashboard` package, such as `dashboard.ProjectName`, `dashboard.Name` (the display name), `dashboard.Duration`, `dashboard.AddVariable` and `dashboard.AddPanelGroup`. A panel group takes its own options from the `panelgroup` package, such as `panelgroup.PanelsPerLine` and `panelgroup.AddPanel`, and a panel takes options from the `panel` package, such as `panel.AddQuery`.

The plugins provide the rest. Each plugin module has an `sdk/go` package with options of its own:

| Package | Option | What it adds |
| --- | --- | --- |
| `github.com/perses/plugins/timeserieschart/sdk/go` | `timeseries.Chart()` | A time series chart as the panel's plugin |
| `github.com/perses/plugins/statchart/sdk/go` | `stat.Chart(stat.Calculation(common.LastCalculation))` | A Stat chart showing one value of the series |
| `github.com/perses/plugins/prometheus/sdk/go/query` | `query.PromQL(expr, query.Datasource(name))` | A Prometheus query on a named datasource |
| `github.com/perses/plugins/prometheus/sdk/go/variable/label-values` | `labelvalues.PrometheusLabelValues(label, ...)` | A variable listing the values of a label |

The repository's library package `lib/boards` wraps some of these. `boards.PromQuery(expr)` adds a Prometheus query on the project datasource `prometheus`, and `boards.TargetsUp(job)` adds a complete Stat panel.

## Write a dashboard

Start the Gitea port-forward in a second terminal (`kubectl -n gitea port-forward svc/gitea-http 3000:3000`), and clone the repository if you have not yet:

<!-- astrona:playground:renew -->

```sh
git clone http://gitops:gitops-password@gitea.localtest.me:3000/gitops/dashboards.git
cd dashboards
dac() { kubectl -n dac exec -i deploy/dac-runner -- dac-run "$@"; }
```

Save this as `dashboards/go/perses-requests/main.go`, in a folder of its own:

```go
// The Perses requests dashboard: how busy the Perses API is.
package main

import (
	"flag"
	"time"

	"github.com/perses/perses/go-sdk"
	"github.com/perses/perses/go-sdk/dashboard"
	panelgroup "github.com/perses/perses/go-sdk/panel-group"
	listvariable "github.com/perses/perses/go-sdk/variable/list-variable"
	labelvalues "github.com/perses/plugins/prometheus/sdk/go/variable/label-values"
	timeseries "github.com/perses/plugins/timeserieschart/sdk/go"

	"example.com/dashboards/lib/boards"
)

func main() {
	flag.Parse()
	exec := sdk.NewExec()
	builder, buildErr := dashboard.New("perses-requests",
		dashboard.ProjectName("inventory"),
		dashboard.Name("Perses Requests"),
		dashboard.Duration(30*time.Minute),
		dashboard.AddVariable("job",
			listvariable.List(
				labelvalues.PrometheusLabelValues("job",
					labelvalues.Matchers("up"),
					labelvalues.Datasource(boards.Datasource),
				),
				listvariable.DisplayName("Job"),
			),
		),
		dashboard.AddPanelGroup("Requests",
			panelgroup.PanelsPerLine(2),
			boards.TargetsUp("$job"),
			panelgroup.AddPanel("Go routines",
				timeseries.Chart(),
				boards.PromQuery(`go_goroutines{job="$job"}`),
			),
		),
	)
	exec.BuildDashboard(builder, buildErr)
}
```

Read it from the inside out. `listvariable.List` wraps the label values plugin into a list variable called `job`, shown as `Job`. The panel group `Requests` places two panels per line: a Stat panel from the library for the selected job, and a time series panel with a query written in place. Both queries use `$job`, the variable's value. `dashboard.Duration(30*time.Minute)` sets the default time range.

## Build and apply it

Push the file, then build and apply it in the runner:

```sh
git add dashboards/go/perses-requests && git commit -m "Add the Perses requests dashboard" && git push
dac sh -c 'percli dac build -f dashboards/go/perses-requests/main.go -ojson && percli apply -f built/dashboards/go/perses-requests/main_output.json'
```

The built file is `built/dashboards/go/perses-requests/main_output.json`: `percli` names it after the source path, so every Go dashboard's file ends in `main_output.json`, in a folder named after the dashboard's folder. Check what the server now holds:

```sh
dac sh -c 'curl -s http://perses.localtest.me:8080/api/v1/projects/inventory/dashboards/perses-requests | jq "{duration: .spec.duration, panels: [.spec.panels[] | .spec.plugin.kind]}"'
```

The dashboard has the duration `30m` and two panels, a `StatChart` and a `TimeSeriesChart`.

## When a builder fails

A builder can refuse its options. If an option is invalid, `dashboard.New` returns an error instead of a dashboard, and `exec.BuildDashboard` prints it to standard error and exits with a non-zero code. `percli dac build` then reports the file as failed, with the program's error output. A Go compile error, such as a typo in a function name, is reported the same way, before the program even runs.

You now know how to build a dashboard from the SDK builders and the plugin packages. The panel in the library came from a function; the open question is how to write such functions and prove they work.

## Common pitfalls

> [!WARNING]
> - **Confusing `dashboard.Name` and the name argument.** The first argument of `dashboard.New` is the dashboard's identifier, `metadata.name`; `dashboard.Name` sets the title shown in the browser.
> - **A query without a datasource.** Without `query.Datasource`, the query uses the project's default datasource. Name it, so the dashboard does not change when the default does.
> - **Expecting `perses-requests_output.json`.** The output file is named after the source file, `main.go`, so it is `main_output.json` in the dashboard's folder.
