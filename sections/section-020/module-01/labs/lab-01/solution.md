# Solution: Compose A Dashboard From Shared Panels

Work the task yourself first. Running `astrona submit -c sections/section-020/module-01/labs/lab-01` after a step tells you which checks pass.

The grader checks three things: the file takes its panels from the shared package, the build has the required variable, groups and panels, and the server equals the build of `main`.

## Step 1: Clone the repository

Start the Gitea port-forward in a second terminal (`kubectl -n gitea port-forward svc/gitea-http 3000:3000`), then clone and define the helper:

```sh
git clone http://gitops:gitops-password@gitea.localtest.me:3000/gitops/dashboards.git
cd dashboards
dac() { kubectl -n dac exec -i deploy/dac-runner -- dac-run "$@"; }
```

## Step 2: Write the dashboard

Save this as `dashboards/cue/team-overview.cue`:

```cue
// The team overview dashboard: the selected job, and Perses itself.
package dashboards

import (
	dashboardBuilder "github.com/perses/perses/cue/dac-utils/dashboard"
	panelGroupsBuilder "github.com/perses/perses/cue/dac-utils/panelgroups"
	varGroupBuilder "github.com/perses/perses/cue/dac-utils/variable/group"
	labelValuesVarBuilder "github.com/perses/plugins/prometheus/sdk/cue/variable/labelvalues"

	"example.com/dashboards/lib/panels"
)

dashboardBuilder & {
	#name:    "team-overview"
	#project: "inventory"
	#display: name: "Team Overview"
	#duration: "1h"

	#variables: {varGroupBuilder & {
		#datasourceName: "prometheus"
		#input: [
			labelValuesVarBuilder & {
				#name: "job"
				#display: name: "Job"
				#metric: "up"
			},
		]
	}}.variables

	#panelGroups: panelGroupsBuilder & {
		#input: [
			{
				#title: "Selected job"
				#cols:  2
				#panels: [panels.#TargetsUp.panel, panels.#HeadSeries.panel]
			},
			{
				#title: "Perses"
				#cols:  1
				#panels: [{panels.#TargetsUp & {#job: "perses"}}.panel]
			},
		]
	}
}
```

The first group uses the definitions without an argument, so their `#job` default, `"$job"`, puts the dashboard variable into the queries. The second group fixes the job to `perses`.

## Step 3: Push, build and apply

```sh
git add dashboards/cue/team-overview.cue && git commit -m "Add the team overview dashboard" && git push
dac sh -c 'percli dac build -f dashboards/cue/team-overview.cue -ojson && percli apply -f built/dashboards/cue/team-overview_output.json'
```

## Step 4: Check the result

```sh
dac sh -c 'percli dac build -f dashboards/cue/team-overview.cue -ojson -m stdout | jq "[.spec.panels | to_entries[] | [.key, .value.spec.display.name, .value.spec.queries[0].spec.plugin.spec.query]]"'
```

The panels are `0_0` `Targets up` with `sum(up{job="$job"})`, `0_1` `Head series` with `prometheus_tsdb_head_series{job="$job"}`, and `1_0` `Targets up` with `sum(up{job="perses"})`. Submit:

```sh
astrona submit -c sections/section-020/module-01/labs/lab-01
```

## Why the obvious shortcuts are wrong

| Shortcut | What happens |
| --- | --- |
| Copy the panel spec from `lib/panels` into the dashboard | The query lives in two places; the grader rejects queries written in the dashboard |
| Use `panels.#TargetsUp` without `.panel` | The build fails or produces the definition instead of a panel |
| Add `#job` inside the panel builder | The panel schema is closed, so the field is rejected |
