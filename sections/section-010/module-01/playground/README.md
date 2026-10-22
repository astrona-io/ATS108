# Build And Apply Your First Dashboard As Code — Playground

- **ID:** PLAYGROUND
- **Slug:** ats-108-playground-010-01
- **Author:** Paris Nakita Kejser
- **Type:** Astrona playground — no task, no grading

A sandbox that starts Perses v0.54.0, Prometheus, Gitea with the repository
`gitops/dashboards`, and the `dac-runner` pod with `percli`, `cue` and Go,
then waits. The learner guide is `docs/overview.md`.

## Run it

```sh
astrona run -c .
astrona destroy ats-108-playground-010-01
```

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition |
| `bootstrap/prepare.sh` | Environment preparation, run once at startup |
| `manifests/lab-start.yaml` | Prometheus, tester, Gitea, the DaC runner (and the pipeline in section 040) |
| `manifests/perses-values.yaml` | Helm values for Perses |
| `manifests/repo/` | The starting state of `gitops/dashboards` |
| `docs/overview.md` | What the environment contains and ideas to try |

The plumbing is generated; change shared pieces in every environment of the
repository (see `CLAUDE.md`).
