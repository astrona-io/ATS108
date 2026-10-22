# Applying And Diffing Built Dashboards

A built dashboard is a file. It does nothing until it reaches the server, and once it is there, the server can change without the code knowing. This part applies built dashboards with `percli apply`, checks them through the Perses API, and uses `percli dac diff` to find a difference between the server and the code.

## Apply a built dashboard

`percli apply` sends resources from JSON or YAML files to the Perses server. It creates a resource that does not exist yet and updates one that does. Build the overview dashboard and apply the result in one command, so both steps see the same version of the code:

<!-- astrona:playground:renew -->

```sh
dac sh -c 'percli dac build -f dashboards/cue/prometheus-overview.cue -ojson && percli apply -f built/dashboards/cue/prometheus-overview_output.json'
```

`percli` reports that it created the dashboard `prometheus-overview` in the project `inventory`. It took the project from the dashboard's own `metadata.project`. If you select a different project with `-p` or `percli project`, `percli apply` refuses a resource whose metadata names another project, unless you add `--force`; that check protects you from applying a dashboard into the wrong project.

Check the result through the Perses API from the runner:

```sh
dac sh -c 'curl -s http://perses.localtest.me:8080/api/v1/projects/inventory/dashboards/prometheus-overview | jq "[.spec.layouts[].spec.display.title]"'
```

The API returns the two group titles, `Scrape health` and `Storage`. If you want to see the dashboard, start a second port-forward with `kubectl -n perses port-forward svc/perses 8080:8080` and open `http://perses.localtest.me:8080` in a browser; the panels show data from Prometheus.

## Change the code, then compare

A real change starts on your machine. Open `dashboards/cue/prometheus-overview.cue` in your clone and change the display name `"Prometheus Overview"` to `"Prometheus Overview (from Git)"`. Commit and push it:

```sh
git commit -am "Rename the overview dashboard"
git push
```

Before you apply, ask what would change on the server. `percli dac diff` compares each built dashboard with the dashboard of the same name on the server:

```sh
dac sh -c 'percli dac build -f dashboards/cue/prometheus-overview.cue -ojson && percli dac diff -f built/dashboards/cue/prometheus-overview_output.json'
```

The command prints one result per dashboard: the project, the name, a status, and the path of a diff file. It compares only the `spec` of the two dashboards and writes a unified diff to `built/inventory-prometheus-overview.diff`. A dashboard that does not exist on the server yet gets no diff file; it is reported as new. Read the diff:

```sh
dac cat built/inventory-prometheus-overview.diff
```

The diff shows one changed line: the display name. Nothing else differs, so applying is safe:

```sh
dac percli apply -f built/dashboards/cue/prometheus-overview_output.json
```

## Drift: when the server changes first

The same comparison finds the opposite problem. If someone edits the dashboard in the browser, the server no longer matches the code. That difference is called **drift**. Run the diff without changing the code, and any line it shows is a change made outside Git. You then decide, line by line, whether to move the change into the code or to overwrite it with the next apply.

You now know the whole loop: change the code, push, build, compare with `percli dac diff`, apply. The open question for the rest of the course is how to write the source files themselves.

## Common pitfalls

> [!WARNING]
> - **Applying without building first.** `percli apply` sends whatever is in `built`. An old file there applies an old dashboard. Build and apply in one command.
> - **Reading "no diff file" as "no difference".** A dashboard that is not on the server yet has no diff file; it is reported as new.
> - **Fixing drift by hand in the browser.** That creates more drift. Move the change into the code and apply it.

## Your mission: Build And Apply A CUE Dashboard

You can now build a dashboard from code, apply it, and check that the server holds what the code builds. The graded lab gives you a repository with a new CUE dashboard, `scrape-health`, that is not on the server yet, and asks you to put it there from the code.

The lab runs in its own cluster, so first pause your playground. Nothing in it is lost:

```sh
astrona stop ats-108-playground-010-01
```

Then start the lab:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS108.git -c sections/section-010/module-01/labs/lab-01
```

The task is on the next page. Solve it on your own first. When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-010/module-01/labs/lab-01
```

When the lab is done, remove it and start your playground again:

```sh
astrona destroy ats-108-lab-010-01
astrona start ats-108-playground-010-01
```
