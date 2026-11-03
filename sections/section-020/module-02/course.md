# Generate Dashboards With CUE

A team with ten services does not want ten copies of one dashboard, and does not want to edit ten files when a panel changes. CUE can produce the repeated parts of a dashboard from a short list. This module teaches the CUE features that do that, and the tools that check the result before it is built.

Keep one sentence in mind: **write the list of things once, and let a comprehension produce one panel group for each.** A comprehension is a CUE expression that builds a list or a struct by looping over another one.

The module has four parts. **Lists And Comprehensions** teaches the loop, the condition and string interpolation in small files. **Chained Variables** builds two variables where the second depends on the first. **Generating Panel Groups** produces one panel group per scrape job from a list. **Checking CUE With The CUE Tools** uses `cue fmt`, `cue vet`, `cue eval` and `cue export` to check files. A graded lab follows the third part.

## Learning objectives

After this module you can:

- Write a list comprehension with `for`, and filter it with `if`.
- Build strings and queries with interpolation.
- Keep helper values out of the output with hidden fields.
- Chain two variables with the variable group builder.
- Generate one panel group per item of a list from the shared panel definitions.
- Check a CUE file with `cue fmt`, `cue vet` and `cue eval -e`.

## Before you start

You need the CUE basics of unification, definitions, defaults and packages, the Perses CUE builders for dashboards, panel groups and variables, and the shared panel definitions in `lib/panels`.

Your playground is a single-node `kind` cluster with Perses (project `inventory`, datasource `prometheus`), Prometheus, the Git server Gitea with the repository `gitops/dashboards`, and the `dac-runner` pod with `percli`, `cue` and Go. Every command in the parts runs against the playground.

Launch your playground now, and keep it running next to you while you read the parts:

<!-- astrona:playground -->
