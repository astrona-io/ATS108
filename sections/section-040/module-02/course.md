# Pipelines Beyond The Playground

The pipeline in the playground runs against a Perses server with no login, and it always applies what it builds. A real pipeline logs in, runs on every commit, and often has to check a commit without changing the server. This module covers what changes outside the playground: how a pipeline authenticates, how it runs in a check-only mode, how versions stay aligned, and how it proves that the server matches the code.

Keep one sentence in mind: **a pipeline must be able to say no to a commit without touching the server, and must be able to prove what it did after it says yes.**

The module has four parts. **Authenticating The Pipeline** covers `percli login` with a username and password or a token. **Check And Deploy Modes** adds a switch so the same script can check a commit or deploy it. **Keeping Versions Aligned** lists the versions that must agree. **Verifying After Apply** compares the server with the code after a run. A graded lab follows the second part.

## Learning objectives

After this module you can:

- Describe how a pipeline logs in to a Perses server that has authentication on.
- Pass a secret to a pipeline Job without writing it in the script.
- Add a check-only mode to a pipeline script and start a run in that mode.
- Name the versions that must agree between the runner, the server, the SDKs and the plugins.
- Verify with the API and with `percli dac diff` that the server holds what the code builds.

## Before you start

You need the pipeline as a Job from the CronJob `dashboards-pipeline`, the steps fetch, dependencies, build, lint, diff and apply, and the habit of reading a failed run from the Job to the end of its log.

Your playground is a single-node `kind` cluster with Perses (project `inventory`, datasource `prometheus`), Prometheus, the Git server Gitea with the repository `gitops/dashboards`, the `dac-runner` pod, and the working pipeline. Authentication is off in this course. The parts describe how a pipeline logs in when it is on, and no lab turns it on.

Launch your playground now, and keep it running next to you while you read the parts:

<!-- astrona:playground -->
