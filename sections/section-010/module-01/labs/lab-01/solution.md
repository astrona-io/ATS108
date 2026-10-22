# Solution: Build And Apply A CUE Dashboard

Work the task yourself first. Running `astrona submit -c sections/section-010/module-01/labs/lab-01` after a step tells you which checks pass.

The grader checks two things: the dashboard `scrape-health` is in the project `inventory`, and what the server holds equals what the file builds at the head of `main`.

## Step 1: Define the helper and look at the file

Every `percli` command runs in the `dac-runner` pod. Define the helper, then read the file you are going to build:

```sh
dac() { kubectl -n dac exec -i deploy/dac-runner -- dac-run "$@"; }
dac cat dashboards/cue/scrape-health.cue
```

The file builds a dashboard named `scrape-health` in the project `inventory`, with two panel groups, `Prometheus` and `Perses`. Every panel comes from the shared package `example.com/dashboards/lib/panels`.

## Step 2: Build and apply in one command

Building and applying in the same command makes sure you apply the file you just built:

```sh
dac sh -c 'percli dac build -f dashboards/cue/scrape-health.cue -ojson && percli apply -f built/dashboards/cue/scrape-health_output.json'
```

`percli dac build` runs `cue eval` on the file with `--concrete` and writes `built/dashboards/cue/scrape-health_output.json`. `percli apply` then creates the dashboard in the project named in its metadata, `inventory`.

## Step 3: Prove that the server matches the code

`percli dac diff` compares the built dashboard with the server:

```sh
dac sh -c 'percli dac build -f dashboards/cue/scrape-health.cue -ojson && percli dac diff -f built/dashboards/cue/scrape-health_output.json'
dac cat built/inventory-scrape-health.diff
```

The diff file has no changed lines, because the server holds what the code builds. You can also list the group titles through the API:

```sh
dac sh -c 'curl -s http://perses.localtest.me:8080/api/v1/projects/inventory/dashboards/scrape-health | jq "[.spec.layouts[].spec.display.title]"'
```

The API returns `Prometheus` and `Perses`.

## Step 4: Submit

```sh
astrona submit -c sections/section-010/module-01/labs/lab-01
```

## Why the obvious shortcuts are wrong

| Shortcut | What happens |
| --- | --- |
| Write the JSON by hand and apply it | It drifts from the code at the first change; the grader compares the server with the build of `main` |
| Build on your machine without pushing a change you made | The runner builds `main` on Gitea, not your machine |
| Apply an old file from `built` | You apply whatever was built last, which may not be the current code |
