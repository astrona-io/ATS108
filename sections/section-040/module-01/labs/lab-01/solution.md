# Solution: Make The Pipeline Refuse Broken Dashboards

Work the task yourself first. Running `astrona submit -c sections/section-040/module-01/labs/lab-01` after a step tells you which checks pass.

The grader checks three things, in order: the script lints with `--online`; a commit with a broken dashboard fails the run and applies nothing; a good commit completes the run and applies every dashboard.

## Step 1: Read the script

```sh
kubectl -n dac get configmap dashboards-pipeline -o jsonpath='{.data.pipeline\.sh}' > pipeline.sh
cat pipeline.sh
```

Three things let a broken commit through. The script has no `set -e`, so a failing command does not stop it. The build step ends with `|| echo "some dashboards did not build"`, which turns a failed build into a success. The script ends with `exit 0`, so the Job always succeeds. And the lint step runs `percli lint -d built` without `--online`, which checks nothing beyond the file format.

## Step 2: Write the strict script

Replace the content of `pipeline.sh` with this script:

```sh
#!/bin/sh
# The dashboard pipeline: fetch the repository, build every dashboard, lint
# the results against the server, show the differences, then apply.
# `set -eu` stops the run at the first failing step, so a broken commit
# applies nothing.
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

echo "== apply"
percli apply -d built
```

`set -eu` stops the script at the first failing command. The build step has nothing after it that hides its exit code. The lint step checks every built dashboard against the server. The diff step shows what is about to change, and only then does the apply run.

## Step 3: Replace the ConfigMap and run once

```sh
kubectl -n dac create configmap dashboards-pipeline --from-file=pipeline.sh --dry-run=client -o yaml | kubectl apply -f -
kubectl -n dac create job pipeline-fixed --from=cronjob/dashboards-pipeline
kubectl -n dac wait job/pipeline-fixed --for=condition=complete --timeout=600s
kubectl -n dac logs job/pipeline-fixed
```

The run completes. The log shows the build report, the lint result, the diff report and the apply report.

## Step 4: See it refuse a broken commit

Start the Gitea port-forward in a second terminal (`kubectl -n gitea port-forward svc/gitea-http 3000:3000`), clone the repository, add a CUE file that does not build, push, and run:

```sh
printf 'package dashboards\n\nbroken: {\n' > dashboards/cue/broken.cue
git add dashboards/cue/broken.cue && git commit -m "A broken dashboard" && git push
kubectl -n dac create job pipeline-broken --from=cronjob/dashboards-pipeline
```

After a few minutes, `kubectl -n dac get job pipeline-broken` shows the Job as failed. Its log ends at the first step that reads the broken file: the dependencies step, where `cue mod tidy` loads every CUE package, or the build step. Nothing after it ran. Remove the broken file again (`git rm dashboards/cue/broken.cue`, commit, push) before you submit:

```sh
astrona submit -c sections/section-040/module-01/labs/lab-01
```

## Why the obvious shortcuts are wrong

| Shortcut | What happens |
| --- | --- |
| Add `set -e` but keep `\|\| echo` on the build | The build failure is still hidden, and the run applies the dashboards that did build |
| Add `--online` but keep `exit 0` and no `set -e` | The lint fails, the script goes on, and the Job reports success |
| Build only the folders that build today | A new dashboard folder is silently never shipped |
