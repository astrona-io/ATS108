# Options As Building Blocks

The Go SDK builds a dashboard by applying options to a builder. A call such as `dashboard.AddPanelGroup(...)` does not change anything when you write it. It returns an option, and `dashboard.New` applies the option later. That is why you can put a call in a function, a variable or a slice. This part reads the two option types in the library and writes a function that returns a whole panel group.

## Two option types

The library functions `TargetsUp`, `SamplesAppended` and `HeadSeries` return `panelgroup.Option`. A panel group option adds one panel to a group. The call `dashboard.AddPanelGroup(title, ...)` takes panel group options and returns a `dashboard.Option`, which adds a whole group to a dashboard. Read the signatures in the library:

<!-- astrona:playground:renew -->

```sh
dac() { kubectl -n dac exec -i deploy/dac-runner -- dac-run "$@"; }
dac sh -c 'grep -n "^func" lib/boards/boards.go'
```

Every function in the list takes a `job string` and returns `panelgroup.Option`, except `PromQuery`, which returns a `panel.Option`. The Go compiler checks the types: you cannot pass a `dashboard.Option` where a panel group expects a `panelgroup.Option`.

## A function that returns a group

A dashboard with three jobs would repeat the same `AddPanelGroup` call three times. A function removes the repetition. In your clone of the repository (start the Gitea port-forward in a second terminal first, with `kubectl -n gitea port-forward svc/gitea-http 3000:3000`), add this function at the end of `lib/boards/boards.go`:

```sh
git clone http://gitops:gitops-password@gitea.localtest.me:3000/gitops/dashboards.git
cd dashboards
```

```go
// JobGroup is a panel group named after a job, with the job's two main panels.
func JobGroup(job string) dashboard.Option {
	return dashboard.AddPanelGroup(job,
		panelgroup.PanelsPerLine(2),
		TargetsUp(job),
		SamplesAppended(job),
	)
}
```

The file needs one more import, `"github.com/perses/perses/go-sdk/dashboard"`, in the import block next to the other `go-sdk` packages. The function returns a `dashboard.Option`, so a dashboard program uses it like any other option: `dashboard.New("x", boards.JobGroup("perses"))`.

## Check that it compiles

Push the change and ask Go to vet the library:

```sh
git commit -am "Add JobGroup" && git push
dac go vet ./lib/...
```

The command prints nothing when the package compiles and has no suspicious code. A compile error names the file and line, and usually says that a type does not match: the most likely cause is the missing import or an option of the wrong type.

You now know that options are values with types, and how to write a function that returns a group. The open question is how to use such a function for a list of jobs.

## Common pitfalls

> [!WARNING]
> - **Returning the wrong option type.** `AddPanelGroup` returns `dashboard.Option`; `AddPanel` returns `panelgroup.Option`.
> - **Forgetting the import.** The function uses the `dashboard` package, so the library file must import it.
> - **Putting the function in package main.** Library code belongs in `lib/boards`, where tests can live.
