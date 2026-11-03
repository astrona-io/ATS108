# Reading A Pipeline Failure

A pipeline that refuses a broken commit is only useful if the person who pushed the commit can tell why. The Job, its pod and its log hold the answer. This part makes the pipeline fail on purpose and reads the evidence in the order that finds the cause fastest.

## Make a run fail

Push a CUE file that cannot be evaluated. This needs the Gitea port-forward from a second terminal (`kubectl -n gitea port-forward svc/gitea-http 3000:3000`):

<!-- astrona:playground:renew -->

```sh
git clone http://gitops:gitops-password@gitea.localtest.me:3000/gitops/dashboards.git
cd dashboards
```

Save this as `dashboards/cue/broken.cue`:

```cue
package dashboards

broken: {
```

Commit, push and start a run:

```sh
git add dashboards/cue/broken.cue && git commit -m "Add a broken file" && git push
kubectl -n dac create job pipeline-fail --from=cronjob/dashboards-pipeline
kubectl -n dac wait job/pipeline-fail --for=condition=failed --timeout=600s
```

The wait ends when the Job reports the condition `Failed`. The pipeline script runs with `set -eu`, so the first failing step ended the run.

## Start with the Job and the pod

Ask Kubernetes what happened at the Job level:

```sh
kubectl -n dac get job pipeline-fail
kubectl -n dac get pods -l job-name=pipeline-fail
```

The Job shows no completions, and the pod shows the status `Error`. That tells you the container exited with a non-zero code, which is the pipeline script's own failure. A pod in `Init:Error` would point to the init container that downloads the tools, and a pod in `ImagePullBackOff` would point to an image problem. Both are environment faults, not faults of your commit.

## Read the log from the end

The last lines of the log hold the failure, and the step headings above them show how far the run got:

```sh
kubectl -n dac logs job/pipeline-fail | tail -20
```

The headings `== fetch` and `== dependencies` appear, then `== build`, then the build report. The report names `dashboards/cue/broken.cue` as the file that failed, with CUE's message. There is no `== lint` heading, because the run stopped before it. A missing heading is the quickest way to see which step failed.

## Check what reached the server

A failed run must leave the server unchanged. Check it:

```sh
dac percli get dashboards
```

The list does not contain any dashboard from the commit, because the run stopped before the apply step. Remove the broken file and push, then start a new Job with a new name:

```sh
git rm dashboards/cue/broken.cue && git commit -m "Remove the broken file" && git push
kubectl -n dac create job pipeline-ok --from=cronjob/dashboards-pipeline
```

The second run completes, and the dashboards of the repository appear on the server.

You now know the order for reading a failure: the Job condition, the pod status, the last lines of the log, and the missing step heading. The open question is what the pipeline does about the server being changed by something other than the pipeline.

## Common pitfalls

> [!WARNING]
> - **Reading the top of the log.** The cause is at the bottom, next to the last step heading.
> - **Re-running the same Job name.** A Job name is unique in its namespace; pick a new one.
> - **Fixing the environment when the commit is wrong.** A pod in `Error` after a build failure means the commit is wrong, not the cluster.
