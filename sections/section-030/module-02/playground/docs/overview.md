# Overview: Reusable Go Dashboards (Playground)

This is a **playground**, not a lab. It starts a fresh cluster with Perses, Prometheus, a Git server and a build pod, pushes a repository of dashboards as code, and waits. There is no task, no `astrona submit` and no pass or fail. Explore, break things, `astrona destroy`, start over.

## What's in the box

- A single-node `kind` Kubernetes cluster. `kubectl` is already pointed at it.
- **Perses v0.54.0** in the namespace `perses`, with the project `inventory` and its datasource `prometheus`.
- **Prometheus** in the namespace `observability`, with the scrape jobs `prometheus` and `perses`.
- **Gitea** in the namespace `gitea`, with the repository `gitops/dashboards` (lab-only user `gitops`, password `gitops-password`).
- The pod **`dac-runner`** in the namespace `dac`, with `percli` v0.54.0, `cue` v0.17.1 and Go 1.26.5. It builds what is pushed to `main`.

The repository holds a Go module, the library package `lib/boards` with its test, and the Go dashboard `dashboards/go/storage/main.go`.

## Helpers

Paste this once in each new terminal. `dac` runs a command in the runner, in an up-to-date copy of `main`.

```sh
dac() { kubectl -n dac exec -i deploy/dac-runner -- dac-run "$@"; }
```

To clone, start `kubectl -n gitea port-forward svc/gitea-http 3000:3000` in a second terminal and run `git clone http://gitops:gitops-password@gitea.localtest.me:3000/gitops/dashboards.git`.

## Practice tasks

- Add a function that returns a `panelgroup.Option` and use it in a new dashboard program.
- Build a dashboard from a slice of options and add a third job to the list.
- Write a table-driven test with `t.Run` and make one case fail on purpose to read the report.
- Print a debug line with `fmt.Println` in a dashboard program, build it, and read the error. Then send the line to standard error.
- Run `go vet ./lib/...` after a change to the library.
