# Overview: Write Dashboards In CUE (Playground)

This is a **playground**, not a lab. It starts a fresh cluster with Perses, Prometheus, a Git server and a build pod, pushes a repository of dashboards as code, and waits. There is no task, no `astrona submit` and no pass or fail. Explore, break things, `astrona destroy`, start over.

## What's in the box

- A single-node `kind` Kubernetes cluster. `kubectl` is already pointed at it.
- **Perses v0.54.0** in the namespace `perses`, with the project `inventory` and its datasource `prometheus`. The dashboard `prometheus-overview` is already applied from `dashboards/cue/prometheus-overview.cue`.
- **Prometheus** in the namespace `observability`, with the scrape jobs `prometheus` and `perses`.
- **Gitea** in the namespace `gitea`, with the repository `gitops/dashboards` (lab-only user `gitops`, password `gitops-password`).
- The pod **`dac-runner`** in the namespace `dac`, with `percli` v0.54.0, `cue` v0.17.1 and Go 1.26.5. It builds what is pushed to `main`.

The repository holds a CUE module (`cue.mod/module.cue`), the shared panel package `lib/panels` with `#TargetsUp`, `#SamplesAppended` and `#HeadSeries`, and the CUE dashboard `dashboards/cue/prometheus-overview.cue`.

## Helpers

Paste these once in each new terminal. `dac` runs a command in the runner, in an up-to-date copy of `main`. `build_cue` builds one CUE file and prints the result as JSON.

```sh
dac() { kubectl -n dac exec -i deploy/dac-runner -- dac-run "$@"; }
build_cue() { dac percli dac build -f "$1" -ojson -m stdout; }
```

Use them like this: `build_cue dashboards/cue/prometheus-overview.cue | jq '.spec.layouts'`. To clone, start `kubectl -n gitea port-forward svc/gitea-http 3000:3000` in a second terminal and run `git clone http://gitops:gitops-password@gitea.localtest.me:3000/gitops/dashboards.git`.

## Practice tasks

- Change `#cols` of the `Scrape health` group to `1`, push, and predict the new grid positions before you build.
- Add a second variable to the variable group and look at the matcher the builder writes for it.
- Give `#TargetsUp` a misspelled field, such as `titel`, in its `spec.display`. Read where the build error points.
- Write a fourth shared definition in `lib/panels`, for example the rate of `prometheus_http_requests_total`, and use it in a dashboard.
- Evaluate `lib/panels/panels.cue` on its own with `dac cue eval lib/panels/panels.cue` and compare it with the built dashboard.
