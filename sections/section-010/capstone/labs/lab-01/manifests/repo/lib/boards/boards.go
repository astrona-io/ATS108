// Package boards holds reusable pieces for the Go dashboards in this
// repository. It is not package main, so `percli dac build` never runs it
// directly, and its tests can live next to it.
package boards

import (
	"fmt"

	"github.com/perses/perses/go-sdk/common"
	"github.com/perses/perses/go-sdk/panel"
	panelgroup "github.com/perses/perses/go-sdk/panel-group"
	"github.com/perses/plugins/prometheus/sdk/go/query"
	stat "github.com/perses/plugins/statchart/sdk/go"
	timeseries "github.com/perses/plugins/timeserieschart/sdk/go"
)

// Datasource is the project datasource every query in this repository uses.
const Datasource = "prometheus"

// PromQuery returns a Prometheus query on the project datasource.
func PromQuery(expr string) panel.Option {
	return panel.AddQuery(query.PromQL(expr, query.Datasource(Datasource)))
}

// TargetsUp is a stat panel with the number of healthy scrape targets of a job.
func TargetsUp(job string) panelgroup.Option {
	return panelgroup.AddPanel("Targets up",
		stat.Chart(stat.Calculation(common.LastCalculation)),
		PromQuery(fmt.Sprintf(`sum(up{job="%s"})`, job)),
	)
}

// SamplesAppended is a time series panel with the ingestion rate of a job.
func SamplesAppended(job string) panelgroup.Option {
	return panelgroup.AddPanel("Samples appended per second",
		timeseries.Chart(),
		PromQuery(fmt.Sprintf(`rate(prometheus_tsdb_head_samples_appended_total{job="%s"}[5m])`, job)),
	)
}

// HeadSeries is a time series panel with the number of series in the head block.
func HeadSeries(job string) panelgroup.Option {
	return panelgroup.AddPanel("Head series",
		timeseries.Chart(),
		PromQuery(fmt.Sprintf(`prometheus_tsdb_head_series{job="%s"}`, job)),
	)
}
