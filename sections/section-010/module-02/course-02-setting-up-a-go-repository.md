# Setting Up A Go Repository

A Go dashboard is a program, so it needs a Go module with the Perses packages as dependencies. The setup follows the same idea as for CUE, with the Go tools doing the dependency work. This part creates a Go module from nothing, prepares it with `percli dac setup --language go`, and builds the example program.

## Create the module

A Go module is a folder with a file `go.mod`. The command `go mod init` creates it and takes the module path. Make a scratch folder in the runner:

<!-- astrona:playground:renew -->

```sh
dac() { kubectl -n dac exec -i deploy/dac-runner -- dac-run "$@"; }
dac sh -c 'rm -rf /tmp/newgo && mkdir /tmp/newgo && cd /tmp/newgo && go mod init example.com/newgo && cat go.mod'
```

The file holds the module path and the Go version of the tool that created it. It has no `require` lines yet.

## Let percli prepare the module

The command `percli dac setup --language go` needs the `go.mod` file. It writes an example program, `main.go`, and then runs `go get github.com/perses/perses@<version>`. The command `go get` downloads the Perses module at that version, adds it to `go.mod` and writes the checksums to `go.sum`. As for CUE, the version comes from the server, or from `--version`:

```sh
dac sh -c 'cd /tmp/newgo && percli dac setup --language go && cat go.mod && ls'
```

The `go.mod` file now requires `github.com/perses/perses`, and the folder holds `main.go`, `go.sum` and the example.

## Add plugin modules

The SDK module holds the dashboard, panel group, panel and variable builders. The chart and query options live in the plugin modules, each with its own version. A program that uses a Stat chart or a Prometheus query needs those modules. Add the Stat chart module at the version that ships with Perses v0.54.0:

```sh
dac sh -c 'cd /tmp/newgo && go get github.com/perses/plugins/statchart@v0.13.0 && grep statchart go.mod'
```

The line `github.com/perses/plugins/statchart v0.13.0` appears in `go.mod`. Pinning the plugin versions that ship with the server keeps the program and the server in agreement about each plugin's fields.

## Build the example

Build the example program to prove the setup:

```sh
dac sh -c 'cd /tmp/newgo && percli dac build -f main.go -ojson -m stdout | jq ".kind"'
```

The result is `"Dashboard"`. The build ran `go run main.go --output json` from the file's folder, and the SDK wrote the dashboard to standard output.

You now know how a Go repository is prepared: `go mod init`, then `percli dac setup --language go`, then one `go get` per plugin. Commit `go.mod` and `go.sum` together. The open question is how the build options change what a build reads and writes.

## Common pitfalls

> [!WARNING]
> - **Committing `go.mod` without `go.sum`.** The checksums are what make the download repeatable.
> - **Forgetting a plugin module.** A program that imports a plugin package fails to compile until `go get` adds the module.
> - **Letting `go get` choose the latest plugin version.** Use the version that ships with your Perses server.
