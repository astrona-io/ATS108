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
