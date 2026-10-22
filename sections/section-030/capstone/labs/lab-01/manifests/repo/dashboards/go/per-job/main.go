// The per-job dashboard: one panel group per Prometheus scrape job.
// Build it with: percli dac build -f dashboards/go/per-job/main.go -ojson
package main

import (
	"flag"
	"fmt"
	"time"

	"github.com/perses/perses/go-sdk"
	"github.com/perses/perses/go-sdk/dashboard"

	"example.com/dashboards/lib/boards"
)

func main() {
	flag.Parse()
	exec := sdk.NewExec()
	options := []dashboard.Option{
		dashboard.ProjectName("inventory"),
		dashboard.Name("Per Job"),
		dashboard.Duration(time.Hour),
	}
	options = append(options, boards.JobGroups([]string{"prometheus", "perses"})...)
	fmt.Println("building the per-job dashboard for", len(options), "options")
	builder, buildErr := dashboard.New("per-job", options...)
	exec.BuildDashboard(builder, buildErr)
}
