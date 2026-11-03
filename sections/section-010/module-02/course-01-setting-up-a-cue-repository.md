# Setting Up A CUE Repository

Every CUE dashboard imports the Perses SDK, and the import only works inside a CUE module that lists the SDK as a dependency at a version. Without a module, `cue eval` cannot find the packages. This part creates a module from an empty folder and lets `percli dac setup` fill it in.

## Create the module

A CUE module is a folder with a file `cue.mod/module.cue`. The command `cue mod init` creates it and takes the module path, the name other files use to import packages of this module. Make a scratch folder in the runner and initialise it:

<!-- astrona:playground:renew -->

```sh
dac() { kubectl -n dac exec -i deploy/dac-runner -- dac-run "$@"; }
dac sh -c 'rm -rf /tmp/newrepo && mkdir /tmp/newrepo && cd /tmp/newrepo && cue mod init example.com/newrepo && cat cue.mod/module.cue'
```

The file holds the module path and the CUE language version. It has no dependencies yet. A module with no dependencies cannot import the Perses packages, so the next step adds them.

## Let percli prepare the module

The command `percli dac setup` prepares a folder for the CUE SDK. It needs the module to exist. It writes an example dashboard file, `example.cue`, and then runs `cue mod tidy`. The command `cue mod tidy` finds every import in the module's files, downloads the modules they need from the CUE Central Registry, and records their versions in `cue.mod/module.cue`.

The command also needs to know which SDK version to use. It asks the Perses server it is logged in to. In the runner, `percli` is already logged in, so no flag is needed:

```sh
dac sh -c 'cd /tmp/newrepo && percli dac setup && cat cue.mod/module.cue && ls'
```

The module file now lists the Perses modules with exact versions, and the folder holds `example.cue`. With no server connection, you pass the version yourself with `--version 0.54.0`. Matching the SDK to the server matters because the dashboard schema and the plugin schemas change between versions.

## Build the example

The example is a complete dashboard. Build it to prove the setup works, writing to standard output:

```sh
dac sh -c 'cd /tmp/newrepo && percli dac build -f example.cue -ojson -m stdout | jq ".metadata"'
```

The metadata shows the name and project that the example sets. The build ran `cue eval` with `--concrete` on the file, and every import resolved because `cue mod tidy` had already recorded the dependencies.

## What to commit

Commit `cue.mod/module.cue` and your source files. The module file is what makes the build repeatable: another machine with the same file downloads the same versions. The command also adds the folder `built` to an existing `.gitignore`, so build results stay out of Git.

You now know that a CUE repository needs a module, that `percli dac setup` fills in the dependencies for the server's version, and that the module file is what you commit. The open question is how the same setup works for Go.

## Common pitfalls

> [!WARNING]
> - **Running `percli dac setup` before `cue mod init`.** The command needs the module to exist.
> - **Choosing a different version from the server.** The schemas may not match the plugins the server runs.
> - **Deleting `cue.mod/module.cue` to fix a dependency error.** Run `cue mod tidy` instead, so the versions are recorded again.
