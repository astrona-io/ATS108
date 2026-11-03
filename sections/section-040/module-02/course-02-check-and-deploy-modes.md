# Check And Deploy Modes

A pipeline that runs on every pushed branch should check commits, but only the main branch should change the server. Two scripts would drift apart, so one script with a switch is better. This part adds a variable named `MODE` to the pipeline script. With `MODE=check` the run does everything except the apply step. Without it, the run deploys.

## The new script

Save this as `pipeline.sh`. It is the working pipeline with one new block before the apply step:

<!-- astrona:playground:renew -->

```sh
#!/bin/sh
# The dashboard pipeline: fetch the repository, build every dashboard, lint
# the results against the server, show the differences, then apply.
# MODE=check stops before the apply step. Any other value deploys.
set -eu
REPO_URL="http://gitops:gitops-password@gitea.localtest.me:3000/gitops/dashboards.git"
PERSES_URL="http://perses.localtest.me:8080"

echo "== fetch"
git clone -q --depth 1 "$REPO_URL" /work/repo
cd /work/repo
percli login "$PERSES_URL" >/dev/null

echo "== dependencies"
cue mod tidy
go mod download

echo "== build"
percli dac build -d dashboards -ojson

echo "== lint"
percli lint -d built --online

echo "== diff"
percli dac diff -d built

if [ "${MODE:-deploy}" = "check" ]; then
  echo "== check mode: nothing applied"
  exit 0
fi

echo "== apply"
percli apply -d built
```

The expression `${MODE:-deploy}` means the value of `MODE`, or `deploy` when `MODE` is not set. The script has `set -u`, which stops on an undefined variable, so the default is needed. The `exit 0` ends the run successfully before `percli apply`, so the Job completes and the server is unchanged.

## Replace the ConfigMap script

The pipeline script lives in the ConfigMap `dashboards-pipeline`. Replace it from the file. The first command builds the ConfigMap from the file without sending it, and the second applies it:

```sh
kubectl -n dac create configmap dashboards-pipeline --from-file=pipeline.sh --dry-run=client -o yaml > pipeline-configmap.yaml
kubectl apply -f pipeline-configmap.yaml
```

A Job reads the ConfigMap when its pod starts, so the next run uses the new script. The CronJob itself does not change.

## Start a check run

The CronJob has no `MODE` variable, and it stays that way. Add the variable to one Job only. The first command creates the Job object without sending it, the second adds an environment variable to its first container, and the third sends it:

```sh
kubectl -n dac create job pipeline-check --from=cronjob/dashboards-pipeline --dry-run=client -o json \
  | kubectl patch --local -f - --type=json -o json \
    -p '[{"op":"add","path":"/spec/template/spec/containers/0/env/-","value":{"name":"MODE","value":"check"}}]' \
  | kubectl apply -f -
kubectl -n dac wait job/pipeline-check --for=condition=complete --timeout=600s
kubectl -n dac logs job/pipeline-check | tail -5
```

The last lines show the heading `== diff`, the diff report, and the line `== check mode: nothing applied`. There is no `== apply` heading, because the script exited before it. A run without the variable, started with `kubectl -n dac create job pipeline-deploy --from=cronjob/dashboards-pipeline`, still ends with the apply step.

## A check that fails still fails

Check mode only skips the apply step. The build and lint steps still run with `set -e`, so a broken commit fails a check run exactly as it fails a deploy run. This is what makes the check useful on a branch: the author sees the same error before the commit reaches `main`.

You now know how to add a switch to the pipeline and start a run in each mode. The mission below tests it.

## Common pitfalls

> [!WARNING]
> - **Adding `MODE` to the CronJob.** Every run would then be a check run. Add it to one Job.
> - **Checking the value without a default.** With `set -u`, an unset `MODE` stops the script.
> - **Exiting with a non-zero code in check mode.** A successful check must complete the Job.

## Your mission: Add A Check Mode To The Pipeline

You can now add a check-only mode to a pipeline script. The graded lab asks you to add `MODE` to the pipeline in the cluster so that a run with `MODE=check` applies nothing, and a run without it deploys.

The lab runs in its own cluster, so first pause your playground. Nothing in it is lost:

```sh
astrona stop ats-108-playground-040-02
```

Then start the lab:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS108.git -c sections/section-040/module-02/labs/lab-01
```

The task is on the next page. Solve it on your own first. When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-040/module-02/labs/lab-01
```

When the lab is done, remove it and start your playground again:

```sh
astrona destroy ats-108-lab-040-02
astrona start ats-108-playground-040-02
```
