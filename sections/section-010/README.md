# Section 010: Why Dashboard-As-Code

A dashboard that only exists on a Perses server can be changed by anyone with access, at any time, with no review and no history. When it breaks, nobody knows what it looked like yesterday. Dashboard-as-Code (DaC) fixes this by keeping dashboards as source files in Git and building them into Perses resources.

This section teaches the loop every later page uses. You change a file in Git and push it. Then `percli`, the Perses command-line tool, builds the file into a dashboard, applies it to the server, and compares the server with the code.

## What you will learn

- What Dashboard-as-Code solves, and how the CUE software development kit (SDK) and the Go SDK compare.
- How a DaC repository is laid out, and what `percli dac setup` prepares.
- Building CUE files and Go programs into dashboards with `percli dac build`, and where the results go.
- Applying built dashboards with `percli apply`, and checking them on the server.
- Finding changes made in the browser with `percli dac diff`.

## The learning path

The module has a landing page, three short parts, a graded lab right after the part it tests, and a summary. The landing page starts the module's playground: Perses with the project `inventory`, Prometheus, a Git server with the repository `gitops/dashboards`, and the `dac-runner` pod where every build runs.

### 1. Build And Apply Your First Dashboard As Code

1. Dashboards As Code
2. The Repository And The Build
3. Applying And Diffing Built Dashboards, followed by the lab **Build And Apply A CUE Dashboard**
4. Summary

## Section capstone: Bring A Hand-Edited Dashboard Back Under Code

Someone fixed the scrape health dashboard in the browser instead of in Git. One of the two changes is worth keeping; the other is a mistake. The capstone asks you to find both with `percli dac diff`, move the good one into the code, and make the server match the code again. Work it after the module lab.

Start the capstone:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS108.git -c sections/section-010/capstone/labs/lab-01
```

When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-010/capstone/labs/lab-01
```

When the capstone is done, remove it:

```sh
astrona destroy ats-108-capstone-010
```
