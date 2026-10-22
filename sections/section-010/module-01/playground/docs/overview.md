# Overview: Build And Apply Your First Dashboard As Code (Playground)

This is a **playground**, not a lab. It starts a fresh cluster with Perses, Prometheus, a Git server and a build pod, pushes a repository of dashboards as code, and waits. There is no task, no `astrona submit` and no pass or fail. Explore, break things, `astrona destroy`, start over.

## What's in the box

- A single-node `kind` Kubernetes cluster. `kubectl` is already pointed at it.
- **Perses v0.54.0** in the namespace `perses`, with the project `inventory` and its datasource `prometheus`. The dashboard `prometheus-storage` is already applied from code.
- **Prometheus** in the namespace `observability`. It collects metrics from itself (job `prometheus`) and from Perses (job `perses`).
- **Gitea**, a Git server, in the namespace `gitea`, with the repository `gitops/dashboards`. Lab-only user `gitops`, password `gitops-password`.
- The pod **`dac-runner`** in the namespace `dac`, with `percli` v0.54.0, `cue` v0.17.1 and Go 1.26.5. It keeps a copy of `main` in `/work/dashboards` and resets it before every command.

## Helpers

Paste these once in each new terminal. `dac` runs a command in the runner, in an up-to-date copy of `main`. `show_dashboard` prints the group titles and panel names of a dashboard as the Perses API serves it.

```sh
dac() { kubectl -n dac exec -i deploy/dac-runner -- dac-run "$@"; }
show_dashboard() {
  dac sh -c "curl -s http://perses.localtest.me:8080/api/v1/projects/inventory/dashboards/$1 \
    | jq '{groups: [.spec.layouts[].spec.display.title], panels: [.spec.panels[].spec.display.name]}'"
}
```

Use them like this: `dac percli get dashboards`, `show_dashboard prometheus-storage`.

To clone the repository, start `kubectl -n gitea port-forward svc/gitea-http 3000:3000` in a second terminal, then run `git clone http://gitops:gitops-password@gitea.localtest.me:3000/gitops/dashboards.git`. To see dashboards in a browser, start `kubectl -n perses port-forward svc/perses 8080:8080` and open `http://perses.localtest.me:8080`.

## Practice tasks

- Build every dashboard with `dac percli dac build -d dashboards -ojson`, then list the results with `dac find built -type f`. Predict each output file name before you look.
- Build `dashboards/go/storage/main.go` with `-m stdout` and compare it with `dac percli describe dashboard prometheus-storage -ojson`.
- Change a panel title in the browser, then run `percli dac diff` on the built storage dashboard and read the diff file. Apply the built file again and run the diff once more.
- Change a query in your clone, but do not push it. Build in the runner and check whether your change is in the result. Then push and build again.
- In the runner, try `percli dac setup` in an empty folder: `dac sh -c 'mkdir -p /tmp/new && cd /tmp/new && cue mod init example.com/new && percli dac setup --version 0.54.0 && ls'`.
