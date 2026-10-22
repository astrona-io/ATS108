# ATS108 — Dashboard-as-Code With CUE & Go (Perses)

Course material for the **Dashboard-as-Code With CUE & Go** domain of the
Astrona Perses training path ([ATP021](https://github.com/astrona-io/ATP021)),
which is **25% of the path**. Written for **Perses v0.54.0**, **CUE v0.17.1**
and **Go 1.26.5**.

> **Status: draft, not yet run.** No playground or lab has been started on a
> cluster, and no lab has passed `astrona test` yet. Every Go file was
> compiled, tested and run against the pinned modules; the CUE files were not
> evaluated. See `CLAUDE.md`.

The course opens with an Introduction in `sections/intro/` (welcome, machine
setup, how the course is made). Everything else lives under `sections/`. Each
section contains:

- **A module** — a reading chapter split into a short landing page, ordered
  deep-dive parts and a summary page, a throwaway **playground** to explore
  in, and a graded **lab** placed right after the part it tests.
- **A capstone** — one larger graded lab with several independent faults.

---

## Sections

| Section | Title | Modules | Labs | Topic |
| --- | --- | --- | --- | --- |
| [010](sections/section-010) | Why Dashboard-As-Code | 1 | 1 + capstone | The workflow: repository, build, apply, diff |
| [020](sections/section-020) | CUE For Dashboards | 1 | 1 + capstone | The CUE SDK |
| [030](sections/section-030) | The Go SDK | 1 | 1 + capstone | The Go SDK |
| [040](sections/section-040) | A Pipeline For Dashboards | 1 | 1 + capstone | Lint, build and apply from a Kubernetes Job |

The order goes from the workflow to the languages to automation. Section 010
shows the loop every later page uses: edit, push, build, apply, diff.
Sections 020 and 030 teach the two ways Perses offers to write dashboards.
Section 040 hands the loop to a pipeline that refuses broken commits.

---

## Modules

| Module | Reader | Parts | Labs |
| --- | --- | --- | --- |
| 010-01 | [Build And Apply Your First Dashboard As Code](sections/section-010/module-01/course.md) | 3 | [lab-01](sections/section-010/module-01/labs/lab-01) |
| 020-01 | [Write Dashboards In CUE](sections/section-020/module-01/course.md) | 3 | [lab-01](sections/section-020/module-01/labs/lab-01) |
| 030-01 | [Write Dashboards In Go](sections/section-030/module-01/course.md) | 3 | [lab-01](sections/section-030/module-01/labs/lab-01) |
| 040-01 | [Lint, Build And Apply Dashboards From A Pipeline](sections/section-040/module-01/course.md) | 3 | [lab-01](sections/section-040/module-01/labs/lab-01) |

---

## Capstones

| Capstone | Scenario | Faults |
| --- | --- | --- |
| [010](sections/section-010/capstone/labs/lab-01) | Bring A Hand-Edited Dashboard Back Under Code | a query changed in the browser, a panel added in the browser that must move into code |
| [020](sections/section-020/capstone/labs/lab-01) | Repair A CUE Dashboard Library | a value outside the StatChart schema, a panel group without a title, a value that is never set |
| [030](sections/section-030/capstone/labs/lab-01) | Generate A Dashboard Per Job | a loop that uses the first job for every group, a debug line printed into the build output |
| [040](sections/section-040/capstone/labs/lab-01) | Run Dashboard-As-Code End To End | a pipeline that builds only CUE, an apply into the wrong project, a Go program that prints into its output |

---

## The lab environment

Every playground and lab is a **kind** cluster with:

- Perses v0.54.0 (chart `perses` 0.23.3) with the project `inventory` and its
  datasource `prometheus`;
- Prometheus v3.15.1 scraping itself and Perses;
- Gitea with the repository `gitops/dashboards` (lab-only user `gitops` /
  `gitops-password`);
- the pod `dac-runner` (`golang:1.26.5-alpine` with `percli` v0.54.0 and
  `cue` v0.17.1), where every DaC command runs through the helper
  `dac() { kubectl -n dac exec -i deploy/dac-runner -- dac-run "$@"; }`.

The reader edits a clone of `gitops/dashboards` on their machine and pushes;
the runner always builds `origin/main`. Perses and Gitea answer at
`http://perses.localtest.me:8080` and `http://gitea.localtest.me:3000`, in the
cluster through CoreDNS rewrites and on the machine through port-forwards.

## Running a playground

```bash
astrona run --git ssh://git@github.com/astrona-io/ATS108.git -c sections/<section>/module-01/playground
astrona destroy <name>
```

## Running a lab

Labs and capstones are graded. Read `question.md`, do the work, and submit:

```bash
astrona run --git ssh://git@github.com/astrona-io/ATS108.git -c sections/<section>/module-01/labs/lab-01
astrona submit -c sections/<section>/module-01/labs/lab-01
astrona destroy <name>
```

Each lab grades the **head of `main`** and **what the Perses API serves**:
graders build the code in the runner and compare groups, panels, plugin kinds,
queries and variables with the server. Several graders reject the
plausible-but-wrong fix (hand-written JSON, a weakened schema, a deleted test,
a pipeline step that ignores its errors).
