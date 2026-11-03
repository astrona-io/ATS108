# Question

Solve this question on: `terminal`

**Time:** about 20 minutes · **Topic:** Projects and the apply command

## Scenario

The release team pushed a new dashboard, `release-health`, to `gitops/dashboards`. The file `dashboards/cue/release-health.cue` names a project that does not exist on the Perses server. The team wants the dashboard in the project `inventory`, together with the other dashboards of the service.

## Your task

Make the dashboard `release-health` exist in the project `inventory`, built from the code at the head of `main`.

Run every `percli` command in the runner with this helper:

```sh
dac() { kubectl -n dac exec -i deploy/dac-runner -- dac-run "$@"; }
```

## Constraints

- Change the dashboard only through a Git commit on `main`.
- Do not create any new project on the Perses server.
- Do not use `--force` to apply a dashboard into a project it does not name.

## Done when

- `dashboards/cue/release-health.cue` on `main` builds a dashboard whose project is `inventory`.
- The server holds the dashboard `release-health` in the project `inventory`, exactly as the code builds it.
- The server has no project called `staging`.
