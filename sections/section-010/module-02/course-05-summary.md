# Summary

A DaC repository is a CUE module, a Go module, or both. A CUE module is created with `cue mod init`, and `percli dac setup` writes an example and runs `cue mod tidy`, which records the Perses modules and their versions in `cue.mod/module.cue`. A Go module is created with `go mod init`, and `percli dac setup --language go` writes an example program and runs `go get` for the Perses module. Plugin modules are added one by one at the versions that ship with the server. The version of the SDK comes from the server, or from `--version` when no server is connected.

The build options choose the input, the format and the destination. `-f` builds one file and `-d` builds a folder, with each CUE file on its own and every Go file of package `main`. `-o` selects JSON or YAML. Results go to `built/<source path>_output.<format>`, or to standard output with `-m stdout`. Arguments after a double dash go to Go programs. Old files in `built` stay there until the folder is removed.

A dashboard belongs to the project in its `metadata.project`, which the CUE builder sets from `#project` and the Go SDK from `dashboard.ProjectName`. `percli apply` refuses a resource whose project differs from the selected project. `--force` and `--create-project` get past the refusal but leave the mistake in the code. The fix is a change in the source, pushed to `main`, built and applied again.

- Commit the module files and `go.sum`; never commit `built`.
- Match the SDK and plugin versions to the server.
- Fix a wrong project in the code, not with a flag.

<!-- astrona:playground:destroy -->
