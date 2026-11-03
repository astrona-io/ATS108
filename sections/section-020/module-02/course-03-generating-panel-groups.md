# Generating Panel Groups

The scrape health dashboard repeats the same panels for two jobs, written out by hand. A third job means another block of near-identical lines. A comprehension over a list of jobs writes the blocks for you, and the shared panel definitions keep the queries in one place. This part rewrites a dashboard that way.

## One group per item

The panel groups builder takes a list in `#input`, and each element is a group with a `#title`, a number of columns `#cols` and a list of panels. A list comprehension produces that list. Save this as `dashboards/cue/per-job.cue`:

<!-- astrona:playground:renew -->

```cue
// One panel group per scrape job.
package dashboards

import (
	dashboardBuilder "github.com/perses/perses/cue/dac-utils/dashboard"
	panelGroupsBuilder "github.com/perses/perses/cue/dac-utils/panelgroups"

	"example.com/dashboards/lib/panels"
)

_jobs: ["prometheus", "perses"]

dashboardBuilder & {
	#name:    "per-job"
	#project: "inventory"
	#display: name: "Per Job"
	#duration: "1h"

	#panelGroups: panelGroupsBuilder & {
		#input: [
			for job in _jobs {
				#title: job
				#cols:  1
				#panels: [
					{panels.#TargetsUp & {#job: job}}.panel,
				]
			},
		]
	}
}
```

The hidden list `_jobs` is the only data. The comprehension makes one group for each job and sets the group title to the job name. Each group holds the shared `#TargetsUp` panel with its `#job` parameter set to that job.

## Build and read it

Push the file, build it to standard output and list the groups with their panel queries:

```sh
git add dashboards/cue/per-job.cue && git commit -m "Add a per-job dashboard" && git push
dac() { kubectl -n dac exec -i deploy/dac-runner -- dac-run "$@"; }
dac sh -c 'percli dac build -f dashboards/cue/per-job.cue -ojson -m stdout | jq "[.spec.layouts[].spec.display.title], [.spec.panels[].spec.queries[0].spec.plugin.spec.query]"'
```

The titles are `prometheus` and `perses`, and the queries are `sum(up{job="prometheus"})` and `sum(up{job="perses"})`. The panel keys are `0_0` and `1_0`: one panel at position 0 of group 0 and one of group 1.

## Add an item

Add `"tester"` to `_jobs`, push, and build again. The dashboard has a third group with no other edit. A comprehension turns a data change into a structure change, which is why a long list belongs in a hidden field at the top of the file.

## Several panels per group

The element of the comprehension can hold as many panels as you want. Put a second shared panel in the list and every group gets it:

```cue
#panels: [
	{panels.#TargetsUp & {#job: job}}.panel,
	{panels.#HeadSeries & {#job: job}}.panel,
]
```

With `#cols: 2`, the two panels sit side by side in each group.

You now know how to generate panel groups from a list with a hidden field, a comprehension and the shared panels. The module's lab asks you to build a dashboard this way.

## Common pitfalls

> [!WARNING]
> - **Writing queries in the dashboard.** Keep every query in the shared package.
> - **Using a normal field for the job list.** It would appear in the output. Use a name with an underscore.
> - **Expecting panel keys to follow job names.** Keys follow positions.

## Your mission: Generate One Group Per Job With A Comprehension

You can now produce panel groups from a list in CUE. The graded lab asks you to write a dashboard that has one group per scrape job from a single list, with no repeated blocks.

The lab runs in its own cluster, so first pause your playground. Nothing in it is lost:

```sh
astrona stop ats-108-playground-020-02
```

Then start the lab:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS108.git -c sections/section-020/module-02/labs/lab-01
```

The task is on the next page. Solve it on your own first. When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-020/module-02/labs/lab-01
```

When the lab is done, remove it and start your playground again:

```sh
astrona destroy ats-108-lab-020-02
astrona start ats-108-playground-020-02
```
