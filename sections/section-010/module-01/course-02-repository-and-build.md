# The Repository And The Build

A DaC repository is not just a folder of files. `percli dac build` expects a CUE module and a Go module at the root, and it treats each dashboard file in a specific way. This part clones the repository, walks through its layout, and builds a dashboard into the `built` folder, so you know where every file comes from and where every result goes.

## Clone the repository

The Git server runs inside the cluster. Your machine reaches it through a port-forward, and the address `http://gitea.localtest.me:3000` points at your own machine, so the same address works on your machine and inside the cluster. In a second terminal, start the port-forward and leave it running:

<!-- astrona:playground:renew -->

```sh
kubectl -n gitea port-forward svc/gitea-http 3000:3000
```

Back in your first terminal, clone the repository with the lab-only user `gitops` and the password `gitops-password`. If the name `gitea.localtest.me` does not resolve, add `127.0.0.1 gitea.localtest.me` to `/etc/hosts`.

```sh
git clone http://gitops:gitops-password@gitea.localtest.me:3000/gitops/dashboards.git
cd dashboards
find . -path ./.git -prune -o -type f -print | sort
```

The list shows a small, fixed layout. Each path has one job:

| Path | What it holds |
| --- | --- |
| `cue.mod/module.cue` | The CUE module `example.com/dashboards@v0` and the exact versions of the Perses CUE modules it depends on |
| `go.mod`, `go.sum` | The Go module `example.com/dashboards` and the exact versions of the Perses Go modules |
| `lib/panels/` | Panels the CUE dashboards share |
| `lib/boards/` | Functions the Go dashboards share, and their tests |
| `dashboards/cue/` | One CUE dashboard per file |
| `dashboards/go/<name>/main.go` | One Go dashboard per folder |
| `.gitignore` | Keeps the `built` folder out of Git |

## What percli dac setup prepares

You did not have to create the module files: they are part of the repository. In a new repository, `percli dac setup` prepares them for you. For CUE, you first run `cue mod init <module name>`. Then `percli dac setup` writes an example file and runs `cue mod tidy`, which downloads the Perses CUE modules and records their versions. For Go, you first run `go mod init <module name>`. Then `percli dac setup --language go` writes an example `main.go` and runs `go get github.com/perses/perses@<version>`.

The command asks the Perses server for its version, so the SDK matches the server. Without a server connection you pass `--version 0.54.0` yourself. It also adds `built` to an existing `.gitignore`, because built files are results, not source.

## Build one dashboard

The runner does the building. Its copy of the repository is reset to `main` on Gitea before every command, so it only sees what you pushed; a change on your machine that you did not push does not exist for it. Build the overview dashboard, a CUE file:

```sh
dac percli dac build -f dashboards/cue/prometheus-overview.cue -ojson
```

The command reports that it built the file and names the output: `built/dashboards/cue/prometheus-overview_output.json`. `percli` ran `cue eval` on the file, with JSON output and the `--concrete` flag, which fails if any value is still undecided. The name of the output file is the source path with `_output` and the format added, under `built`.

Read the result to see what the build produced:

```sh
dac sh -c 'percli dac build -f dashboards/cue/prometheus-overview.cue -ojson -m stdout | jq ".metadata, [.spec.layouts[].spec.display.title]"'
```

With `-m stdout`, `percli` prints the dashboard instead of writing a file, which is handy in a pipe. The metadata names the dashboard `prometheus-overview` in the project `inventory`, and the dashboard has two panel groups, `Scrape health` and `Storage`.

## Build the whole folder

One file at a time is fine while you work. Before you apply, build everything:

```sh
dac percli dac build -d dashboards -ojson
```

With `-d`, `percli` walks the folder. It evaluates **each CUE file on its own**, so two CUE files cannot share values except through an imported package. It runs **every Go file of package `main`** with `go run`, from that file's folder. It skips `built`, `cue.mod` and `.git`. If any file fails, it builds the others, lists the failures at the end, and exits with an error.

You now know where each part of a DaC repository lives and what the build does with it. The dashboards exist only as files in the runner. The open question is how they reach the server, and how you check that the server holds what the code says.

## Common pitfalls

> [!WARNING]
> - **Building before pushing.** The runner builds `main` on Gitea. Commit and push first, or the build shows the old version.
> - **Two Go dashboards in one folder.** `percli dac build -d` runs every `main` file with `go run` from its folder; two `main` packages in one folder do not build together. Give each Go dashboard its own folder.
> - **A Go test file next to a `main.go`.** A `_test.go` file in package `main` is a Go file of package `main`, so `percli dac build -d` tries to `go run` it, and `go run` refuses test files. Keep tests in a library package.
> - **Committing the `built` folder.** It is a result of the build. Commit the source; build in the pipeline.
