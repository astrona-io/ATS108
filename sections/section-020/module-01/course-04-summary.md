# Summary

CUE writes schemas and values the same way. A type such as `string` is the set of all strings, and a constraint such as `int & >0 & <=24` narrows it. Writing two values for one field unifies them with `&`, which keeps only what both allow and fails when they conflict. A disjunction lists allowed values, and `*` marks the default CUE picks when nothing else decides.

A definition, a field whose name starts with `#`, describes a shape and is not part of the output. It is closed: a value unified with it may only use the fields it declares, which is how a plugin schema rejects a misspelled field. `cue eval --concrete`, which every dashboard build uses, also requires every output field to have one final value.

The repository is a CUE module with its dependencies pinned in `cue.mod/module.cue`. Files with the same `package` clause form a package, and other files import it by its path in the module. The Perses builders take inputs in fields that start with `#`. The dashboard builder reads `#name`, `#project`, `#display`, `#duration`, `#variables` and `#panelGroups`. The panel groups builder places panels on a 24-unit grid and keys them by group and position. The variable group builder passes a datasource to each variable and chains them.

A shared definition keeps its parameter beside the panel it produces, so the closed panel schema stays strict, and a dashboard takes the panel from its `panel` field. A wrong value in the library stops the build of every dashboard that uses it, before anything reaches the server. The key facts to remember are these:

- Unification combines values; it never overwrites.
- Definitions are closed; an unknown field is an error.
- Plugin schemas are imported with the `:model` suffix.
- Fix the value a schema rejects, never the schema.

<!-- astrona:playground:destroy -->
