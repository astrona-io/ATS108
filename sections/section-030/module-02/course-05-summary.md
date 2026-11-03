# Summary

A Go builder option is a value. `AddPanel` returns a `panelgroup.Option` and `AddPanelGroup` returns a `dashboard.Option`, so a function can return either one, and the compiler checks that the right type goes into the right place. A function such as `JobGroup(job)` turns a repeated block into one call.

A dashboard program collects options in a slice, appends one option per item of a list in a loop, and passes the slice to `dashboard.New` with three dots after its name. The list is then the only part that changes when a job is added. Standard output stays reserved for the dashboard, and any debug text goes to standard error.

A table-driven test runs the same checks for each case of a list, and `t.Run` names each case. After a successful build, the builder holds the dashboard in its field `Dashboard`, so a test counts panels and layouts without calling a server. Tests live in the library package, never next to a dashboard program.

CUE and Go produce the same Perses resource. CUE checks values against schemas while it evaluates. Go checks types when it compiles and gives loops, functions and tests. To move a dashboard between them, build both, compare group titles, panel names, plugin kinds and queries, then apply the new one.

- Keep logic in the library package and keep dashboard programs short.
- Pass option slices with `options...`.
- Test counts and queries, not only the absence of an error.

<!-- astrona:playground:destroy -->
