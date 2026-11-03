# Checking CUE With The CUE Tools

`percli dac build` is the final check, but it is slow to run for every change, and it hides CUE's own tools behind one command. The `cue` program has commands that format, check and print values. They run in seconds and tell you what a value is at a specific place. This part uses four of them in the runner.

## Format

`cue fmt` rewrites a file in the standard layout. Check which files would change without writing them by running it on a copy:

<!-- astrona:playground:renew -->

```sh
dac() { kubectl -n dac exec -i deploy/dac-runner -- dac-run "$@"; }
dac sh -c 'cp lib/panels/panels.cue /tmp/p.cue && cue fmt /tmp/p.cue && diff lib/panels/panels.cue /tmp/p.cue && echo formatted'
```

No difference means the file is already in the standard layout. Format before each commit, so reviews show only real changes.

## Vet

`cue vet` checks that a file evaluates without errors. With `-c` (short for `--concrete`) it also requires every value to be final:

```sh
dac cue vet -c dashboards/cue/prometheus-overview.cue
```

The command prints nothing and exits with code 0 when the file is valid. A shared package is checked with `cue vet ./lib/panels` the same way, without `-c`, because definitions are not concrete.

## Eval an expression

The option `-e` evaluates one expression instead of the whole file. This is the fastest way to look at one value:

```sh
dac cue eval dashboards/cue/prometheus-overview.cue -e spec.display --concrete
```

The output shows the dashboard's `display` field only. When a large dashboard builds wrongly, pick the field that looks wrong and print it.

## Export

`cue export` produces JSON or YAML like the build does, and the option `--out yaml` picks the format. It is the command `percli` runs underneath, so its errors are the build's errors:

```sh
dac sh -c 'cue export dashboards/cue/prometheus-overview.cue --out json | jq ".metadata"'
```

Use `percli dac build` when you want the output in the `built` folder, and `cue export` when you want to understand an error.

You now know four tools that check CUE in seconds: `cue fmt`, `cue vet`, `cue eval -e` and `cue export`. The open question is how a pipeline can run them on every commit.

## Common pitfalls

> [!WARNING]
> - **Running `cue vet` without `-c` on a dashboard.** It passes while fields are still undecided.
> - **Evaluating a file that imports the main module from outside the repository.** Run `cue` in the repository folder, as the runner does.
> - **Ignoring formatting.** Unformatted files make reviews noisy.
