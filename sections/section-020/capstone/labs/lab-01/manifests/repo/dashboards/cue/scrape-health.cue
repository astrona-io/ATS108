// The scrape health dashboard: one panel group per scrape job.
package dashboards

import (
	dashboardBuilder "github.com/perses/perses/cue/dac-utils/dashboard"
	panelGroupsBuilder "github.com/perses/perses/cue/dac-utils/panelgroups"

	"example.com/dashboards/lib/panels"
)

// _probeJob is the scrape job the Perses group shows.
_probeJob: string

dashboardBuilder & {
	#name:    "scrape-health"
	#project: "inventory"
	#display: name: "Scrape Health"
	#duration: "1h"

	#panelGroups: panelGroupsBuilder & {
		#input: [
			{
				#title: "Prometheus"
				#cols:  2
				#panels: [
					{panels.#TargetsUp & {#job: "prometheus"}}.panel,
					{panels.#SamplesAppended & {#job: "prometheus"}}.panel,
				]
			},
			{
				#title: "Perses"
				#cols:  1
				#panels: [
					{panels.#TargetsUp & {#job: _probeJob}}.panel,
				]
			},
		]
	}
}
