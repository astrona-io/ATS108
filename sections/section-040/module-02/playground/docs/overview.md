# Overview: Pipelines Beyond The Playground (Playground)

This is a **playground**, not a lab. It starts a fresh cluster with Perses, Prometheus, a Git server and a build pod, pushes a repository of dashboards as code, and waits. There is no task, no `astrona submit` and no pass or fail. Explore, break things, `astrona destroy`, start over.

## What's in the box

- A single-node `kind` Kubernetes cluster. `kubectl` is already pointed at it.
- **Perses v0.54.0** in the namespace `perses`, with the project `inventory` and its datasource `prometheus`. Authentication is off.
- **Prometheus** in the namespace `observability`, with the scrape jobs `prometheus` and `perses`.
- **Gitea** in the namespace `gitea`, with the repository `gitops/dashboards` (lab-only user `gitops`, password `gitops-password`).
- The pod **`dac-runner`** in the namespace `dac`, with `percli` v0.54.0, `cue` v0.17.1 and Go 1.26.5.
- The suspended CronJob **`dashboards-pipeline`** and its ConfigMap, the working pipeline. A run is started with `kubectl -n dac create job <name> --from=cronjob/dashboards-pipeline`.

## Helpers

Paste this once in each new terminal. `dac` runs a command in the runner, in an up-to-date copy of `main`.

```sh
dac() { kubectl -n dac exec -i deploy/dac-runner -- dac-run "$@"; }
```

## Practice tasks

- Print the pipeline script and find the line that logs in. Read `percli login --help` in the runner.
- Add the `MODE` switch to the script, start one check run and one deploy run, and compare the last lines of their logs.
- Push a CUE file that does not build and start a check run. Confirm that the Job fails.
- Read the tool versions in the ConfigMap `dac-runner-scripts` and the pins in `cue.mod/module.cue` and `go.mod`.
- List the dashboard names of the project through the API after a deploy run, then run `percli dac diff` and read the status of each dashboard.
