# A Go Module For Dashboards

A Go dashboard is not a library that Perses loads. It is a small program that runs once and prints a dashboard. To make that work, the repository needs a Go module with the Perses packages, and every dashboard program needs to follow the same short convention. This part looks at both, and at what `percli dac build` does with a Go file.

## The module

The repository's Go module is defined in two files at its root. Look at the first one:

<!-- astrona:playground:renew -->

```sh
dac() { kubectl -n dac exec -i deploy/dac-runner -- dac-run "$@"; }
dac cat go.mod
```

The module is called `example.com/dashboards`, with `go 1.26.5`, the Go version the Perses v0.54.0 packages require. It requires four modules, each at an exact version: `github.com/perses/perses` at `v0.54.0` for the SDK itself, and three plugin modules, `github.com/perses/plugins/prometheus` at `v0.58.0`, `.../statchart` at `v0.13.0` and `.../timeserieschart` at `v0.13.0`. Those are the plugin versions that ship with Perses v0.54.0, so the code and the server agree on every plugin's fields. `go.sum` holds the checksums Go verifies when it downloads them.

In a new repository, `percli dac setup --language go` prepares this for you, after `go mod init <module name>`. It writes an example `main.go` and runs `go get github.com/perses/perses@<version>`, with the version of the Perses server it is logged in to, or the one you give with `--version`. You add each plugin module yourself with `go get`, for every plugin your dashboards use.

## The exec convention

Every Go dashboard follows the same pattern. Read the storage dashboard:

```sh
dac cat dashboards/go/storage/main.go
```

The program is in package `main`. It starts with `flag.Parse()`, then `exec := sdk.NewExec()`, then builds the dashboard with `dashboard.New(...)`, and ends with `exec.BuildDashboard(builder, buildErr)`. `sdk.NewExec()` reads the `--output` flag, which the SDK registers; its value is `yaml` or `json`. `exec.BuildDashboard` writes the dashboard to standard output in that format. If the builder returned an error, it writes the error to standard error and exits with a non-zero code instead.

That is exactly what `percli dac build` needs. For a `.go` file, it runs `go run <file> --output <format>` from the file's folder, and takes standard output as the dashboard. Run the program yourself the way `percli` does:

```sh
dac sh -c 'cd dashboards/go/storage && go run main.go --output json | jq ".metadata.name"'
```

The program prints the dashboard, and `jq` reads its name: `prometheus-storage`. Without `--output`, the program prints YAML, which is the SDK's default.

## Only the dashboard on standard output

Because `percli` takes everything the program prints as the dashboard, one debug line breaks it. A `fmt.Println("building...")` before `exec.BuildDashboard` puts that text in front of the JSON. `go run` still succeeds, so `percli dac build` writes the file, but the file is no longer valid JSON, and `percli apply` and every other reader fail on it. If a program must report something, it writes to standard error, which `percli` does not collect.

The same rule explains the folder layout. `percli dac build -d` runs every Go file of package `main` it finds. Two dashboard programs in one folder would be one `main` package with two `main` functions, so each Go dashboard gets its own folder. A Go test file in package `main` would also be picked up and passed to `go run`, which refuses test files, so tests live in a library package outside `dashboards`.

You now know what the Go module holds and the convention every dashboard program follows. The open question is how to build the dashboard itself with the SDK.

## Common pitfalls

> [!WARNING]
> - **Printing to standard output.** Anything but the dashboard ends up in the built file. Log to standard error, or not at all.
> - **Two dashboards in one folder.** They form one `main` package that does not compile. One folder per dashboard.
> - **A plugin module missing from `go.mod`.** The program does not compile. Add each plugin with `go get` at the version that matches the server.
