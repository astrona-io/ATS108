# Solution: Repair A CUE Dashboard Library

Work the task yourself first. Running `astrona submit -c sections/section-020/capstone/labs/lab-01` after a step tells you which checks pass.

The grader checks four things: every dashboard builds, the Stat panels use `last` through the schema, the groups and the Perses job are right, and the server equals the build of each file.

## Step 1: Read the errors

```sh
dac() { kubectl -n dac exec -i deploy/dac-runner -- dac-run "$@"; }
dac percli dac build -d dashboards -ojson
```

`percli` builds each file on its own and lists every failure at the end. Three different faults show up:

- Every file reports a conflict on a path ending in `plugin.spec.calculation`: the value `"average"` matches none of the values the StatChart schema allows. The value comes from `#TargetsUp` in `lib/panels/panels.cue`.
- `team-overview.cue` reports a missing value for a panel group's `#title`: the second group has `#cols` and `#panels` but no title.
- `scrape-health.cue` reports a value that is not concrete: `_probeJob` is declared as `string` but never set, so the `Perses` panel's `#job` stays undecided under `--concrete`.

## Step 2: Fix the three faults

Start the Gitea port-forward in a second terminal (`kubectl -n gitea port-forward svc/gitea-http 3000:3000`), clone the repository and make three changes:

```sh
git clone http://gitops:gitops-password@gitea.localtest.me:3000/gitops/dashboards.git
cd dashboards
```

1. In `lib/panels/panels.cue`, change `calculation: "average"` to `calculation: "last"`. "Latest value" is `last` in the StatChart schema; `"average"` is not a value it knows, and `mean` would show the average.
2. In `dashboards/cue/team-overview.cue`, give the second group its title, so it reads `#title: "Perses"` above `#cols: 1`.
3. In `dashboards/cue/scrape-health.cue`, set the job: change `_probeJob: string` to `_probeJob: "perses"`.

Push:

```sh
git commit -am "Fix the shared panels and the dashboards" && git push
```

## Step 3: Build everything and apply

```sh
dac sh -c 'rm -rf built && percli dac build -d dashboards -ojson && percli apply -d built'
```

Removing `built` first means `percli apply -d built` applies only what this build produced. Check one result:

```sh
dac sh -c 'percli dac build -f dashboards/cue/team-overview.cue -ojson -m stdout | jq "[.spec.layouts[].spec.display.title]"'
```

The titles are `Selected job` and `Perses`. Submit:

```sh
astrona submit -c sections/section-020/capstone/labs/lab-01
```

## Why the obvious shortcuts are wrong

| Shortcut | What happens |
| --- | --- |
| Remove `statChart &` so any calculation is accepted | The schema no longer checks the panel; the grader requires the schema |
| Change the calculation to `mean` | The build passes, but the panel shows the average, not the latest value |
| Delete the second group of `team-overview` | The build passes without the group the team asked for |
| Give `_probeJob` a default with `string \| *"perses"` and keep the declaration | It builds, but a plain value is clearer; either form passes as long as the query is `sum(up{job="perses"})` |
