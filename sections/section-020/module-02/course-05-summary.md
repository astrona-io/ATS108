# Summary

A comprehension builds a list or a struct by looping over another value. `for` loops over a list, `if` filters, and `\(expression)` inserts a value into a string. With two names the first is the index. A field whose name starts with an underscore is hidden, so a helper list takes part in the evaluation without appearing in the dashboard.

The variable group builder chains variables in list order. It gives the datasource to each variable and passes the earlier variables to the later ones, which use them as label filters in their matchers. The broadest variable goes first.

A list of jobs and a comprehension produce one panel group per job. Each group takes the shared panel definitions with the job as a parameter, so queries stay in the shared package and adding a job changes one line. The `cue` tools check files faster than a full build: `cue fmt` formats, `cue vet -c` checks that a file is valid and concrete, `cue eval -e` prints one expression, and `cue export` produces the same output the build does.

- Keep data in hidden fields and structure in comprehensions.
- Order chained variables from broad to specific.
- Never write a query in a dashboard that a shared panel already holds.

<!-- astrona:playground:destroy -->
