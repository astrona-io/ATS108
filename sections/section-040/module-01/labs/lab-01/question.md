# Question

Solve this question on: `terminal`

**Time:** about 30 minutes · **Topic:** A pipeline for dashboards

## Scenario

The dashboards of the project `inventory` are shipped by the pipeline in the namespace `dac`: the script `pipeline.sh` in the ConfigMap `dashboards-pipeline`, run by Jobs created from the suspended CronJob `dashboards-pipeline`. Last week a commit with a broken CUE file still put half of its changes on the server, and the run reported success. The team wants a pipeline that refuses a broken commit completely.

## Your task

Change the pipeline script so that:

1. The run stops at the first step that fails, and the Job ends as failed.
2. The built dashboards are linted against the Perses server before anything is applied.
3. Nothing is applied when any dashboard fails to build or to lint.

Then run the pipeline once on the current `main` and check that it succeeds.

Start a run with:

```sh
kubectl -n dac create job <name> --from=cronjob/dashboards-pipeline
```

## Constraints

- Keep the steps fetch, dependencies, build, lint and apply, in that order.
- Do not change the dashboards in the repository, and do not remove dashboards from the build.
- Change the pipeline through the ConfigMap `dashboards-pipeline`; keep the CronJob as it is.

## Done when

- The script lints with `percli lint` and `--online`.
- A commit that adds a dashboard file that does not build makes the run fail, and none of that commit's changes reach the server.
- A good commit makes the run complete, and every dashboard of the repository is on the server as the code builds it.

The grader pushes its own commits to `main` and starts its own runs to check this.
