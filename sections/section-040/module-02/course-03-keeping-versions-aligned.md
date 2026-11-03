# Keeping Versions Aligned

A dashboard build uses several tools that must agree: the `percli` binary, the Perses server, the Go and CUE SDKs and the plugin modules. A mismatch rarely shows up as a clear error. It shows up as a field that the server rejects or a plugin that fails to load. This part lists where each version is set, and how to read them.

## The versions that must agree

The Perses server and `percli` use the same release number: the playground pins both to v0.54.0. The SDKs are modules of the same release, so the CUE module `github.com/perses/perses/cue` and the Go module `github.com/perses/perses` are pinned to v0.54.0 as well. The plugins have their own release numbers. The server bundles one version of each plugin, and the repository must use schemas for that version.

Read the server image in the playground:

<!-- astrona:playground:renew -->

```sh
kubectl -n perses get pods -o jsonpath='{.items[*].spec.containers[*].image}'
```

The image tag is the server version.

## Where the runner sets its tools

The runner and the pipeline Job install `cue` and `percli` from the same script in the ConfigMap `dac-runner-scripts`. Print it to read the versions:

```sh
kubectl -n dac get configmap dac-runner-scripts -o jsonpath='{.data.install-tools\.sh}'
```

The script downloads one release of each binary. Because the runner and the Job share this script, a change to a version changes both at once.

## Where the repository pins its modules

The repository pins its CUE dependencies in `cue.mod/module.cue` and its Go dependencies in `go.mod`. Read them in the runner:

```sh
dac() { kubectl -n dac exec -i deploy/dac-runner -- dac-run "$@"; }
dac sh -c 'grep -n "v0\." cue.mod/module.cue; grep -n "perses" go.mod'
```

The CUE file lists the Perses module and each plugin with its version. The Go file lists the Perses module and the plugin modules. When you upgrade the server, change these pins in one commit and build all dashboards before you merge, so that a schema change shows as a build error in the pipeline, not in the browser.

## Upgrade in this order

Upgrade a test server first and build against it. Then change the pins in the repository and the tool versions in the runner script together. A pipeline run in check mode on a branch shows any problem before `main` changes.

You now know where each version is set. The open question is how to prove after a run that the server matches the code.

## Common pitfalls

> [!WARNING]
> - **Upgrading `percli` alone.** The server and the SDK modules use the same release.
> - **Changing a pin without a full build.** Build every dashboard, not only the one you edited.
> - **Assuming plugin versions equal the Perses version.** Plugins have their own numbers.
