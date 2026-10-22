# Solution: Port A CUE Dashboard To The Go SDK

Work the task yourself first. Running `astrona submit -c sections/section-030/module-01/labs/lab-01` after a step tells you which checks pass.

The grader checks four things: the Go program builds the right name and title, its dashboard has the same variable, groups, panels and queries as the CUE one, it uses the shared functions, and the server holds both dashboards as built.

## Step 1: Read what the CUE file builds

```sh
dac() { kubectl -n dac exec -i deploy/dac-runner -- dac-run "$@"; }
dac sh -c 'percli dac build -f dashboards/cue/team-overview.cue -ojson -m stdout | jq "{variables: [.spec.variables[] | {name: .spec.name, label: .spec.plugin.spec.labelName}], groups: [.spec.layouts[].spec.display.title], panels: [.spec.panels | to_entries[] | [.key, .value.spec.display.name, .value.spec.queries[0].spec.plugin.spec.query]]}"'
```

The CUE dashboard has the variable `job` (label `job`), the groups `Selected job` (two panels) and `Perses` (one panel), and three panels: `Targets up` and `Head series` for `$job`, and `Targets up` for `perses`.

## Step 2: Write the Go program

Start the Gitea port-forward in a second terminal (`kubectl -n gitea port-forward svc/gitea-http 3000:3000`), clone the repository, and save this as `dashboards/go/team-overview-go/main.go`:

```go
// The team overview dashboard, written with the Go SDK.
// It builds the same groups, panels, queries and variable as
// dashboards/cue/team-overview.cue.
package main

import (
	"flag"
	"time"

	"github.com/perses/perses/go-sdk"
	"github.com/perses/perses/go-sdk/dashboard"
	panelgroup "github.com/perses/perses/go-sdk/panel-group"
	listvariable "github.com/perses/perses/go-sdk/variable/list-variable"
	labelvalues "github.com/perses/plugins/prometheus/sdk/go/variable/label-values"

	"example.com/dashboards/lib/boards"
)

func main() {
	flag.Parse()
	exec := sdk.NewExec()
	builder, buildErr := dashboard.New("team-overview-go",
		dashboard.ProjectName("inventory"),
		dashboard.Name("Team Overview (Go)"),
		dashboard.Duration(time.Hour),
		dashboard.AddVariable("job",
			listvariable.List(
				labelvalues.PrometheusLabelValues("job",
					labelvalues.Matchers("up"),
					labelvalues.Datasource(boards.Datasource),
				),
				listvariable.DisplayName("Job"),
			),
		),
		dashboard.AddPanelGroup("Selected job",
			panelgroup.PanelsPerLine(2),
			boards.TargetsUp("$job"),
			boards.HeadSeries("$job"),
		),
		dashboard.AddPanelGroup("Perses",
			panelgroup.PanelsPerLine(1),
			boards.TargetsUp("perses"),
		),
	)
	exec.BuildDashboard(builder, buildErr)
}
```

`boards.TargetsUp("$job")` and `boards.HeadSeries("$job")` put the variable into the queries, the same way the CUE definitions do with their default. `labelvalues.Matchers("up")` gives the variable the matcher `up{}`, like the CUE builder.

## Step 3: Push, build and apply

```sh
git add dashboards/go/team-overview-go && git commit -m "Port the team overview dashboard to Go" && git push
dac sh -c 'percli dac build -f dashboards/go/team-overview-go/main.go -ojson && percli apply -f built/dashboards/go/team-overview-go/main_output.json'
```

## Step 4: Compare both builds

```sh
dac sh -c 'for f in dashboards/cue/team-overview.cue dashboards/go/team-overview-go/main.go; do percli dac build -f $f -ojson -m stdout | jq -c "[.spec.layouts[].spec.display.title, [.spec.panels[].spec.queries[0].spec.plugin.spec.query]]"; done'
```

Both lines are the same. Submit:

```sh
astrona submit -c sections/section-030/module-01/labs/lab-01
```

## Why the obvious shortcuts are wrong

| Shortcut | What happens |
| --- | --- |
| Write the queries with `query.PromQL` in `main.go` | The queries live in two places; the grader requires the shared functions |
| Put the program in `dashboards/go/storage/` next to the storage dashboard | Two `main` programs in one folder do not compile together |
| Name the dashboard `team-overview` | It replaces the CUE dashboard on the server instead of standing next to it |
