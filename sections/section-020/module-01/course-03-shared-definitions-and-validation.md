# Shared Definitions And Build-Time Validation

Ten dashboards that each define their own "targets up" panel will soon have ten slightly different queries. A shared package defines the panel once, and every dashboard uses it. This part reads the repository's panel library, uses a definition with a parameter in a new dashboard, and then breaks a value on purpose to see how CUE reports it.

## A definition with a parameter

Open the library:

<!-- astrona:playground:renew -->

```sh
dac() { kubectl -n dac exec -i deploy/dac-runner -- dac-run "$@"; }
dac cat lib/panels/panels.cue
```

The package `panels` holds three definitions: `#TargetsUp`, `#SamplesAppended` and `#HeadSeries`. Each one has the same shape:

```cue
#TargetsUp: {
	#job: string | *"$job"
	panel: panelBuilder & {
		spec: {
			display: name: "Targets up"
			plugin: statChart & {spec: calculation: "last"}
			queries: [{#promQuery & {#expr: "sum(up{job=\"\(#job)\"})"}}.query]
		}
	}
}
```

`#job` is the parameter. It is a string with the default `"$job"`, so without an argument the query uses the dashboard variable `job`. `\(#job)` is string interpolation: CUE puts the value of `#job` into the query. The finished panel is in the field `panel`. A dashboard takes it with `panels.#TargetsUp.panel` for the default, or `{panels.#TargetsUp & {#job: "perses"}}.panel` to fix the job. The braces unify the definition with your argument first, then `.panel` selects the result.

The panel is in its own field for a reason. `panelBuilder` produces a Perses panel, which is a closed definition. Adding a new field such as `#job` to it would be a field the panel schema does not declare. Keeping the parameter beside the panel, not inside it, keeps the panel schema as strict as it is.

## Use the library in a new dashboard

Save this as `dashboards/cue/perses-health.cue` in your clone:

```cue
package dashboards

import (
	dashboardBuilder "github.com/perses/perses/cue/dac-utils/dashboard"
	panelGroupsBuilder "github.com/perses/perses/cue/dac-utils/panelgroups"

	"example.com/dashboards/lib/panels"
)

dashboardBuilder & {
	#name:    "perses-health"
	#project: "inventory"
	#display: name: "Perses Health"

	#panelGroups: panelGroupsBuilder & {
		#input: [
			{
				#title: "Perses"
				#cols:  1
				#panels: [{panels.#TargetsUp & {#job: "perses"}}.panel]
			},
		]
	}
}
```

The file writes no query and no plugin. Push it, build it and look at the query:

```sh
git add dashboards/cue/perses-health.cue && git commit -m "Add the Perses health dashboard" && git push
dac sh -c 'percli dac build -f dashboards/cue/perses-health.cue -ojson -m stdout | jq ".spec.panels[\"0_0\"].spec.queries[0].spec.plugin.spec.query"'
```

The query is `sum(up{job="perses"})`. It came from the library, with your argument in place of the default.

## Let the schema catch a mistake

Now make the kind of mistake a schema exists for. In your clone, open `lib/panels/panels.cue` and change the Stat calculation of `#TargetsUp` from `"last"` to `"average"`, a word that sounds right but is not one of the values the Stat chart accepts. Push, then build every dashboard:

```sh
git commit -am "Use the average in Targets up" && git push
dac percli dac build -d dashboards -ojson
```

Every dashboard that uses `#TargetsUp` fails, and `percli` lists each failure at the end. Each error names the path of the field, ending in `calculation`, and says that `"average"` does not match any of the allowed values. The mistake was made once, in the library, and the build refused every dashboard it would have reached. The server never saw it.

Put the value back to `"last"` and push again, so the playground builds cleanly:

```sh
git commit -am "Back to the last value in Targets up" && git push
```

You now know how a shared definition takes a parameter, how a dashboard uses it, and how the plugin schemas stop a wrong value at build time. That is everything the graded lab needs.

## Common pitfalls

> [!WARNING]
> - **Forgetting `.panel`.** `panels.#TargetsUp` is the definition with its parameter; the panel is in its `panel` field.
> - **Fixing a schema error by loosening the schema.** The error is in the value. Change the value, never the plugin's schema or the `#job: string` type.
> - **Testing one file after changing the library.** A library change affects every dashboard that imports it. Build the whole folder with `-d`.

## Your mission: Compose A Dashboard From Shared Panels

You can now build a dashboard from the Perses builders and the repository's shared panels. The graded lab asks you to write a new CUE dashboard with a variable, two panel groups and three panels, using only the shared library, and put it on the server.

The lab runs in its own cluster, so first pause your playground. Nothing in it is lost:

```sh
astrona stop ats-108-playground-020-01
```

Then start the lab:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS108.git -c sections/section-020/module-01/labs/lab-01
```

The task is on the next page. Solve it on your own first. When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-020/module-01/labs/lab-01
```

When the lab is done, remove it and start your playground again:

```sh
astrona destroy ats-108-lab-020-01
astrona start ats-108-playground-020-01
```
