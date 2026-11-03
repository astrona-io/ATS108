# Solution: Add A Check Mode To The Pipeline

Work the task yourself first. Running `astrona submit -c sections/section-040/module-02/labs/lab-01` after a step tells you which checks pass.

The grader checks three things, in order: the script reads `MODE`, still lints online and applies, and the CronJob is unchanged; a check run completes and applies nothing, and a check run on a broken commit fails; a run without `MODE` applies every dashboard.

## Step 1: Read the script

```sh
kubectl -n dac get configmap dashboards-pipeline -o jsonpath='{.data.pipeline\.sh}' > pipeline.sh
cat pipeline.sh
```

The script already has `set -eu`, the online lint and the diff. The only thing missing is a way to stop before `percli apply`.

## Step 2: Add the mode

Replace the content of `pipeline.sh` with this script:

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

The expression `${MODE:-deploy}` is the value of `MODE`, or `deploy` when it is not set. The script has `set -u`, so it needs the default.

## Step 3: Replace the ConfigMap

```sh
kubectl -n dac create configmap dashboards-pipeline --from-file=pipeline.sh --dry-run=client -o yaml > pipeline-configmap.yaml
kubectl apply -f pipeline-configmap.yaml
```

## Step 4: Run both modes

Start a check run by adding the variable to one Job:

```sh
kubectl -n dac create job pipeline-check --from=cronjob/dashboards-pipeline --dry-run=client -o json \
  | kubectl patch --local -f - --type=json -o json \
    -p '[{"op":"add","path":"/spec/template/spec/containers/0/env/-","value":{"name":"MODE","value":"check"}}]' \
  | kubectl apply -f -
kubectl -n dac wait job/pipeline-check --for=condition=complete --timeout=600s
kubectl -n dac logs job/pipeline-check | tail -5
```

The last lines show the diff step and the line that says nothing was applied. Then start a deploy run:

```sh
kubectl -n dac create job pipeline-deploy --from=cronjob/dashboards-pipeline
kubectl -n dac wait job/pipeline-deploy --for=condition=complete --timeout=600s
```

Submit:

```sh
astrona submit -c sections/section-040/module-02/labs/lab-01
```

## Why the obvious shortcuts are wrong

| Shortcut | What happens |
| --- | --- |
| Set `MODE` in the CronJob | Every run becomes a check run, and the grader requires a CronJob without `MODE` |
| Make check mode `exit 1` before the apply | A successful check fails the Job; the grader requires Complete |
| Remove the apply step | The deploy run applies nothing, and the grader requires every dashboard on the server |
