// The storage dashboard: how much data the Prometheus server holds.
// Build it with: percli dac build -f dashboards/go/storage/main.go -ojson
package main

import (
	"flag"
	"time"

	"github.com/perses/perses/go-sdk"
	"github.com/perses/perses/go-sdk/dashboard"
	panelgroup "github.com/perses/perses/go-sdk/panel-group"
	timeseries "github.com/perses/plugins/timeserieschart/sdk/go"

	"example.com/dashboards/lib/boards"
)

func main() {
	flag.Parse()
	exec := sdk.NewExec()
	builder, buildErr := dashboard.New("prometheus-storage",
		dashboard.ProjectName("inventory"),
		dashboard.Name("Prometheus Storage"),
		dashboard.Duration(time.Hour),
		dashboard.AddPanelGroup("Storage",
			panelgroup.PanelsPerLine(2),
			boards.HeadSeries("prometheus"),
			panelgroup.AddPanel("Chunks in the head block",
				timeseries.Chart(),
				boards.PromQuery(`prometheus_tsdb_head_chunks{job="prometheus"}`),
			),
		),
	)
	exec.BuildDashboard(builder, buildErr)
}
