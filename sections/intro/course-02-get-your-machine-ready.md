# Get Your Machine Ready

Every playground and lab in this course runs on your own machine, in a small Kubernetes cluster. A tool called `astrona` builds it for you, sets it up, grades your work and removes it again. This page gets your machine ready: first the tools you need, then the handful of `astrona` commands you will use every day, and last what to do when a start goes wrong.

## What you need

Every section needs the same set of tools. Install these before you start:

- **A container engine:** Docker or Podman. The cluster runs inside it.
- **`kind`:** runs Kubernetes inside the container engine.
- **`kubectl`:** talks to the cluster. You run every `percli`, `cue` and `go` command through it, inside the `dac-runner` pod.
- **`git`:** you clone the dashboards repository, commit and push from your own machine.
- **A text editor** for CUE and Go files. An editor with CUE and Go support helps, but is not needed.
- **The astrona command-line tool.**
- **A web browser:** some pages open the Perses web interface to look at a dashboard.

You do not need to install Perses, CUE or Go. The environments install Helm 3.22.1 on your machine for their own setup, and the `dac-runner` pod brings `percli` v0.54.0, `cue` v0.17.1 and Go 1.26.5.

The playgrounds and labs need **outbound internet** while they start and the first time they build: the container images, the Perses Helm chart, the Go module proxy and the CUE module registry. Without it, starts and first builds fail with network errors that have nothing to do with Perses. Plan on about **4 GiB** of memory for one environment.

## Reaching Perses and the Git server

Perses and the Git server run inside the cluster, so your machine reaches them through port-forwards. Pages that use `git` or the browser ask you to start both in a second terminal and leave them running:

```sh
kubectl -n gitea port-forward svc/gitea-http 3000:3000 &
kubectl -n perses port-forward svc/perses 8080:8080
```

The addresses are always `http://gitea.localtest.me:3000` for Git and `http://perses.localtest.me:8080` for Perses. The name `localtest.me` and every name under it is a public DNS name that points at `127.0.0.1`, your own machine, so the port-forwards answer them. Inside the cluster, the same names point at the real Services, so the runner and you use the same addresses.

Some home routers block DNS answers that point at `127.0.0.1`. If `git clone` says it cannot resolve `gitea.localtest.me`, add these lines to `/etc/hosts` on your machine:

```
127.0.0.1 gitea.localtest.me
127.0.0.1 perses.localtest.me
```

The Git server uses plain HTTP and the lab-only user `gitops` with the password `gitops-password`. A real Git server uses HTTPS or SSH and real credentials.

You do not have to check your tools by hand. Let `astrona` look at your machine for you:

```sh
astrona setup
```

`astrona setup` looks at what is missing, shows you each step it would take, and asks before it does anything. On macOS it can install `kind`, `kubectl` and Podman. Install `git` yourself.

Later, you can check your machine at any time:

```sh
astrona check
```

## The commands you use every day

Once your machine is ready, you need only a handful of `astrona` commands. Each module page and lab page shows the exact command to copy, so you do not need to remember paths. This section walks through them in the order you meet them: sign in, start, pause, submit and clean up.

Labs from the course catalog are tied to your Astrona account, so you sign in first:

```sh
astrona login
```

Next you start a playground or a lab. Each module page and lab page shows the exact `astrona run` command for it. It looks like this:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS108.git -c sections/section-010/module-01/playground
```

When the cluster is ready, `kubectl` already points at it.

A chapter that sends you to a lab asks you to pause the playground first. Pausing frees your machine's memory but keeps everything you built:

```sh
astrona stop <name>
```

When the lab is done, start the playground again and carry on where you left off:

```sh
astrona start <name>
```

Inside a lab, you send your work for grading with `astrona submit`. The grader checks the live cluster. It builds the code at the head of `main` and compares it with what Perses serves, so your fix has to actually work, not only make an error message go away. Each lab page shows the exact command:

```sh
astrona submit -c sections/section-010/module-01/labs/lab-01
```

You can submit as often as you like.

When you are done with a playground or a lab, remove it:

```sh
astrona destroy <name>
```

The name is the environment's name, printed by `astrona run` and shown on each page (for example `ats-108-playground-010-01`). It is not the folder path. To see what is on your machine, list it:

```sh
astrona list
```

> [!WARNING]
> **Run one environment at a time.** Each playground and lab is a whole cluster with its own Perses, Git server and runner. Two running at once can use up your machine's memory, and it is easy to send a command to the wrong one. Pause or destroy the playground before you start the lab.

## When a start goes wrong

Sometimes a playground or lab does not start cleanly. Ask `astrona` what is wrong before you try anything else:

```sh
astrona doctor
```

It checks your machine, the lab's configuration and the running lab, and tells you how to fix what it finds.

If a start fails while it downloads something, check your network first. If `git` cannot reach the repository, check that the port-forward is still running in your second terminal; it stops when the playground restarts. If the first build in a new environment is slow, it is downloading Go and CUE modules; the next builds are fast. Remember also that a lab that starts with a build that fails is often broken on purpose: the lab's task tells you when that is the case. With your machine ready and these commands at hand, you can start the first module.
