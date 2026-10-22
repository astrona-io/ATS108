# CUE Essentials For Dashboards

The Perses CUE builders are written in CUE, and their errors are CUE errors. You do not need the whole language to use them, but you need five ideas: values, constraints, defaults, unification and definitions. This part shows each one on a small file you build in the runner, before any dashboard is involved.

## Set up a sandbox in the repository

The runner builds what is pushed to `main`, so small experiments also go through Git. Start the Gitea port-forward in a second terminal (`kubectl -n gitea port-forward svc/gitea-http 3000:3000`), clone the repository if you have not yet, and define the helper:

<!-- astrona:playground:renew -->

```sh
git clone http://gitops:gitops-password@gitea.localtest.me:3000/gitops/dashboards.git
cd dashboards
dac() { kubectl -n dac exec -i deploy/dac-runner -- dac-run "$@"; }
```

Create a folder called `sandbox` in your clone for the experiments in this part. It is outside `dashboards`, so the dashboard build never picks it up.

## Types are values, and constraints narrow them

In CUE, `string` is a value: the set of all strings. `"Targets up"` is a narrower value inside that set. A constraint such as `int & >0 & <=24` is the set of whole numbers from 1 to 24. Writing a field twice does not overwrite it; CUE **unifies** the two values with `&`, which keeps only what both allow.

Save this as `sandbox/panel.cue`:

```cue
package sandbox

#Panel: {
	name:        string
	calculation: "first" | *"last" | "mean" | "sum"
	height:      int & >0 & <=24
}

overview: #Panel & {
	name:   "Targets up"
	height: 8
}
```

`#Panel` is a **definition**: a field whose name starts with `#`. It describes a shape and is not part of the output. `calculation` is a **disjunction**, a choice between listed values, and the `*` marks the **default**: the value CUE picks when nothing else decides. `overview` unifies the definition with concrete values.

Push it and evaluate it in the runner:

```sh
git add sandbox && git commit -m "Add a CUE sandbox" && git push
dac cue eval sandbox/panel.cue
```

The result shows `overview` with `name: "Targets up"`, `height: 8`, and `calculation: "last"`. You never wrote the calculation: the default filled it in. The definition `#Panel` is printed too, as the schema it is.

## Conflicts stop the evaluation

Now break each rule once. In `sandbox/panel.cue`, change `height: 8` to `height: 30` and add a field `color: "red"` to `overview`. Push, and evaluate again:

```sh
git commit -am "Break the sandbox panel" && git push
dac cue eval sandbox/panel.cue
```

The evaluation fails with two errors, each naming a path. For `overview.height`, CUE reports that `30` is out of the bound `<=24`. For `overview.color`, it reports that the field is not allowed. That second error comes from **closedness**: a definition is closed, so a value unified with it may only use the fields the definition declares. This is how a plugin schema rejects a misspelled field.

## Incomplete values and --concrete

Remove the two broken lines, and also remove `height: 8`. The file is valid again, but `overview.height` is now only a constraint, not a number. Evaluate it the way `percli dac build` does, with JSON output and the `--concrete` flag:

```sh
git commit -am "Leave height undecided" && git push
dac cue eval sandbox/panel.cue --out json --concrete
```

The command fails: `--concrete` requires every output field to have one final value, and `height` does not. Without `--concrete` the same file evaluates without an error. A dashboard build always uses `--concrete`, so every field must end up decided, either by you or by a default.

## Packages and modules

Every CUE file starts with a `package` clause. Files with the same package in the same folder form one package, and another package uses it with an `import`. The repository is a CUE **module** called `example.com/dashboards@v0`, declared in `cue.mod/module.cue`. That file also lists the modules it depends on, each with an exact version, for example `github.com/perses/perses/cue@v0` at `v0.54.0`. CUE downloads those from the CUE Central Registry the first time a build needs them.

A package of the module itself is imported by its path in the module. A dashboard in `dashboards/cue` imports the shared panels with `"example.com/dashboards/lib/panels"` and uses them as `panels.#TargetsUp`. A package from a dependency is imported the same way, for example `"github.com/perses/perses/cue/dac-utils/dashboard"`.

You now know the CUE ideas the Perses SDK relies on: unification, constraints, defaults, closed definitions, and packages. The open question is what the SDK's builders expect from you.

## Common pitfalls

> [!WARNING]
> - **Expecting a second value to overwrite the first.** CUE unifies. `height: 8` and `height: 12` in the same value is a conflict, not an update.
> - **Adding a field to a value unified with a definition.** Definitions are closed. A misspelled field is an error, not an extra field.
> - **Testing without `--concrete`.** A file can evaluate cleanly and still fail the dashboard build, because the build requires every field to be decided.
