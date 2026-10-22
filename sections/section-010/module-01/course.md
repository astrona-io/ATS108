# Build And Apply Your First Dashboard As Code

A dashboard edited in the browser has no history. You cannot review a change before it goes live, and you cannot see who changed a query last week or why. Dashboard-as-Code (DaC) moves the dashboard into a Git repository as a source file, and builds the file into the JSON that Perses stores.

This module walks through that loop once, end to end. Keep one sentence in mind: **Git holds the source, `percli dac build` turns it into a dashboard, and `percli apply` puts the dashboard on the server.** Everything else in this course is a variation of that sentence.

The module has three parts. **Dashboards As Code** explains what DaC solves and compares the two ways Perses offers to write dashboards: the CUE SDK and the Go SDK. **The Repository And The Build** clones the repository, shows its layout, and builds a dashboard into the `built` folder. **Applying And Diffing Built Dashboards** applies the result to Perses and compares the server with the code. A graded lab follows the third part.

## Learning objectives

After this module you can:

- Explain what Dashboard-as-Code solves that editing dashboards in the browser does not.
- Compare the CUE SDK and the Go SDK, and say when each one fits.
- Describe the layout of a DaC repository and what `percli dac setup` prepares.
- Build a CUE file or a Go program into a dashboard with `percli dac build`, and find the result in the `built` folder.
- Apply a built dashboard with `percli apply` and check it through the Perses API.
- Find the differences between the server and the code with `percli dac diff`.

## Before you start

You need Git basics (clone, commit, push, pull), `kubectl exec`, and an idea of what a Perses dashboard holds: panels, a layout that places them, queries, and variables. You do not need to know CUE or Go. The files you build in this module are provided.

Your playground is a single-node `kind` cluster with these parts:

| Part | What it is |
| --- | --- |
| Perses v0.54.0 | The dashboard server, in the namespace `perses`, with the project `inventory` and its datasource `prometheus` |
| Prometheus | In the namespace `observability`; it collects metrics from itself and from Perses |
| Gitea | A Git server in the namespace `gitea`, with the repository `gitops/dashboards` |
| `dac-runner` | A pod in the namespace `dac` with `percli`, `cue` and Go; every build runs here |

One dashboard is already on the server: `prometheus-storage`, built from a Go program in the repository. Every command in the parts runs against the playground, and `kubectl` already points at it.

Launch your playground now, and keep it running next to you while you read the parts:

<!-- astrona:playground -->
