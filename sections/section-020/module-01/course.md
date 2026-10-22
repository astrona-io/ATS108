# Write Dashboards In CUE

A dashboard in JSON accepts any value you type. A calculation called `average` that the Stat panel does not know, a panel group without a title, a query left empty: the server finds out later, or nobody does. In CUE, the same mistakes stop the build, and the error names the field and the rule it broke.

This module teaches CUE from that angle. Keep one sentence in mind: **a CUE dashboard is your values unified with the Perses schemas, and the build fails if they cannot agree.** Unification is the CUE operation that combines two values into one that satisfies both.

The module has three parts. **CUE Essentials For Dashboards** runs small CUE files to show types, constraints, defaults, unification and definitions. **The Perses CUE Builders** reads a real dashboard built with the SDK: the dashboard builder, panel groups and a label values variable. **Shared Definitions And Build-Time Validation** shows how the repository's panel library takes a parameter, and what CUE says when a value breaks a schema. A graded lab follows the third part.

## Learning objectives

After this module you can:

- Explain unification, constraints, defaults and closed definitions, and predict the result of a small CUE file.
- Describe how a CUE module and its packages are organised, and import a package of the same module.
- Build a dashboard with the Perses dashboard, panel group and variable group builders.
- Use a shared panel definition with and without its parameter.
- Read a CUE build error and name the field and the constraint it reports.

## Before you start

You need the Dashboard-as-Code workflow: the repository `gitops/dashboards` holds the source, the `dac-runner` pod builds what is pushed to `main`, and `percli apply` puts the result on the server. You also need to know what a Perses dashboard holds: panels, layouts, queries and variables. You do not need to know CUE.

Your playground is a single-node `kind` cluster with Perses (project `inventory`, datasource `prometheus`), Prometheus, the Git server Gitea with the repository `gitops/dashboards`, and the `dac-runner` pod with `percli`, `cue` and Go. The dashboard `prometheus-overview` is already applied from `dashboards/cue/prometheus-overview.cue`. Every command in the parts runs against the playground.

Launch your playground now, and keep it running next to you while you read the parts:

<!-- astrona:playground -->
