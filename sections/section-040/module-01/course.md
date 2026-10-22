# Lint, Build And Apply Dashboards From A Pipeline

A Dashboard-as-Code repository is only as safe as the way its dashboards reach the server. If anyone can build and apply from their own machine, the server holds whatever was applied last, not what is on `main`. A pipeline fixes that: one automated run per commit, with the same steps every time.

Keep one sentence in mind: **a pipeline is only as strict as its first step that is allowed to fail.** If a failed build or a failed lint does not stop the run, the pipeline applies broken dashboards with confidence.

The module has three parts. **Validating Dashboards Before They Ship** looks at what `percli lint` really checks. **A Pipeline As A Kubernetes Job** reads the playground's pipeline, runs it, and follows its log. **Keeping Perses And Git The Same** covers credentials, deletions and edits made outside the pipeline. A graded lab follows the third part.

## Learning objectives

After this module you can:

- Explain what `percli lint` checks with `--online`, with `--plugin.path`, and with neither.
- List the pipeline steps in order and say why each one must stop the run when it fails.
- Run the pipeline as a Job from a suspended CronJob, and read its log and its result.
- Describe how a pipeline logs in to a Perses server with authentication on.
- Explain what `percli apply` does not do, such as deleting a dashboard removed from Git.

## Before you start

You need the Dashboard-as-Code workflow: the repository `gitops/dashboards` holds the source, `percli dac build` turns it into dashboards in the `built` folder, and `percli apply` puts them on the server. You need Kubernetes Jobs and CronJobs, ConfigMaps, and `kubectl logs`.

Your playground is a single-node `kind` cluster with Perses (project `inventory`, datasource `prometheus`), Prometheus, the Git server Gitea with the repository `gitops/dashboards`, and the `dac-runner` pod. The repository holds CUE and Go dashboards; none of them is on the server yet. The namespace `dac` also holds the pipeline: a ConfigMap `dashboards-pipeline` with the script `pipeline.sh`, and a suspended CronJob with the same name that runs it. Every command in the parts runs against the playground.

Launch your playground now, and keep it running next to you while you read the parts:

<!-- astrona:playground -->
