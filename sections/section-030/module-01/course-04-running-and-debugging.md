# Running And Debugging A Dashboard Program

A Go dashboard is a program, so you can run it, read its output and its errors, and check it before `percli` ever sees it. That shortens the loop when a build fails. This part runs the storage dashboard by hand in the formats the SDK supports, shows where output and errors go, and checks the library code with the Go tools.

## Run the program yourself

`percli dac build` runs `go run` on the file from its folder. Run the same command in the runner and read the start of the output:

<!-- astrona:playground:renew -->

```sh
dac() { kubectl -n dac exec -i deploy/dac-runner -- dac-run "$@"; }
dac sh -c 'cd dashboards/go/storage && go run main.go --output yaml | head -8'
```

The program prints the dashboard as YAML, because the `--output` flag accepts `yaml` or `json`. The first lines show `kind: Dashboard` and the `metadata`. `percli dac build -ojson` passes `--output json` to the same program, so both formats come from one source.

## Standard output and standard error

The program has two output streams. Standard output carries the dashboard. Standard error carries messages about problems. `exec.BuildDashboard` writes a builder error to standard error and exits with a non-zero code. Separate the two streams to see this:

```sh
dac sh -c 'cd dashboards/go/storage && go run main.go --output json 2>/tmp/errors.txt | jq -r ".metadata.name"; wc -c < /tmp/errors.txt'
```

The name is `prometheus-storage`, and the error file holds zero bytes, because nothing went wrong. If a program prints a debug line to standard output, that line becomes part of the dashboard text and breaks it. A debug line sent to standard error is safe, because `percli` does not read it as the dashboard.

## Compile errors and vet

A typo in a function name fails before the program runs. `go vet` finds many such problems, and some suspicious code that compiles, without running anything. Check the library package:

```sh
dac go vet ./lib/...
```

The command prints nothing when it finds nothing. Run the build check for the dashboard programs too, which compiles each one without running it:

```sh
dac go build -o /dev/null ./dashboards/go/storage
```

An error here names a file, a line and the identifier Go could not resolve. `percli dac build` shows the same text when it fails on a Go file.

## Extra arguments

Everything after `--` in a `percli dac build` command goes to the Go program. A program can read it with Go's `flag` package, for example to pick a project. The SDK registers only `--output`; any other flag the program reads must be declared before `flag.Parse()` runs, or the program fails with an unknown flag error.

You now know how to run a dashboard program in both formats, which stream carries what, and how to catch compile problems early. The open question is how to share code between many dashboard programs.

## Common pitfalls

> [!WARNING]
> - **Printing progress text with `fmt.Println`.** It lands in the dashboard. Use standard error.
> - **Running `go run` from the repository root.** `percli` runs it from the file's folder; relative paths in the program resolve from there.
> - **Passing a flag the program does not declare.** `flag.Parse()` stops with an error.
