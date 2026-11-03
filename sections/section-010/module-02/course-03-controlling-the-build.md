# Controlling The Build

The same source can be built in different ways: one file or a whole folder, JSON or YAML, written to a file or printed. The options decide what happens, and knowing them lets you use the build in scripts and reviews. This part tries each option on the overview dashboard.

## One file or a folder

The option `-f` builds one file. The option `-d` builds a folder, and walks it. Build one CUE file, then the whole `dashboards` folder:

<!-- astrona:playground:renew -->

```sh
dac() { kubectl -n dac exec -i deploy/dac-runner -- dac-run "$@"; }
dac percli dac build -f dashboards/cue/prometheus-overview.cue -ojson
dac percli dac build -d dashboards -ojson
```

The first command builds one dashboard. The second evaluates each CUE file on its own and runs every Go file of package `main`. It skips `.git`, `.github`, `.idea`, `built` and `cue.mod`. If one file fails, the others still build, and the command lists the failures at the end and exits with an error.

## The path of the result

Without `-m stdout`, the result goes to the folder `built`. The path is the source path without its extension, plus `_output` and the format. List the results:

```sh
dac sh -c 'find built -type f | sort'
```

The CUE file `dashboards/cue/prometheus-overview.cue` gives `built/dashboards/cue/prometheus-overview_output.json`. The Go file `dashboards/go/storage/main.go` gives `built/dashboards/go/storage/main_output.json`. Because the folder structure is kept, two dashboards with the same file name in different folders never collide.

## JSON or YAML

The option `-o` selects the format, `json` or `yaml`. The file extension follows the format. Build the same file as YAML and list the folder:

```sh
dac sh -c 'percli dac build -f dashboards/cue/prometheus-overview.cue -oyaml && ls built/dashboards/cue'
```

Both the JSON and the YAML files exist now, side by side. `percli apply -d built` applies every file it finds in the folder. Two files of the same dashboard in two formats apply the same resource twice, which is harmless but noisy. Build one format per pipeline.

## Print instead of write

The option `-m` selects the mode. With `-m stdout`, the build prints the dashboard and writes no file. This suits pipes into `jq` and quick checks:

```sh
dac sh -c 'percli dac build -f dashboards/cue/prometheus-overview.cue -ojson -m stdout | jq ".metadata.name"'
```

## Arguments for Go programs

Everything after a double dash goes to the Go program. A program that declares its own flag reads it from there. The SDK itself only declares `--output`, which `percli` sets from `-o`.

You now know how to choose the input, the format and the destination of a build. The open question is what happens to a built file when it is applied to a project.

## Common pitfalls

> [!WARNING]
> - **Leaving old files in `built`.** A dashboard you deleted from the source stays in `built` until you remove the folder, and `percli apply -d built` applies it again. Pipelines start from a clean folder.
> - **Building a folder that holds a Go test file in package `main`.** `go run` refuses it, and the build reports a failure.
> - **Expecting `-m stdout` to work for a whole folder.** Use it with one file, because several dashboards would print into one stream.
