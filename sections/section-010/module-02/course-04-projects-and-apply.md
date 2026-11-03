# Projects And The Apply Command

A Perses project is a group of resources, such as dashboards and datasources, that share access rules. A dashboard always belongs to exactly one project. When the project in the dashboard and the project the command works in do not agree, `percli apply` has to choose, and its choice protects you. This part shows where the project comes from and what to do when it is wrong.

## Where the project comes from

A built dashboard names its project in `metadata.project`. In CUE the builder sets it from `#project`. In Go, `dashboard.ProjectName` sets it. List the projects and read the project of a built file:

<!-- astrona:playground:renew -->

```sh
dac() { kubectl -n dac exec -i deploy/dac-runner -- dac-run "$@"; }
dac percli get projects
dac sh -c 'percli dac build -f dashboards/cue/prometheus-overview.cue -ojson -m stdout | jq -r ".metadata.project"'
```

The server has the project `inventory`, and the dashboard names `inventory`. They agree, so applying works.

## The selected project

`percli` also has a selected project, set by `percli project <name>` or by `-p <name>` on a command. The runner selects `inventory`. When you apply a file whose `metadata.project` is different from the selected project, `percli apply` refuses it, unless you add `--force`. The check exists so that a dashboard written for one project cannot be applied into another by mistake.

## Fix the cause, not the check

Suppose a dashboard names the project `staging`, which does not exist. There are three ways to make the command succeed, and only one is right:

| Action | Result |
| --- | --- |
| Add `--force` | The resource is applied although the project differs. The mismatch stays in the code. |
| Add `--create-project` | `percli apply` creates the missing project, so the dashboard lands in a new project nobody uses. |
| Change the project in the source and push | The code says what you mean, and every later build agrees. |

The third way is the only one that keeps the code and the server consistent. `--create-project` is useful on purpose, for example when a pipeline provisions a new team's project, but it hides a typo in a project name.

## Check the destination

After an apply, ask the server where the dashboard went:

```sh
dac sh -c 'curl -s http://perses.localtest.me:8080/api/v1/projects/inventory/dashboards | jq -r ".[].metadata.name"'
```

The API path contains the project, so a dashboard in another project does not show up here. If a dashboard seems to be missing, check the project named in its metadata before you assume it was not applied.

You now know where a dashboard's project comes from, what the selected project is, and why the fix for a mismatch belongs in the source. The module's lab puts this to work.

## Common pitfalls

> [!WARNING]
> - **Using `--force` to get past the check.** The code still names the wrong project.
> - **Creating a project to match a typo.** `--create-project` makes the typo permanent.
> - **Looking for a dashboard in the wrong project.** The API path and the project selector decide what you see.

## Your mission: Fix The Project Of A Dashboard

You can now find which project a dashboard names, and fix a wrong project in the source. The graded lab asks you to move the dashboard `release-health` into the project `inventory` through a commit, without creating a project and without `--force`.

The lab runs in its own cluster, so first pause your playground. Nothing in it is lost:

```sh
astrona stop ats-108-playground-010-02
```

Then start the lab:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS108.git -c sections/section-010/module-02/labs/lab-01
```

The task is on the next page. Solve it on your own first. When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-010/module-02/labs/lab-01
```

When the lab is done, remove it and start your playground again:

```sh
astrona destroy ats-108-lab-010-02
astrona start ats-108-playground-010-02
```
