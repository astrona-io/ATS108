# Prepare A Repository And Control Where Dashboards Go

A repository that builds on one machine and not on another, or a dashboard that lands in the wrong project, wastes more time than any query mistake. Both problems come from setup and from the options of the build and the apply commands. This module covers both.

Keep one sentence in mind: **the repository fixes the versions, the build options fix the output, and the project in the metadata fixes the destination.**

The module has four parts. **Setting Up A CUE Repository** creates a CUE module from nothing and prepares it with `percli dac setup`. **Setting Up A Go Repository** does the same for a Go module. **Controlling The Build** covers the options that choose the input, the format and the destination of a build. **Projects And The Apply Command** covers how `percli apply` chooses a project and what it refuses. A graded lab follows the fourth part.

## Learning objectives

After this module you can:

- Create a CUE module and prepare it for the Perses CUE SDK with `percli dac setup`.
- Create a Go module and prepare it for the Perses Go SDK with `percli dac setup --language go`.
- Choose between building one file and a folder, between JSON and YAML, and between a file and standard output.
- Predict the path of a built file from the path of its source.
- Explain why `percli apply` refuses a dashboard whose project differs from the selected project, and fix the cause in the code.

## Before you start

You need the Dashboard-as-Code loop: the source is in Git, the `dac-runner` pod builds what is pushed to `main`, and `percli apply` puts the result on the server. You do not need CUE or Go.

Your playground is a single-node `kind` cluster with Perses (project `inventory`, datasource `prometheus`), Prometheus, the Git server Gitea with the repository `gitops/dashboards`, and the `dac-runner` pod. Every command in the parts runs against the playground.

Launch your playground now, and keep it running next to you while you read the parts:

<!-- astrona:playground -->
