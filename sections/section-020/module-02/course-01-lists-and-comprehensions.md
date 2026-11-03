# Lists And Comprehensions

A dashboard for two scrape jobs and a dashboard for twenty differ only by the length of a list. CUE builds the repeated parts with comprehensions, so the list is the only thing you edit. This part tries comprehensions on small files, away from dashboards, so that you see exactly what each form produces.

## A sandbox helper

The runner resets its copy of the repository before each command, so a sandbox file is written inside the command. This helper writes the text you pass to `/tmp/sandbox.cue` and evaluates it with `--concrete`, as a dashboard build does:

<!-- astrona:playground:renew -->

```sh
dac() { kubectl -n dac exec -i deploy/dac-runner -- dac-run "$@"; }
try_cue() { dac sh -c "printf '%s\n' \"\$1\" > /tmp/sandbox.cue && cue eval /tmp/sandbox.cue --concrete" -- "$1"; }
```

## A list comprehension

A list comprehension is written between square brackets. It loops with `for` over a list and produces one element for each item:

```sh
try_cue 'jobs: ["prometheus", "perses"]
titles: [for j in jobs {j}]'
```

The output has the field `jobs` and the field `titles`, and both hold the same two strings. The loop variable `j` takes each value in turn. The body in braces is the value of the new element, which can be a string, a number or a whole struct.

## Filter with if

An `if` clause after the `for` keeps only the items for which the condition is true:

```sh
try_cue 'jobs: ["prometheus", "perses", "tester"]
real: [for j in jobs if j != "tester" {j}]'
```

The field `real` holds `prometheus` and `perses`. A condition keeps one list for all dashboards and lets a dashboard leave out what it does not need.

## String interpolation

Inside a string, `\(expression)` inserts the value of an expression. The shared panels use it to put the job into a query:

```sh
try_cue 'jobs: ["prometheus", "perses"]
queries: [for j in jobs {"sum(up{job=\"\(j)\"})"}]'
```

Each element is a PromQL query for one job. A quote inside the string needs a backslash, and the interpolation uses the characters backslash and an opening parenthesis.

## Index and struct comprehensions

With two names, `for i, j in jobs`, the first is the index, counted from zero. A comprehension over a struct, `for k, v in someStruct`, loops over its fields and can build a new struct:

```sh
try_cue 'jobs: ["prometheus", "perses"]
numbered: [for i, j in jobs {"\(i): \(j)"}]'
```

The result is `0: prometheus` and `1: perses`.

## Hidden fields

A field whose name starts with an underscore is hidden: it takes part in the evaluation but does not appear in the output. This keeps a helper list out of the built dashboard:

```sh
try_cue '_jobs: ["prometheus", "perses"]
count: len(_jobs)'
```

The output holds only `count: 2`. Without `--concrete` and with `cue eval -H` the hidden field would show; the build never shows it.

You now know the comprehension forms a dashboard needs: a loop, a filter, interpolation, an index and hidden helper values. The open question is how two variables can depend on each other.

## Common pitfalls

> [!WARNING]
> - **Forgetting the braces after the loop.** The part after `for ... in ...` is a value in braces.
> - **Putting the helper list in a normal field.** It appears in the output and fails the dashboard schema. Use a hidden field.
> - **Quotes inside interpolated strings.** A quote in the string needs a backslash.
