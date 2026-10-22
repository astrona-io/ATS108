---
estimated_duration: 25m
---

# Make The Pipeline Refuse Broken Dashboards

- **ID:** LAB
- **Slug:** ats-108-lab-040-01
- **Author:** Paris Nakita Kejser
- **Type:** Astrona graded lab

Read `question.md` for the task; `solution.md` is the walkthrough.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS108.git -c sections/section-040/module-01/labs/lab-01
astrona submit -c sections/section-040/module-01/labs/lab-01
astrona destroy ats-108-lab-040-01
```

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition, bootstrap and grading |
| `question.md` | The task |
| `solution.md` | Step-by-step walkthrough |
| `prerequisites.md` | Assumed knowledge and what the environment provides |
| `bootstrap/` | Environment preparation and the starting state |
| `manifests/` | Workloads, Helm values and the starting repository (`repo/`) |
| `solution/apply.sh` | Reference solution used by `astrona test` |
| `testing/` | Helpers `astrona test` runs first |
| `validation/` | Grading scripts, one per check, run in order |

The plumbing is generated; change shared pieces in every environment of the
repository (see `CLAUDE.md`).
