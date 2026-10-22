# Overview: Lint, Build And Apply Dashboards From A Pipeline (Playground)

This is a **playground**, not a lab. It starts a fresh cluster with Perses, Prometheus, a Git server, a build pod and a dashboard pipeline, pushes a repository of dashboards as code, and waits. There is no task, no `astrona submit` and no pass or fail. Explore, break things, `astrona destroy`, start over.

## What's in the box

- A single-node `kind` Kubernetes cluster. `kubectl` is already pointed at it.
- **Perses v0.54.0** in the namespace `perses`, with the project `inventory` and its datasource `prometheus`. No dashboard is applied yet.
- **Prometheus** in the namespace `observability`, with the scrape jobs `prometheus` and `perses`.
- **Gitea** in the namespace `gitea`, with the repository `gitops/dashboards`: the CUE dashboard `prometheus-overview`, and the Go dashboards `prometheus-storage` and `per-job` (lab-only user `gitops`, password `gitops-password`).
- The pod **`dac-runner`** in the namespace `dac`, with `percli`, `cue` and Go.
- The pipeline in the namespace `dac`: the ConfigMap `dashboards-pipeline` with `pipeline.sh`, and the suspended CronJob `dashboards-pipeline` that runs it.

## Helpers

Paste these once in each new terminal. `dac` runs a command in the runner. `run_pipeline` starts one pipeline run with the name you give, waits up to ten minutes, and prints its log.

```sh
dac() { kubectl -n dac exec -i deploy/dac-runner -- dac-run "$@"; }
run_pipeline() {
  kubectl -n dac create job "$1" --from=cronjob/dashboards-pipeline
  kubectl -n dac wait "job/$1" --for=condition=complete --timeout=600s
  kubectl -n dac logs "job/$1"
}
```

Use them like this: `run_pipeline run-1`, then `dac percli get dashboards`. If a run fails, `kubectl wait` times out; read the log with `kubectl -n dac logs job/<name>`.

To change the script, save it to a file with `kubectl -n dac get configmap dashboards-pipeline -o jsonpath='{.data.pipeline\.sh}' > pipeline.sh`, edit it, and replace the ConfigMap with `kubectl -n dac create configmap dashboards-pipeline --from-file=pipeline.sh --dry-run=client -o yaml | kubectl apply -f -`.

## Practice tasks

- Run the pipeline once and read the diff step in the log. Change a dashboard's title in the browser, run it again, and find the drift in the log.
- Push a CUE file with a syntax error and run the pipeline. Find the step that stopped it, and check that nothing was applied.
- Remove `--online` from the lint step, push a dashboard with an unknown plugin kind made with `jq`, and compare the two runs.
- Add a custom lint rule idea to the script as a comment, and write its `target` and `assertion` for "dashboard names use lower case and hyphens only".
- Delete a dashboard's file from Git, run the pipeline, and confirm the dashboard is still on the server. Remove it with `dac percli delete dashboard <name>`.
