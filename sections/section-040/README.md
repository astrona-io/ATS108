# Section 040: A Pipeline For Dashboards

Building and applying by hand works for one person and one dashboard. With a team, someone forgets to build before applying, someone applies a half-finished branch, and a broken dashboard reaches the server between two meetings. A pipeline runs the same steps for every commit, in the same order, and stops at the first error.

This section builds that pipeline as a Kubernetes Job: fetch the repository, build every dashboard, lint the results against the server, show the differences, apply. It also covers the rules that keep the server and Git the same once a pipeline owns the dashboards.

## What you will learn

- What `percli lint` checks with and without `--online`, and why a lint step that checks nothing is worse than none.
- The pipeline steps, their order, and why a failed step must stop the run.
- Running the pipeline as a Kubernetes Job started from a suspended CronJob, and reading its log.
- How a pipeline logs in to a Perses server with authentication on, and what `percli apply` does not do for you.

## The learning path

The module has a landing page, three short parts, a graded lab right after the part it tests, and a summary. The landing page starts the module's playground, with a working pipeline CronJob called `dashboards-pipeline`.

### 1. Lint, Build And Apply Dashboards From A Pipeline

1. Validating Dashboards Before They Ship
2. A Pipeline As A Kubernetes Job
3. Keeping Perses And Git The Same, followed by the lab **Make The Pipeline Refuse Broken Dashboards**
4. Summary

## Section capstone: Run Dashboard-As-Code End To End

The repository holds CUE and Go dashboards, and a pipeline that should ship them all. It ships none: it skips the Go dashboards, it applies into the wrong project, and one Go program breaks its own output. The capstone asks you to fix the pipeline and the code until one run puts every dashboard on the server. Work it after the module lab.

Start the capstone:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS108.git -c sections/section-040/capstone/labs/lab-01
```

When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-040/capstone/labs/lab-01
```

When the capstone is done, remove it:

```sh
astrona destroy ats-108-capstone-040
```
