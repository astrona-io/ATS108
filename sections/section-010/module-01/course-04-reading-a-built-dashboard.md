# Reading A Built Dashboard

Every build ends in one JSON document, and every error message, diff and API response in the rest of the workflow talks about that document. If you can read it, you can tell what a change in the source did, which part of the dashboard a diff line belongs to, and why Perses shows a panel where it does. This part opens a built dashboard and names each of its parts.

## The three top-level fields

A Perses dashboard is a resource. Print the top-level fields of the overview dashboard as the build produces them:

<!-- astrona:playground:renew -->

```sh
dac() { kubectl -n dac exec -i deploy/dac-runner -- dac-run "$@"; }
dac sh -c 'percli dac build -f dashboards/cue/prometheus-overview.cue -ojson -m stdout | jq "keys"'
```

The result lists `kind`, `metadata` and `spec`. The `kind` is `Dashboard`: it tells the server which type of resource this is. The `metadata` holds the identity of the resource: its `name` and the `project` it belongs to. The `spec` holds everything the dashboard shows. `percli apply` reads `kind` and `metadata.project` to decide where the resource goes, and `percli dac diff` compares only the `spec`.

## What the spec holds

Print the field names of the `spec`:

```sh
dac sh -c 'percli dac build -f dashboards/cue/prometheus-overview.cue -ojson -m stdout | jq ".spec | keys"'
```

The overview dashboard has these fields in its `spec`:

| Field | What it holds |
| --- | --- |
| `display` | The title shown in the browser |
| `duration` | The default time range, for example `1h` |
| `variables` | The list of variables, such as `job` |
| `panels` | A map from a panel key to the panel definition |
| `layouts` | A list of grids that place panels on the page |

A dashboard can also hold `datasources`, which are datasources defined inside the dashboard instead of the project, and a refresh interval. The overview dashboard sets neither.

## Panels and layouts are separate

The most surprising part of the format is that a panel does not say where it is on the page. The `panels` map only describes what each panel is. The `layouts` list describes where panels go, and it points at them by key.

Print the layout:

```sh
dac sh -c 'percli dac build -f dashboards/cue/prometheus-overview.cue -ojson -m stdout | jq ".spec.layouts[0]"'
```

The layout has the kind `Grid`. Its `spec.display.title` is the title of the panel group. Its `spec.items` is a list, and each item has the position fields `x`, `y`, `width` and `height` on a grid 24 units wide, and a `content` field with a `$ref`. The `$ref` is a reference such as `#/spec/panels/0_0`. It names the panel by its key. Two layouts can hold references to the same panel, and a panel that no layout refers to is on the server but never shown.

## What a panel holds

Print one panel:

```sh
dac sh -c 'percli dac build -f dashboards/cue/prometheus-overview.cue -ojson -m stdout | jq ".spec.panels[\"0_0\"]"'
```

A panel has a `kind` of `Panel` and a `spec` with three parts. The `display` gives the panel name. The `plugin` says which chart draws the data: its `kind` is the plugin name, for example `StatChart` or `TimeSeriesChart`, and its `spec` holds the options of that chart. The `queries` list holds one or more queries. Each query has the kind `TimeSeriesQuery` and its own `plugin`; for Prometheus the plugin kind is `PrometheusTimeSeriesQuery`, and its `spec` has the PromQL `query` and the `datasource` to ask, by kind and by name.

This is the reason a plugin version matters. The `spec` of a plugin is checked against that plugin's schema, so a field that exists in one version of a plugin may not exist in another.

## YAML instead of JSON

The server stores JSON, but `percli` also reads YAML. Build the same file as YAML:

```sh
dac sh -c 'percli dac build -f dashboards/cue/prometheus-overview.cue -oyaml -m stdout | head -12'
```

The content is the same resource, written as YAML, and `percli apply` accepts either file. The first lines show `kind: Dashboard`, the `metadata` and the start of the `spec`. YAML is easier to read in a review; JSON is what the API returns, so JSON compares directly with API responses.

You now know the shape of what every build produces: `kind`, `metadata` and a `spec` of display, duration, variables, panels and layouts, with panels and their positions kept apart. The open question is how a repository is prepared so that this build works at all, and how its output can be steered.

## Common pitfalls

> [!WARNING]
> - **Looking for the position inside the panel.** Position and size live in the layout item, not in the panel.
> - **Editing a panel key by hand.** A layout refers to a panel by its key. Rename the key in one place and the reference breaks.
> - **Reading a panel that no layout refers to as part of the page.** Only referenced panels are shown.
