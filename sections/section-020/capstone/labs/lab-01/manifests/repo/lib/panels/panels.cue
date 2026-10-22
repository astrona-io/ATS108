// Package panels holds the panels the CUE dashboards of this repository
// share. Each definition takes a #job parameter (default: the dashboard
// variable $job) and exposes the finished panel as `panel`.
package panels

import (
	panelBuilder "github.com/perses/plugins/prometheus/sdk/cue/panel"
	statChart "github.com/perses/plugins/statchart/schemas:model"
	timeseriesChart "github.com/perses/plugins/timeserieschart/schemas:model"
	promQuery "github.com/perses/plugins/prometheus/schemas/prometheus-time-series-query:model"
)

// #datasource is the project datasource every query uses.
#datasource: "prometheus"

// #promQuery turns a PromQL expression into a Perses query on #datasource.
#promQuery: {
	#expr: string
	query: {
		kind: "TimeSeriesQuery"
		spec: plugin: promQuery & {
			spec: {
				datasource: {
					kind: "PrometheusDatasource"
					name: #datasource
				}
				query: #expr
			}
		}
	}
}

// #TargetsUp: how many scrape targets of the job are up.
#TargetsUp: {
	#job: string | *"$job"
	panel: panelBuilder & {
		spec: {
			display: name: "Targets up"
			plugin: statChart & {spec: calculation: "average"}
			queries: [{#promQuery & {#expr: "sum(up{job=\"\(#job)\"})"}}.query]
		}
	}
}

// #SamplesAppended: how many samples per second the job's server ingests.
#SamplesAppended: {
	#job: string | *"$job"
	panel: panelBuilder & {
		spec: {
			display: name: "Samples appended per second"
			plugin: timeseriesChart
			queries: [{#promQuery & {#expr: "rate(prometheus_tsdb_head_samples_appended_total{job=\"\(#job)\"}[5m])"}}.query]
		}
	}
}

// #HeadSeries: how many series the job's server holds in its head block.
#HeadSeries: {
	#job: string | *"$job"
	panel: panelBuilder & {
		spec: {
			display: name: "Head series"
			plugin: timeseriesChart
			queries: [{#promQuery & {#expr: "prometheus_tsdb_head_series{job=\"\(#job)\"}"}}.query]
		}
	}
}
