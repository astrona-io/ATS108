# Write Dashboards In Go

A dashboard written as a Go program can use everything Go offers: functions, loops, packages and tests. `percli dac build` runs the program and takes what it prints as the dashboard. That one fact shapes every rule in this module.

Keep one sentence in mind: **a Go dashboard is a `main` program that builds a dashboard with the SDK and prints only that dashboard.** Anything else it prints, and anything that stops it from running with `go run`, breaks the build.

The module has three parts. **A Go Module For Dashboards** looks at the module files and the exec convention the build relies on. **Dashboards, Panel Groups, Panels And Queries In Go** writes a new dashboard with the builders and the plugin packages. **Reusable Functions And Tests** moves shared code into a library package and tests it. A graded lab follows the third part.

## Learning objectives

After this module you can:

- Describe the Go module of a DaC repository and what `percli dac setup --language go` prepares.
- Explain the exec convention and how `percli dac build` runs a Go file.
- Build a dashboard with the dashboard, panel group, panel, query and variable builders.
- Use the chart and query packages of the Prometheus, StatChart and TimeSeriesChart plugins.
- Put shared panels in a library package, test them with `go test`, and keep tests out of the folders `percli` builds.

## Before you start

You need the Dashboard-as-Code workflow: the repository `gitops/dashboards` holds the source, the `dac-runner` pod builds what is pushed to `main`, and `percli apply` puts the result on the server. You need to read Go: packages, imports, functions, slices and a `for` loop. You do not need Go on your machine; the runner has Go 1.26.5.

Your playground is a single-node `kind` cluster with Perses (project `inventory`, datasource `prometheus`), Prometheus with the scrape jobs `prometheus` and `perses`, the Git server Gitea with the repository `gitops/dashboards`, and the `dac-runner` pod. The dashboard `prometheus-storage` is already applied from `dashboards/go/storage/main.go`. Every command in the parts runs against the playground.

Launch your playground now, and keep it running next to you while you read the parts:

<!-- astrona:playground -->
