# Summary

A Go dashboard is a program in package `main` that builds a dashboard with the Perses Go SDK and prints it. The repository's Go module pins `github.com/perses/perses` at the server's version and each plugin module at the version that ships with it. In a new repository, `percli dac setup --language go` writes an example program and runs `go get` for the SDK, and you add each plugin module yourself.

Every program follows the exec convention. It calls `flag.Parse()` and `sdk.NewExec()`, which reads the `--output` flag, builds the dashboard, and ends with `exec.BuildDashboard`, which prints the dashboard or the builder's error. `percli dac build` runs `go run <file> --output <format>` from the file's folder and takes standard output as the dashboard. That is why a program must print nothing else, why each Go dashboard has its own folder, and why test files never sit in package `main` under the folders `percli` builds.

The builders take a name and options. The `dashboard`, `panelgroup` and `panel` packages provide the structure, and each plugin's `sdk/go` package provides charts, queries and variables. A failing option makes the builder return an error, which `percli` reports as a failed file. Shared panels are functions in a library package that return options, so loops can build one group per job and `go test` can check queries through the builder's `Dashboard` field. The key facts to remember are these:

- Only the dashboard goes to standard output.
- One Go dashboard per folder; the built file is `main_output.json` in that folder under `built`.
- Plugin module versions must match the plugins of the Perses server.
- Test shared code in a library package, not next to a `main.go`.

<!-- astrona:playground:destroy -->
