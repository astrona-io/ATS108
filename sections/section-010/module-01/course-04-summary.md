# Summary

A Perses dashboard is a JSON resource with a `kind`, `metadata` and a `spec` that holds panels, layouts, queries and variables. Dashboard-as-Code keeps the source of that resource in Git. Every change becomes a commit that can be reviewed and reverted, and shared panels are written once instead of copied.

Perses offers two software development kits that produce the same JSON. The CUE SDK writes dashboards as configuration that schemas check at build time. The Go SDK writes them as programs that call builder functions, which suits loops and tests. A repository can hold both.

A DaC repository has a CUE module (`cue.mod/module.cue`), a Go module (`go.mod`, `go.sum`), shared code under `lib`, and one dashboard per CUE file or per Go folder. `percli dac setup` prepares a new repository for either language and adds `built` to `.gitignore`. `percli dac build` runs `cue eval --concrete` on a CUE file and `go run` on a Go file, and writes `built/<path>_output.json`. With `-d` it builds each file on its own and reports every failure at the end.

`percli apply` creates or updates resources from the built files, in the project named in each resource's metadata. `percli dac diff` compares the `spec` of each built dashboard with the server and writes a diff file per dashboard. A difference that does not come from the code is drift, and the fix for drift is a change in the code, not another edit in the browser. The key facts to remember are these:

- The runner builds what is pushed to `main`; push before you build.
- Build and apply in one step, so the applied file is the one you just built.
- `percli dac diff` reports a dashboard missing on the server as new, without a diff file.
- One Go dashboard per folder, and no test files next to a `main.go`.

<!-- astrona:playground:destroy -->
