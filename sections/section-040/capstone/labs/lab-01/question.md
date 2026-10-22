# Question

Solve this question on: `terminal`

**Time:** about 40 minutes · **Topic:** A pipeline for dashboards

## Scenario

The repository `gitops/dashboards` holds the CUE dashboard `prometheus-overview` and the Go dashboards `prometheus-storage` and `per-job`. The pipeline in the namespace `dac` (the ConfigMap `dashboards-pipeline` and the suspended CronJob of the same name) should ship all three to the project `inventory`. It ships none of them: every run fails, and even the parts that seemed to work would have missed some dashboards.

## Your task

1. Start a pipeline run and find every reason it does not ship the three dashboards: in the pipeline script and in the repository.
2. Fix them. Change the script through the ConfigMap, and the code through commits on `main`.
3. Start a run that completes and puts every dashboard of the repository on the server.

Start a run with:

```sh
kubectl -n dac create job <name> --from=cronjob/dashboards-pipeline
```

## Constraints

- Keep `set -eu`, the online lint and the diff step in the script.
- Do not remove a dashboard from the repository or from the build.
- Every Go dashboard must keep following the exec convention: `sdk.NewExec()` and `exec.BuildDashboard`.

## Done when

- A new pipeline run completes. The grader starts its own run.
- Both Go dashboards build to clean JSON dashboards.
- `prometheus-overview`, `prometheus-storage` and `per-job` are in the project `inventory`, exactly as the code at the head of `main` builds them.
