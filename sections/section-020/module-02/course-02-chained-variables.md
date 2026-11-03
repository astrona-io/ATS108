# Chained Variables

A variable is a dropdown at the top of a dashboard. Often the second dropdown should only list values that fit the first: the instances of the selected job, not all instances. Perses calls this a chain, and the CUE variable group builder produces it. This part builds two variables and reads what the builder wrote for the second one.

## The variable group

The group builder, `varGroupBuilder`, takes a list of variables in `#input` and a datasource name in `#datasourceName`. It gives the datasource to each variable. It also passes the variables listed before a variable to that variable, in order. The Prometheus label values builder uses them to build its matchers.

Read the single variable of the overview dashboard first:

<!-- astrona:playground:renew -->

```sh
dac() { kubectl -n dac exec -i deploy/dac-runner -- dac-run "$@"; }
dac sh -c 'percli dac build -f dashboards/cue/prometheus-overview.cue -ojson -m stdout | jq ".spec.variables[0].spec.plugin.spec"'
```

The plugin spec holds the label name `job`, the datasource and the matchers, which is the metric `up{}` with no filter, since no variable comes before it.

## Add a second variable

The overview dashboard in the repository has one variable. Clone the repository (start the Gitea port-forward in a second terminal first, with `kubectl -n gitea port-forward svc/gitea-http 3000:3000`):

```sh
git clone http://gitops:gitops-password@gitea.localtest.me:3000/gitops/dashboards.git
cd dashboards
```

Save this as `dashboards/cue/chained.cue`:

```cue
// A dashboard with two chained variables: job, then instance.
package dashboards

import (
	dashboardBuilder "github.com/perses/perses/cue/dac-utils/dashboard"
	panelGroupsBuilder "github.com/perses/perses/cue/dac-utils/panelgroups"
	varGroupBuilder "github.com/perses/perses/cue/dac-utils/variable/group"
	labelValuesVarBuilder "github.com/perses/plugins/prometheus/sdk/cue/variable/labelvalues"

	"example.com/dashboards/lib/panels"
)

dashboardBuilder & {
	#name:    "chained"
	#project: "inventory"
	#display: name: "Chained Variables"
	#duration: "1h"

	#variables: {varGroupBuilder & {
		#datasourceName: "prometheus"
		#input: [
			labelValuesVarBuilder & {
				#name: "job"
				#display: name: "Job"
				#metric: "up"
			},
			labelValuesVarBuilder & {
				#name: "instance"
				#display: name: "Instance"
				#metric: "up"
			},
		]
	}}.variables

	#panelGroups: panelGroupsBuilder & {
		#input: [{
			#title: "Selected job"
			#cols:  1
			#panels: [panels.#TargetsUp.panel]
		}]
	}
}
```

Push it and read the matchers of both variables:

```sh
git add dashboards/cue/chained.cue && git commit -m "Add a dashboard with chained variables" && git push
dac sh -c 'percli dac build -f dashboards/cue/chained.cue -ojson -m stdout | jq "[.spec.variables[] | {name: .spec.name, matchers: .spec.plugin.spec.matchers}]"'
```

The first variable has the plain matcher `up{}`. The second has a matcher that also filters on the label `job`, using the value of the first variable. When the viewer picks a job, the second dropdown lists only that job's instances.

## Order matters

The builder passes a variable only to the ones after it. If you list `instance` first, it has nothing to filter by, and `job` would filter by `instance`. Order the list from the broadest variable to the most specific.

You now know that the variable group chains variables in list order, and how to read the result in the built matchers. The open question is how to create many panel groups from one list.

## Common pitfalls

> [!WARNING]
> - **Listing the variables in the wrong order.** The filter only flows forward.
> - **Using a variable in a query without defining it.** A query that contains `$instance` needs a variable with that name.
> - **Building a chain with a different datasource per variable.** The group passes one datasource name to all of them.
