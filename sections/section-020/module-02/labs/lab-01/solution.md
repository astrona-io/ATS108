# Solution: Generate One Group Per Job With A Comprehension

Work the task yourself first. Running `astrona submit -c sections/section-020/module-02/labs/lab-01` after a step tells you which checks pass.

The grader checks three things: the file takes its panels from the shared package and loops with `for`, the build has the required groups and panels, and the server equals the build of `main`.

## Step 1: Clone the repository

Start the Gitea port-forward in a second terminal (`kubectl -n gitea port-forward svc/gitea-http 3000:3000`), then clone and define the helper:

```sh
git clone http://gitops:gitops-password@gitea.localtest.me:3000/gitops/dashboards.git
cd dashboards
dac() { kubectl -n dac exec -i deploy/dac-runner -- dac-run "$@"; }
```

## Step 2: Write the dashboard

Save this as `dashboards/cue/jobs-overview.cue`:

```cue
// One panel group per scrape job, generated from a list.
package dashboards

import (
	dashboardBuilder "github.com/perses/perses/cue/dac-utils/dashboard"
	panelGroupsBuilder "github.com/perses/perses/cue/dac-utils/panelgroups"

	"example.com/dashboards/lib/panels"
)

_jobs: ["prometheus", "perses"]

dashboardBuilder & {
	#name:    "jobs-overview"
	#project: "inventory"
	#display: name: "Jobs Overview"
	#duration: "1h"

	#panelGroups: panelGroupsBuilder & {
		#input: [
			for job in _jobs {
				#title: job
				#cols:  2
				#panels: [
					{panels.#TargetsUp & {#job: job}}.panel,
					{panels.#HeadSeries & {#job: job}}.panel,
				]
			},
		]
	}
}
```

The hidden list `_jobs` is the only data. The comprehension makes one group per job, and each panel takes the job as its `#job` parameter.

## Step 3: Push, build and apply

```sh
git add dashboards/cue/jobs-overview.cue && git commit -m "Add the jobs overview dashboard" && git push
dac sh -c 'percli dac build -f dashboards/cue/jobs-overview.cue -ojson && percli apply -f built/dashboards/cue/jobs-overview_output.json'
```

## Step 4: Check the result

```sh
dac sh -c 'percli dac build -f dashboards/cue/jobs-overview.cue -ojson -m stdout | jq "[.spec.panels | to_entries[] | [.key, .value.spec.display.name, .value.spec.queries[0].spec.plugin.spec.query]]"'
```

The panels are `0_0` and `0_1` for `prometheus`, and `1_0` and `1_1` for `perses`, each with a query that names its job. Submit:

```sh
astrona submit -c sections/section-020/module-02/labs/lab-01
```

## Why the obvious shortcuts are wrong

| Shortcut | What happens |
| --- | --- |
| Write the two groups out by hand | The grader rejects a file without a `for` comprehension |
| Put the job list in a field without an underscore | The list appears in the output and the dashboard schema rejects it |
| Copy the panel queries into the dashboard | The query lives in two places; the grader rejects queries in the dashboard |
