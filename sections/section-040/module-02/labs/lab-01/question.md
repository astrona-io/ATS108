# Question

Solve this question on: `terminal`

**Time:** about 25 minutes · **Topic:** A pipeline for dashboards

## Scenario

The dashboards of the project `inventory` are shipped by the pipeline in the namespace `dac`: the script `pipeline.sh` in the ConfigMap `dashboards-pipeline`, run by Jobs created from the suspended CronJob `dashboards-pipeline`. The pipeline already stops on errors and lints online. The team now wants to check commits on branches with the same script, without changing the server, and to deploy only from `main`.

## Your task

Change the pipeline script so that it has two modes, selected by the environment variable `MODE`:

1. With `MODE=check`, the run does the steps fetch, dependencies, build, lint and diff, prints a line that says nothing was applied, and ends successfully before the apply step.
2. With `MODE` unset, or set to any other value, the run behaves as it does today and ends with the apply step.

Then run the pipeline once in each mode on the current `main`. Start a deploy run with:

```sh
kubectl -n dac create job <name> --from=cronjob/dashboards-pipeline
```

The CronJob has no `MODE` variable. To start a check run, add the variable to one Job only, for example by creating the Job object with `--dry-run=client -o json`, adding an environment variable to its first container, and applying the result.

## Constraints

- Keep the steps in the same order and keep `percli lint --online`.
- Change the pipeline through the ConfigMap `dashboards-pipeline`; keep the CronJob as it is, suspended and without a `MODE` variable.
- A check run on a broken commit must still fail.

## Done when

- The script reads `MODE` and still has the lint and apply steps.
- A run with `MODE=check` on a good commit completes and no new dashboard reaches the server.
- A run with `MODE=check` on a commit with a broken dashboard fails.
- A run without `MODE` completes and every dashboard of the repository is on the server as the code builds it.

The grader pushes its own commits to `main` and starts its own runs to check this.
