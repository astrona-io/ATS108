# Keeping Perses And Git The Same

A pipeline that applies every commit makes the server follow Git, but only in one direction. It creates and updates dashboards. It does not log in by itself to a server that requires it, it does not delete a dashboard you removed from Git, and it does not stop people from editing dashboards in the browser. This part covers those three gaps.

## Logging in from a pipeline

The playground's Perses has authentication off, so `percli login http://perses.localtest.me:8080` only stores the address. A real server requires a login, and a pipeline cannot type a password. `percli login` takes everything on the command line instead: `--username` and `--password` for a user of Perses' own (native) identity provider, `--token` for an access token, or `--provider`, `--client-id` and `--client-secret` for a robot account at an external identity provider.

The credentials belong in a Kubernetes Secret, passed to the Job's container as environment variables. The script then runs `percli login "$PERSES_URL" --username "$PERSES_USER" --password "$PERSES_PASSWORD"`. The account should have exactly the permissions the pipeline needs: create and update dashboards in its projects, nothing more.

## Deleting dashboards

`percli apply -d built` sends what the build produced. A dashboard whose file you deleted from Git is simply not in `built`, so the pipeline never touches it again, and it stays on the server. Try it in the playground. In your clone, delete one dashboard and push:

<!-- astrona:playground:renew -->

```sh
git rm dashboards/go/per-job/main.go && git commit -m "Retire the per-job dashboard" && git push
kubectl -n dac create job pipeline-2 --from=cronjob/dashboards-pipeline
kubectl -n dac wait job/pipeline-2 --for=condition=complete --timeout=600s
```

The run succeeds. Now list the dashboards:

```sh
dac() { kubectl -n dac exec -i deploy/dac-runner -- dac-run "$@"; }
dac percli get dashboards
```

`per-job` is still there. Removing it is a separate, deliberate step: `percli delete dashboard per-job`, run by a person or by an extra pipeline step that compares the list on the server with the list in `built`. Delete it now:

```sh
dac percli delete dashboard per-job
```

## Edits outside the pipeline

People with edit rights can still change a dashboard in the browser, and the next run overwrites the change without a trace. Two habits keep this rare. The first is permissions: when authentication is on, give people read access to code-managed projects and give only the pipeline's account the right to edit them. The second is the diff step: the pipeline's log shows, for every dashboard, whether the server differed from the code before the apply. A difference nobody committed is drift, and the log tells you where it happened.

You now know the three gaps a pipeline leaves: credentials, deletions and edits made elsewhere. That is everything the graded lab needs, together with a pipeline that stops at the first failing step.

## Common pitfalls

> [!WARNING]
> - **Putting a password in the script.** The script lives in a ConfigMap that many people can read. Use a Secret and environment variables.
> - **Expecting a deleted file to delete the dashboard.** `percli apply` never deletes. Delete removed dashboards on purpose.
> - **Giving the pipeline's account administrator rights.** It needs to edit dashboards in its projects, nothing else.

## Your mission: Make The Pipeline Refuse Broken Dashboards

You can now read and run the pipeline, and you know what each step checks. The graded lab gives you a pipeline that applies whatever it can, even when a build fails, and lints without checking anything. It asks you to make it stop at the first failure and lint against the server.

The lab runs in its own cluster, so first pause your playground. Nothing in it is lost:

```sh
astrona stop ats-108-playground-040-01
```

Then start the lab:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS108.git -c sections/section-040/module-01/labs/lab-01
```

The task is on the next page. Solve it on your own first. When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-040/module-01/labs/lab-01
```

When the lab is done, remove it and start your playground again:

```sh
astrona destroy ats-108-lab-040-01
astrona start ats-108-playground-040-01
```
