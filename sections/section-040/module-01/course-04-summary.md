# Summary

A build that succeeds proves the code is valid, not that the server accepts the dashboard. `percli lint` reads Perses resources from files or folders. Without `--online` or `--plugin.path` it only checks that the files can be read, and still reports that the resources look good. With `--online`, the server validates each dashboard against the plugins it runs and its own custom lint rules. With `--plugin.path`, `percli` loads plugin schemas from archives and checks offline.

A pipeline runs the same steps for every commit: fetch, dependencies, build, lint against the server, diff, apply. `set -e` stops the script at the first failing step, so a broken commit applies nothing; `|| true` or `|| echo` after a step throws that protection away. In this course the pipeline runs as a Kubernetes Job created from a suspended CronJob, with `backoffLimit: 0` so one commit gives one result, and its log shows every step.

A pipeline only creates and updates. It logs in with credentials from a Secret, through `--username` and `--password`, `--token`, or a robot account at an external provider. It never deletes a dashboard whose file was removed; that takes a deliberate `percli delete`. And it overwrites edits made in the browser, which permissions prevent and the diff step makes visible. The key facts to remember are these:

- A plain `percli lint` checks almost nothing; lint with `--online`.
- `set -e` decides whether a broken commit reaches the server.
- `percli apply` never deletes.
- The pipeline's account gets edit rights; people get read rights.

<!-- astrona:playground:destroy -->
