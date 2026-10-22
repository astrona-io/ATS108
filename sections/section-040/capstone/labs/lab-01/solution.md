# Solution: Run Dashboard-As-Code End To End

Work the task yourself first. Running `astrona submit -c sections/section-040/capstone/labs/lab-01` after a step tells you which checks pass.

The grader checks three things: a pipeline run it starts completes, both Go dashboards build to clean JSON, and all three dashboards are on the server as the code builds them.

## Step 1: Run the pipeline and read the log

```sh
kubectl -n dac create job pipeline-1 --from=cronjob/dashboards-pipeline
kubectl -n dac logs -f job/pipeline-1
```

The run builds, lints and diffs, then fails in the apply step: `percli apply -d built -p monitoring` refuses every dashboard because its metadata names the project `inventory`, not `monitoring`. Read the script for the other faults:

```sh
kubectl -n dac get configmap dashboards-pipeline -o jsonpath='{.data.pipeline\.sh}' > pipeline.sh
cat pipeline.sh
```

The build step is `percli dac build -d dashboards/cue -ojson`: it builds only the CUE folder, so the Go dashboards never reach `built`, and the run would ship one dashboard out of three.

## Step 2: Check the Go dashboards

```sh
dac() { kubectl -n dac exec -i deploy/dac-runner -- dac-run "$@"; }
dac percli dac build -f dashboards/go/storage/main.go -ojson -m stdout | head -2
```

The first line is `prometheus-storage: 1 panel groups`, printed by a `fmt.Printf` in `dashboards/go/storage/main.go`. Once the pipeline builds the Go folder, this file is no longer valid JSON, and the lint or the apply fails on it.

## Step 3: Fix the code

Start the Gitea port-forward in a second terminal (`kubectl -n gitea port-forward svc/gitea-http 3000:3000`), clone the repository, and in `dashboards/go/storage/main.go` remove the `fmt.Printf(...)` line and the `"fmt"` import. Push:

```sh
git commit -am "Keep the storage dashboard output clean" && git push
```

## Step 4: Fix the script

In `pipeline.sh`, build the whole folder and apply without the wrong project:

```sh
percli dac build -d dashboards -ojson
```

```sh
percli apply -d built
```

Replace the ConfigMap and run again:

```sh
kubectl -n dac create configmap dashboards-pipeline --from-file=pipeline.sh --dry-run=client -o yaml | kubectl apply -f -
kubectl -n dac create job pipeline-2 --from=cronjob/dashboards-pipeline
kubectl -n dac wait job/pipeline-2 --for=condition=complete --timeout=600s
dac percli get dashboards
```

The run completes, and the project lists `prometheus-overview`, `prometheus-storage` and `per-job`. Submit:

```sh
astrona submit -c sections/section-040/capstone/labs/lab-01
```

## Why the obvious shortcuts are wrong

| Shortcut | What happens |
| --- | --- |
| Add `--force` to the apply | The dashboards would land in the wrong project, `monitoring` |
| Build the Go dashboards in a second step with `\|\| true` | A broken Go dashboard is hidden again, and `set -eu` no longer protects the run |
| Redirect the program's output to `/dev/null` in the pipeline | The dashboard itself is on standard output too; remove the extra print instead |
