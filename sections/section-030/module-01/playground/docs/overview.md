# Overview: Write Dashboards In Go (Playground)

This is a **playground**, not a lab. It starts a fresh cluster with Perses, Prometheus, a Git server and a build pod, pushes a repository of dashboards as code, and waits. There is no task, no `astrona submit` and no pass or fail. Explore, break things, `astrona destroy`, start over.

## What's in the box

- A single-node `kind` Kubernetes cluster. `kubectl` is already pointed at it.
- **Perses v0.54.0** in the namespace `perses`, with the project `inventory` and its datasource `prometheus`. The dashboard `prometheus-storage` is already applied from `dashboards/go/storage/main.go`.
- **Prometheus** in the namespace `observability`, with the scrape jobs `prometheus` and `perses`.
- **Gitea** in the namespace `gitea`, with the repository `gitops/dashboards` (lab-only user `gitops`, password `gitops-password`).
- The pod **`dac-runner`** in the namespace `dac`, with Go 1.26.5, `percli` v0.54.0 and `cue` v0.17.1, and the Go modules already downloaded.

The repository holds the Go module (`go.mod`, `go.sum`), the library package `lib/boards` with `TargetsUp`, `SamplesAppended`, `HeadSeries` and `PromQuery` and a test, and the Go dashboard `dashboards/go/storage/main.go`.

## Helpers

Paste these once in each new terminal. `dac` runs a command in the runner, in an up-to-date copy of `main`. `build_go` builds one Go dashboard folder and prints the result as JSON.

```sh
dac() { kubectl -n dac exec -i deploy/dac-runner -- dac-run "$@"; }
build_go() { dac percli dac build -f "dashboards/go/$1/main.go" -ojson -m stdout; }
```

Use them like this: `build_go storage | jq '.spec.panels | keys'`, `dac go test ./lib/...`. To clone, start `kubectl -n gitea port-forward svc/gitea-http 3000:3000` in a second terminal and run `git clone http://gitops:gitops-password@gitea.localtest.me:3000/gitops/dashboards.git`.

## Practice tasks

- Add `fmt.Println("hello")` to the storage dashboard, push, and build it. Compare the build report with what `jq` says about the output.
- Write a function in `lib/boards` that returns one panel group per job from a list, and use it in a new dashboard.
- Pass an argument to a Go dashboard: read a flag in `main.go` and build with `percli dac build -f ... -- --flagname=value`.
- Put a `main_test.go` next to `dashboards/go/storage/main.go`, push, and run `percli dac build -d dashboards`. Read why it fails, then move the test into `lib/boards`.
- Build the storage dashboard as YAML (`-oyaml`) and compare it with the JSON.
