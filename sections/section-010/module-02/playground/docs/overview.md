# Overview: Prepare A Repository And Control Where Dashboards Go (Playground)

This is a **playground**, not a lab. It starts a fresh cluster with Perses, Prometheus, a Git server and a build pod, pushes a repository of dashboards as code, and waits. There is no task, no `astrona submit` and no pass or fail. Explore, break things, `astrona destroy`, start over.

## What's in the box

- A single-node `kind` Kubernetes cluster. `kubectl` is already pointed at it.
- **Perses v0.54.0** in the namespace `perses`, with the project `inventory` and its datasource `prometheus`.
- **Prometheus** in the namespace `observability`, with the scrape jobs `prometheus` and `perses`.
- **Gitea** in the namespace `gitea`, with the repository `gitops/dashboards` (lab-only user `gitops`, password `gitops-password`).
- The pod **`dac-runner`** in the namespace `dac`, with `percli` v0.54.0, `cue` v0.17.1 and Go 1.26.5. It builds what is pushed to `main`.

## Helpers

Paste this once in each new terminal. `dac` runs a command in the runner, in an up-to-date copy of `main`.

```sh
dac() { kubectl -n dac exec -i deploy/dac-runner -- dac-run "$@"; }
```

## Practice tasks

- Create a scratch CUE module in `/tmp` inside the runner with `cue mod init`, run `percli dac setup`, and read the dependencies it recorded in `cue.mod/module.cue`.
- Do the same for a Go module with `go mod init` and `percli dac setup --language go`.
- Build one dashboard as JSON and as YAML, and list the `built` folder.
- Build the whole `dashboards` folder, then predict the path of each result before you list them.
- Change `#project` in a CUE dashboard to a name that does not exist, push, and read what `percli apply` says.
