# Reading A CUE Build Error

Most of the time you spend with CUE is spent reading errors, so it pays to know the three kinds you meet and what each one tells you to change. All three stop `percli dac build`, and each names a file, a line and the path of a field. This part makes the three errors on purpose, in a sandbox file, and shows how to read them.

## Set up a sandbox file

Evaluate small files with `cue eval` in the runner, not with `percli`, so that you see CUE's own message. The runner resets its copy of the repository before every command, so the file must be in the command itself. This helper writes a file named `sandbox.cue` and evaluates it with the flag `--concrete`, which `percli dac build` uses too:

<!-- astrona:playground:renew -->

```sh
dac() { kubectl -n dac exec -i deploy/dac-runner -- dac-run "$@"; }
try_cue() { dac sh -c "printf '%s\n' \"\$1\" > /tmp/sandbox.cue && cue eval /tmp/sandbox.cue --concrete" -- "$1"; }
```

Each call below passes the file content as one string, so you can change a line and run it again.

## Error 1: conflicting values

A conflict happens when two values for one field cannot both be true. Try a Stat panel with two different calculations:

```sh
try_cue 'a: {calculation: "last"}
a: {calculation: "mean"}'
```

CUE reports that the field `a.calculation` has conflicting values `"mean"` and `"last"`, and it names the line of each. The fix is to decide which value is right and remove the other. In a dashboard, this error usually means a shared definition sets a value and the dashboard sets a different one.

## Error 2: a field that is not allowed

A definition is closed, so a value unified with it may only use the fields it declares. Try a misspelled field:

```sh
try_cue '#Panel: {name: string, height: int}
p: #Panel & {name: "x", height: 8, hieght: 9}'
```

CUE reports that the field `hieght` is not allowed in `#Panel`. The error names the field, not the value, because the problem is the name. The fix is to correct the spelling. When the error names a field you did write correctly, the schema of the plugin version you pinned may not have that field.

## Error 3: an incomplete value

A value is incomplete when CUE cannot decide it. Try a field with a type and no value:

```sh
try_cue 'p: {name: string, height: int & >0 & <=24}
p: name: "x"'
```

Without `--concrete`, CUE accepts this file, because a type is a valid value. With `--concrete`, CUE reports that `p.height` is an incomplete value, and it prints the constraint it still has: an integer greater than 0 and less than or equal to 24. The fix is to set the field. In a dashboard this happens when a parameter has no default and the dashboard does not set it.

## Reading the path

Every CUE error starts with a field path, such as `spec.plugin.spec.calculation`, followed by a message and one or more file positions. Read the path from the right: the last name is the field that failed, and the names before it show where it sits in the output. When a shared definition is used in several places, a path that begins with the dashboard's own field names shows which dashboard you were building. The file positions can list the shared package and the dashboard, because the value comes from both.

You now know the three failures, a conflict, a field that is not allowed and an incomplete value, and how to read a path. The open question is how to produce many similar parts of a dashboard without copying them, which needs lists and loops.

## Common pitfalls

> [!WARNING]
> - **Changing the schema to remove the error.** The schema is the rule. Fix the value that breaks it.
> - **Testing without `--concrete`.** A file can evaluate cleanly and still fail the build, because the build requires every field to be concrete.
> - **Reading only the first position.** A conflict lists two positions. The one you need to change is usually the one in your own file.
