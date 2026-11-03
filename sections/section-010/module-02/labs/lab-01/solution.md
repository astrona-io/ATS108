# Solution: Fix The Project Of A Dashboard

Work the task yourself first. Running `astrona submit -c sections/section-010/module-02/labs/lab-01` after a step tells you which checks pass.

The grader checks three things: the code builds a dashboard for the project `inventory`, the server holds that dashboard as built, and no project `staging` exists.

## Step 1: Find the cause

Define the helper and build the dashboard to standard output:

```sh
dac() { kubectl -n dac exec -i deploy/dac-runner -- dac-run "$@"; }
dac sh -c 'percli dac build -f dashboards/cue/release-health.cue -ojson -m stdout | jq -r ".metadata.project"'
```

The result is `staging`. The build works, but the dashboard names a project that the server does not have.

## Step 2: Fix the code

Start the Gitea port-forward in a second terminal (`kubectl -n gitea port-forward svc/gitea-http 3000:3000`), then clone the repository:

```sh
git clone http://gitops:gitops-password@gitea.localtest.me:3000/gitops/dashboards.git
cd dashboards
```

In `dashboards/cue/release-health.cue`, change the line `#project: "staging"` to `#project: "inventory"`. Then commit and push:

```sh
git commit -am "Put release-health in the inventory project" && git push
```

## Step 3: Build and apply

```sh
dac sh -c 'percli dac build -f dashboards/cue/release-health.cue -ojson && percli apply -f built/dashboards/cue/release-health_output.json'
```

## Step 4: Check the result

```sh
dac sh -c 'curl -s http://perses.localtest.me:8080/api/v1/projects/inventory/dashboards/release-health | jq -r ".metadata.project"'
astrona submit -c sections/section-010/module-02/labs/lab-01
```

## Why the obvious shortcuts are wrong

| Shortcut | What happens |
| --- | --- |
| `percli apply --create-project` | A project `staging` is created, and the grader rejects it |
| `percli apply --force` with `-p inventory` | The dashboard on the server says `inventory` only until the next build; the code still says `staging` |
| Editing the built JSON | The next build produces `staging` again, and the server no longer equals the build |
