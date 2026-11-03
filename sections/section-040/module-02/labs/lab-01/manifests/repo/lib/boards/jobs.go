package boards

import (
	"github.com/perses/perses/go-sdk/dashboard"
	panelgroup "github.com/perses/perses/go-sdk/panel-group"
)

// JobGroups returns one panel group per scrape job, named "Job <job>", with
// the targets that are up and the samples appended for that job.
func JobGroups(jobs []string) []dashboard.Option {
	var groups []dashboard.Option
	for _, job := range jobs {
		groups = append(groups, dashboard.AddPanelGroup("Job "+job,
			panelgroup.PanelsPerLine(2),
			TargetsUp(job),
			SamplesAppended(job),
		))
	}
	return groups
}
