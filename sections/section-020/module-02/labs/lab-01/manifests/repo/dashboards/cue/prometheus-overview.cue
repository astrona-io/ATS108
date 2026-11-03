// The Prometheus overview dashboard, built from the shared panels.
// Build it with: percli dac build -f dashboards/cue/prometheus-overview.cue -ojson
package dashboards

import (
	dashboardBuilder "github.com/perses/perses/cue/dac-utils/dashboard"
	panelGroupsBuilder "github.com/perses/perses/cue/dac-utils/panelgroups"
	varGroupBuilder "github.com/perses/perses/cue/dac-utils/variable/group"
	labelValuesVarBuilder "github.com/perses/plugins/prometheus/sdk/cue/variable/labelvalues"

	"example.com/dashboards/lib/panels"
)

dashboardBuilder & {
	#name:    "prometheus-overview"
	#project: "inventory"
	#display: name: "Prometheus Overview"
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
				#title: "Scrape health"
				#cols:  2
				#panels: [panels.#TargetsUp.panel, panels.#SamplesAppended.panel]
			},
			{
				#title: "Storage"
				#cols:  1
				#panels: [panels.#HeadSeries.panel]
			},
		]
	}
}
