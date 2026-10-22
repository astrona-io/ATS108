# Question

Solve this question on: `terminal`

**Time:** about 30 minutes · **Topic:** The Go SDK

## Scenario

The team behind `team-overview` is moving all its dashboards from CUE to Go, so it can test them with its usual tools. The CUE file `dashboards/cue/team-overview.cue` stays for now; the Go version must build the same dashboard under a new name, so both can be compared on the server.

## Your task

Write the Go program `dashboards/go/team-overview-go/main.go`, push it to `main`, build it and apply it. It must build:

| Field | Value |
| --- | --- |
| Name | `team-overview-go` |
| Project | `inventory` |
| Title (display name) | `Team Overview (Go)` |
| Everything else | The same variable, panel groups, panels, plugin kinds and queries as `dashboards/cue/team-overview.cue` |

Run every `percli` and `go` command in the runner with this helper:

```sh
dac() { kubectl -n dac exec -i deploy/dac-runner -- dac-run "$@"; }
```

## Constraints

- Use the shared functions in `example.com/dashboards/lib/boards` for every panel. Do not write a `query.PromQL` call in `main.go`.
- Do not change `dashboards/cue/team-overview.cue` or `lib/boards`.
- Keep the CUE dashboard `team-overview` on the server.

## Done when

- `dashboards/go/team-overview-go/main.go` builds the dashboard `team-overview-go` with the title `Team Overview (Go)`.
- Its variable, groups, panels, plugin kinds and queries are the same as what `dashboards/cue/team-overview.cue` builds.
- The server holds exactly what both files build.
