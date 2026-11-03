# Reusable Go Dashboards

A Go dashboard is a program, so the usual tools of a program apply: functions, loops, slices and tests. This module uses them to stop copying code. You write one function for a panel group, build a dashboard from a list of jobs in a loop, test the function with `go test`, and compare the Go approach with CUE.

Keep one sentence in mind: **a builder option is a value, so you can return it from a function, keep it in a slice and pass the slice to the builder.** An option is a function that changes the builder, such as `dashboard.AddPanelGroup(...)`.

The module has four parts. **Options As Building Blocks** shows the two option types and writes a function that returns a panel group. **Data-Driven Dashboards** builds a list of options in a loop. **Testing Dashboard Functions** checks the number of panels and layouts with table-driven tests. **Choosing Between CUE And Go** compares what both SDKs build. A graded lab follows the third part.

## Learning objectives

After this module you can:

- Name the option types `panelgroup.Option` and `dashboard.Option`, and write a function that returns one.
- Build a slice of options in a loop and pass it to `dashboard.New` with `options...`.
- Write a table-driven test for a library function.
- Read the panel and layout counts of a built dashboard in a test.
- Choose between CUE and Go for a dashboard, and compare their builds.

## Before you start

You need the Go module and `sdk.NewExec()` convention, the Go builders for dashboards, panel groups and panels, and the library package `lib/boards` with its tests.

Your playground is a single-node `kind` cluster with Perses (project `inventory`, datasource `prometheus`), Prometheus, the Git server Gitea with the repository `gitops/dashboards`, and the `dac-runner` pod with `percli`, `cue` and Go. Every command in the parts runs against the playground.

Launch your playground now, and keep it running next to you while you read the parts:

<!-- astrona:playground -->
