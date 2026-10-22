# Prerequisites

Before starting this lab you should be able to:

- Clone a Git repository, commit and push from the terminal.
- Run a command in a pod with `kubectl exec`.
- Read a Perses dashboard in JSON: its panels, layouts, queries and variables.

## What the environment gives you

The lab environment builds itself before the task begins:

- A single-node `kind` Kubernetes cluster, with `kubectl` already pointed at it.
- **Perses v0.54.0** in the namespace `perses`, with the project `inventory` and its datasource `prometheus`.
- **Prometheus** in the namespace `observability`, scraping itself and Perses.
- **Gitea** in the namespace `gitea`, with the repository `gitops/dashboards` (user `gitops`, password `gitops-password`, lab-only credentials).
- The pod **`dac-runner`** in the namespace `dac`, with `percli` v0.54.0, `cue` v0.17.1 and Go 1.26.5.

Nothing the task asks you to create has been created for you.

## Working rules

- Everything is graded on the **final state**: the head of `main` in
  `gitops/dashboards` and what the Perses API serves.
- The runner builds what is pushed to `main`. A change you have not pushed
  does not exist for the grader.
- Change one thing at a time, push, and build again.
