module: "example.com/dashboards@v0"
language: {
	version: "v0.17.1"
}
source: {
	kind: "self"
}
deps: {
	"github.com/perses/perses/cue@v0": {
		v:       "v0.54.0"
		default: true
	}
	"github.com/perses/plugins/prometheus@v0": {
		v:       "v0.58.0"
		default: true
	}
	"github.com/perses/plugins/statchart@v0": {
		v:       "v0.13.0"
		default: true
	}
	"github.com/perses/plugins/timeserieschart@v0": {
		v:       "v0.13.0"
		default: true
	}
	"github.com/perses/shared/cue@v0": {
		v:       "v0.54.0"
		default: true
	}
	"github.com/perses/spec/cue@v0": {
		v:       "v0.2.0"
		default: true
	}
}
