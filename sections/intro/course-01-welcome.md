# Welcome To The Course

This course trains you for the **Dashboard-as-Code With CUE & Go** part of the Astrona **Perses** training path. That part is 25% of the path. This page tells you who the course is for, what you can do at the end, which words and example setup it uses, and how its pages fit together.

## Who this course is for

You know your way around Kubernetes: namespaces, Deployments, Services, ConfigMaps, `kubectl exec` and `kubectl logs`. You can use Git from the terminal: clone, commit, push and pull. You know what a Perses dashboard is and have read one in JSON: panels, layouts, queries and variables. You do not need to know CUE or Go yet. Each new idea is explained the first time it appears.

## What you can do at the end

A dashboard that only lives in a browser can be changed by anyone, at any time, with no review and no history. This course teaches you to keep dashboards in Git as code and ship them the way you ship software. It asks you to build dashboards, break them, read the errors and fix them, not to remember words. The course has four topics.

The first topic is **the Dashboard-as-Code workflow**. You will learn to:

- Explain what Dashboard-as-Code (DaC) solves and how the CUE and Go SDKs compare.
- Lay out a repository for `percli dac`, build dashboards into the `built` folder and apply them.
- Find changes made in the browser with `percli dac diff` and bring them back under code.

The second topic is **CUE**, a configuration language that checks values against schemas. You will learn to:

- Use the CUE ideas dashboards need: types, constraints, unification, defaults, definitions and packages.
- Build dashboards, panel groups and variables with the Perses CUE builders.
- Share panels between dashboards, and read the build errors CUE gives you.

The third topic is **the Go SDK**. You will learn to:

- Write a dashboard as a Go program that `percli dac build` can run.
- Use the dashboard, panel group, panel, query and variable builders.
- Put shared code in functions and test it, without breaking the build.

The fourth topic is **a pipeline for dashboards**. You will learn to:

- Lint built dashboards against the server.
- Run fetch, build, lint, diff and apply as one Kubernetes Job that stops at the first error.
- Prove that a broken commit applies nothing.

Everything is written for **Perses v0.54.0**, **CUE v0.17.1** and **Go 1.26.5**.

## The words this course uses

The pages use Perses', CUE's and Go's own terms, because those are the words you meet in the tools, the errors and the documentation. Each term gets a short, plain definition the first time it appears on a page. A few terms come back on almost every page, so here they are up front.

**Dashboard-as-Code** means writing dashboards as source files in Git, building them into Perses resources, and applying the result to the server. **`percli`** is the Perses command-line tool. Its `dac` commands set up a repository, build files into dashboards and compare them with the server. **Building** a dashboard turns a CUE file or a Go program into the JSON that Perses stores. **Applying** sends that JSON to the server.

| Command | What it does |
| --- | --- |
| `percli dac build` | Turns CUE files and Go programs into dashboard JSON in the `built` folder |
| `percli apply` | Creates or updates resources on the Perses server from JSON or YAML files |
| `percli dac diff` | Compares built dashboards with the ones on the server |
| `percli lint` | Checks resources before they are applied |

## The example setup in your playground

Every playground and lab runs the same setup. Perses runs in the namespace `perses`, with a project called `inventory` and a datasource called `prometheus`. Prometheus runs in the namespace `observability` and collects metrics from itself and from Perses, so there is always data to show.

The code lives in a Git repository, `gitops/dashboards`, on a Git server called Gitea inside the cluster. You clone it on your own machine, change files and push. A pod called `dac-runner` holds `percli`, `cue` and Go, so you do not have to install them. Every build runs there, on what you pushed.

Many labs start with something broken on purpose. That is the material, not a fault in the course.

## How the course is laid out

The course has four sections. It starts with the workflow, then teaches the two languages, and ends with the pipeline that ships dashboards for you.

| Section | What it covers |
| --- | --- |
| 010 | Why Dashboard-As-Code |
| 020 | CUE For Dashboards |
| 030 | The Go SDK |
| 040 | A Pipeline For Dashboards |

Each section has one or more **modules**, and each module teaches one skill. A module brings together four kinds of material:

| What | What it is for | Graded? |
| --- | --- | --- |
| **Reading** | A short landing page, a few chapters that teach one idea each, and a summary | No |
| **Playground** | A small cluster on your own machine, to try everything you read | No |
| **Lab** | A cluster in a starting state, a task, and a grader that checks your work | Yes |
| **Capstone** | The last lab in a section, with several faults at once | Yes |

The best order is simple: read the chapters with the playground open next to them, take each lab when a chapter sends you to it, and finish each section with its capstone. The next part of this page explains how a module's pages guide you through that order.

## How to read a page

A module starts with a **landing page**. It says what the module teaches, what you should know first, and the order of its chapters. At the bottom of the landing page you start the module's playground, and you keep it running while you read.

The chapters (the parts of a module) read like the chapters of a technical book. Each one opens with the problem it solves, explains one idea in connected paragraphs, and closes with what you now know. The hands-on steps sit right in the text: a sentence or two on what to run and why, the command, and then what the result shows. Run each step in your playground as you reach it. You learn more from one real result than from a page of text.

Every chapter ends with a box of common pitfalls, the mistakes people make most often with what the chapter taught, and how to spot them. Now and then a page also has a tip box with a habit or shortcut you can use again, well beyond that page. The two boxes look like this:

> [!TIP]
> **A tip.** A habit or shortcut you can use again, well beyond this one page.

> [!WARNING]
> **Common pitfalls.** The mistakes people make most often with what you just learned, and how to spot them. Every chapter ends with one.

When a graded lab tests what a chapter taught, that chapter ends with a **Your mission** section. It tells you what the lab asks, then gives every command you need, in order: pause the playground with `astrona stop`, start the lab with `astrona run`, and send your work for grading with `astrona submit`. Solve the lab on your own before you look at its solution. When the lab is done, remove it with `astrona destroy` and start the playground again with `astrona start`, so you can carry on reading where you left off.

The last page of every module is the **Summary**. It sums up what you learned in a few short paragraphs, organised by idea. It also ends the module's hands-on work: the Summary page removes the playground, so your machine is clean before the next module.

One rule holds on every page. Code blocks are exactly what you type. Never change a command to make it "look right". If the result is different from what the page describes, that difference is the lesson.
