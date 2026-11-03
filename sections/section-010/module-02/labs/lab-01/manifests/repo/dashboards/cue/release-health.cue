// The release health dashboard: the scrape targets and series behind a release.
package dashboards

import (
	dashboardBuilder "github.com/perses/perses/cue/dac-utils/dashboard"
	panelGroupsBuilder "github.com/perses/perses/cue/dac-utils/panelgroups"

	"example.com/dashboards/lib/panels"
)

dashboardBuilder & {
	#name:    "release-health"
	#project: "staging"
	#display: name: "Release Health"
	#duration: "1h"

	#panelGroups: panelGroupsBuilder & {
		#input: [
			{
				#title: "Targets"
				#cols:  2
				#panels: [
					{panels.#TargetsUp & {#job: "prometheus"}}.panel,
					{panels.#TargetsUp & {#job: "perses"}}.panel,
				]
			},
			{
				#title: "Series"
				#cols:  1
				#panels: [
					{panels.#HeadSeries & {#job: "prometheus"}}.panel,
				]
			},
		]
	}
}
