# Solution: Bring A Hand-Edited Dashboard Back Under Code

Work the task yourself first. Running `astrona submit -c sections/section-010/capstone/labs/lab-01` after a step tells you which checks pass.

The grader checks three things: the code builds the `Head series` panel as the third panel of the `Prometheus` group, the first panel on the server runs the code's query again, and the server equals the build of `main`.

## Step 1: See the drift

Build the dashboard from `main` and compare it with the server:

```sh
dac() { kubectl -n dac exec -i deploy/dac-runner -- dac-run "$@"; }
dac sh -c 'percli dac build -f dashboards/cue/scrape-health.cue -ojson && percli dac diff -f built/dashboards/cue/scrape-health_output.json'
dac cat built/inventory-scrape-health.diff
```

The diff compares the server's `spec` with the built one. It shows two differences: the server's panel `0_0` runs `count(up{job="prometheus"})` where the code says `sum(up{job="prometheus"})`, and the server has an extra panel `0_2`, `Head series`, with a third item in the `Prometheus` layout.

## Step 2: Move the panel worth keeping into the code

Start the Gitea port-forward in a second terminal (`kubectl -n gitea port-forward svc/gitea-http 3000:3000`), then clone the repository:

```sh
git clone http://gitops:gitops-password@gitea.localtest.me:3000/gitops/dashboards.git
cd dashboards
```

In `dashboards/cue/scrape-health.cue`, the `Prometheus` group lists two panels. Add a third one, after the `#SamplesAppended` line, so the list reads:

```cue
				#panels: [
					{panels.#TargetsUp & {#job: "prometheus"}}.panel,
					{panels.#SamplesAppended & {#job: "prometheus"}}.panel,
					{panels.#HeadSeries & {#job: "prometheus"}}.panel,
				]
```

The group has two columns, so the panel builder places the third panel at the start of the second row, which is where the browser edit put it. Commit and push:

```sh
git commit -am "Keep the Head series panel added in the browser"
git push
```

## Step 3: Apply the code and check again

Build `main` and apply it. The apply replaces the server's dashboard, which also removes the `count` query:

```sh
dac sh -c 'percli dac build -f dashboards/cue/scrape-health.cue -ojson && percli apply -f built/dashboards/cue/scrape-health_output.json'
dac sh -c 'percli dac build -f dashboards/cue/scrape-health.cue -ojson && percli dac diff -f built/dashboards/cue/scrape-health_output.json'
dac cat built/inventory-scrape-health.diff
```

The new diff file has no changed lines. Submit:

```sh
astrona submit -c sections/section-010/capstone/labs/lab-01
```

## Why the obvious shortcuts are wrong

| Shortcut | What happens |
| --- | --- |
| Apply the code without adding the panel | The wanted panel is lost; the grader requires it in the code |
| Copy the server's JSON for the new panel into the CUE file | The query is written by hand instead of coming from `#HeadSeries`; the next change to the shared panel misses it |
| Keep the server as it is | The `count` query stays, and the server no longer matches the code |
