# Verifying After Apply

A run that ends with success says that every command exited with code 0. It does not say that the server now holds what the code builds. A browser edit between two runs, a dashboard in another project or a failed partial change can leave the server different. This part checks the result in two ways: through the API and through `percli dac diff`.

## Ask the API

The Perses API lists the dashboards of a project. The runner reaches the server by its in-cluster name, so run the request there:

<!-- astrona:playground:renew -->

```sh
dac() { kubectl -n dac exec -i deploy/dac-runner -- dac-run "$@"; }
dac sh -c 'curl -fsS http://perses.localtest.me:8080/api/v1/projects/inventory/dashboards | jq -r ".[].metadata.name"'
```

The names are the dashboards of the project. After a deploy run, every dashboard the repository builds is in the list. A name that is missing means the apply step did not create it or it went to another project.

## Diff after apply

`percli dac diff` compares each built dashboard with the server. Run it right after a deploy:

```sh
dac sh -c 'percli dac build -d dashboards -ojson >/dev/null && percli dac diff -d built'
```

The command prints a status for each dashboard. A dashboard that matches has no diff text, and a dashboard that differs has a diff written to the `built` folder. If a diff exists right after an apply, the run did not apply that dashboard, or something changed it afterwards.

## Add the check to the pipeline

The script already runs `percli dac diff` before the apply, to show what will change. A second diff after the apply turns the pipeline into its own verifier: the run only succeeds if the server equals the build. The step goes after `percli apply -d built`, with the same command and the heading `== verify`.

You now know two ways to verify the result and where a verify step belongs. The pipeline can now check, deploy and prove its work.

## Common pitfalls

> [!WARNING]
> - **Trusting a green run.** Success means the commands exited with 0, not that the server matches.
> - **Diffing before the build.** The `built` folder holds the last build, which can be old.
> - **Looking in the wrong project.** The API path includes the project name.
