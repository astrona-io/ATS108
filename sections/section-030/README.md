# Section 030: The Go SDK

Some teams already write Go every day. For them, a dashboard as a Go program is natural: a function returns a panel, a loop adds one panel group per service, and a test proves the result before anything reaches the server. The Perses Go software development kit (SDK) builds the same dashboard JSON as the CUE SDK, from function calls.

This section teaches the Go side of Dashboard-as-Code: the module and the convention `percli dac build` relies on, the builders for dashboards, panel groups, panels, queries and variables, and shared functions with tests.

## What you will learn

- The Go module of a DaC repository, and what `percli dac setup --language go` prepares.
- The exec convention: `sdk.NewExec()`, the `--output` flag, and `exec.BuildDashboard`.
- The dashboard, panel group, panel, query and variable builders, and the plugin packages that provide charts and queries.
- Shared functions in a library package, Go tests for them, and why tests never sit next to a `main.go` that `percli` builds.

## The learning path

The module has a landing page, three short parts, a graded lab right after the part it tests, and a summary. The landing page starts the module's playground, where the dashboard `prometheus-storage` is already applied from Go.

### 1. Write Dashboards In Go

1. A Go Module For Dashboards
2. Dashboards, Panel Groups, Panels And Queries In Go
3. Reusable Functions And Tests, followed by the lab **Port A CUE Dashboard To The Go SDK**
4. Summary

## Section capstone: Generate A Dashboard Per Job

A Go program should build one panel group per Prometheus scrape job, from a shared function. Its output breaks every build, and its tests fail. The capstone asks you to find both faults, fix the code without touching the test, and put the dashboard on the server. Work it after the module lab.

Start the capstone:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS108.git -c sections/section-030/capstone/labs/lab-01
```

When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-030/capstone/labs/lab-01
```

When the capstone is done, remove it:

```sh
astrona destroy ats-108-capstone-030
```
