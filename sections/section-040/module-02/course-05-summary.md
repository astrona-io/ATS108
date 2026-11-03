# Summary

A pipeline for a Perses server with authentication logs in with `percli login`, using a username and password or an access token. It uses a dedicated account, and the credentials come from a Kubernetes Secret that the Job reads into environment variables. They are never written in the script or the repository, and the log never prints them.

One script can serve two purposes with a switch. A variable named `MODE` with the default `deploy` lets a Job request `check`, which runs fetch, dependencies, build, lint and diff, and then ends successfully before the apply step. A broken commit still fails a check run, because the earlier steps run with `set -e`. The variable is set on one Job, not on the CronJob.

The `percli` binary, the Perses server and the SDK modules use the same release. Plugins have their own versions, and the repository must use the schemas of the plugins that the server bundles. The tool versions live in the runner script, and the module pins live in `cue.mod/module.cue` and `go.mod`. They are changed together and checked by a full build.

A successful run proves that commands exited with 0. The API list of dashboards and `percli dac diff` after the apply prove that the server holds what the code builds.

- Credentials come from Secrets.
- One script, two modes, one variable on the Job.
- Verify the server after the apply.

<!-- astrona:playground:destroy -->
