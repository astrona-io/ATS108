# Choosing Between CUE And Go

Both SDKs build the same Perses resource, so the choice is about how you want to write and check the code. This part states the differences that matter, and compares the output of one CUE dashboard and one Go dashboard in the repository, so that you can read both builds in the same way.

## What differs

CUE checks a dashboard against the plugin schemas while it evaluates, and it reports a conflict with a field path. Go checks types when it compiles, and it reports a mismatch with a line number. CUE has no loops as statements; it uses comprehensions. Go has loops, functions, packages and a test runner. A CUE definition closes a structure, so a misspelled field fails. A Go function with a typed parameter fails when you pass the wrong type, but it accepts any string for a job name.

A team that already writes Go services can reuse its tools: editor support, `go vet`, `go test` and code review habits. A team that wants strict schemas and a short file for each dashboard often prefers CUE. A repository can hold both, because `percli dac build` reads each file on its own.

## Compare two builds

The overview dashboard is written in CUE and the storage dashboard in Go. List the plugin kind and the query of every panel in both:

<!-- astrona:playground:renew -->

```sh
dac() { kubectl -n dac exec -i deploy/dac-runner -- dac-run "$@"; }
dac sh -c 'percli dac build -f dashboards/cue/prometheus-overview.cue -ojson -m stdout | jq -c "[.spec.panels[] | [.spec.plugin.kind, .spec.queries[0].spec.plugin.spec.query]]"'
dac sh -c 'percli dac build -f dashboards/go/storage/main.go -ojson -m stdout | jq -c "[.spec.panels[] | [.spec.plugin.kind, .spec.queries[0].spec.plugin.spec.query]]"'
```

Both lists have the same shape: pairs of a chart kind, such as `TimeSeriesChart`, and a PromQL query. The tool that built the resource does not show in the result. That is the point of the SDKs: the server only sees the resource.

## Move a dashboard between SDKs safely

To port a dashboard, build the old one and the new one, and compare the parts that must stay equal: group titles, panel names, plugin kinds and queries. The names of the two dashboards must differ while both exist, because two resources with the same name and project replace each other on the server. After you compare the two builds and see no difference in those parts, apply the new one and remove the old one.

You now know how the two SDKs differ and how to check that a port keeps the same content. The next step is to run the whole thing from a pipeline.

## Common pitfalls

> [!WARNING]
> - **Comparing the whole JSON.** The dashboard name and display name differ on purpose. Compare groups, panels and queries.
> - **Giving both versions the same name.** The second apply replaces the first.
> - **Choosing by taste during a migration.** Port one dashboard, compare it, then continue.
