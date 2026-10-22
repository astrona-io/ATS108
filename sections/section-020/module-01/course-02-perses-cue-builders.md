# The Perses CUE Builders

A Perses dashboard has a strict shape: panels in a map, layouts that point at panels by reference, variables in a list. Writing that shape by hand is slow and easy to get wrong. The Perses CUE builders produce it from a few inputs. This part reads the overview dashboard of the repository line by line and builds it, so you know what each builder expects and what it produces.

## The dashboard builder

Open the dashboard in the runner and keep it next to you:

<!-- astrona:playground:renew -->

```sh
dac() { kubectl -n dac exec -i deploy/dac-runner -- dac-run "$@"; }
dac cat dashboards/cue/prometheus-overview.cue
```

The file imports the builders it uses and gives each a short name, for example `dashboardBuilder "github.com/perses/perses/cue/dac-utils/dashboard"`. The body is one value: `dashboardBuilder & { ... }`. The builder declares its inputs as definitions, so you fill in fields that start with `#`, and it produces the dashboard resource as its output:

| Input | What it sets |
| --- | --- |
| `#name` | `metadata.name`, the dashboard's identifier |
| `#project` | `metadata.project` |
| `#display` | `spec.display`, for example the title shown in the browser |
| `#duration` | `spec.duration`, the default time range, for example `"1h"` |
| `#variables` | `spec.variables`, a list of variables |
| `#panelGroups` | `spec.panels` and `spec.layouts`, from the panel groups |
| `#datasources` | `spec.datasources`, datasources embedded in the dashboard |

The overview dashboard does not embed a datasource. Its queries name the project datasource `prometheus`, which already exists in the project `inventory`, so every dashboard of the project shares one connection to Prometheus.

## Panel groups

`#panelGroups` takes `panelGroupsBuilder & {#input: [...]}`, a list of groups. Each group has a `#title`, a number of columns `#cols`, and a list of `#panels`. The builder places the panels on a grid 24 units wide: with `#cols: 2`, each panel is 12 units wide, and the third panel starts a new row. It gives each panel a key made of the group's position and the panel's position, so the first panel of the second group is `1_0`. The layout items refer to the panels by those keys.

Build the dashboard and look at the keys and the layout it produced:

```sh
dac sh -c 'percli dac build -f dashboards/cue/prometheus-overview.cue -ojson -m stdout | jq "{panels: (.spec.panels | keys), layouts: [.spec.layouts[] | {title: .spec.display.title, items: [.spec.items[] | .content[\"\$ref\"]]}]}"'
```

The result lists the panel keys `0_0`, `0_1` and `1_0`. The layout `Scrape health` refers to `#/spec/panels/0_0` and `#/spec/panels/0_1`, and the layout `Storage` refers to `#/spec/panels/1_0`. You wrote two short lists; the builder wrote the map, the grid positions and the references.

## Variables

The dashboard has one variable, `job`, which lists the values of the label `job` on the metric `up`. It uses two builders. The label values builder from the Prometheus plugin, `labelValuesVarBuilder`, takes `#name`, `#display` and `#metric`. The variable group builder, `varGroupBuilder`, takes a list of variables in `#input` and a `#datasourceName` it passes to each of them. The group's output field `variables` goes into `#variables`.

The group builder exists for chained variables. When a dashboard has a `cluster`, a `namespace` and a `pod` variable, each one should only list values that match the ones before it. The group builder passes the earlier variables to each later one, and the Prometheus builders turn them into label filters. With a single variable, the filter is empty.

Read the built variable:

```sh
dac sh -c 'percli dac build -f dashboards/cue/prometheus-overview.cue -ojson -m stdout | jq ".spec.variables"'
```

The output has one `ListVariable` named `job`, whose plugin is `PrometheusLabelValuesVariable` with `labelName: "job"`, a matcher `up{}`, and the datasource `prometheus`. A panel uses the selected value by writing `$job` in its query.

## Plugins and their schemas

Each panel's `plugin` comes from a plugin's schema package, imported with a `:model` suffix, for example `"github.com/perses/plugins/statchart/schemas:model"`. The suffix selects the CUE package called `model` inside that folder. The schema fixes the plugin `kind` and describes its `spec`. For the Stat chart, `calculation` must be one of `first`, `last`, `first-number`, `last-number`, `mean`, `sum`, `min` or `max`, with `last` as the default. Because the `spec` is closed, any other field or value stops the build.

You now know what the dashboard, panel group and variable builders take and what they produce. The panels themselves came from somewhere else: the shared package `lib/panels`. The open question is how that package is written, and what happens when it is wrong.

## Common pitfalls

> [!WARNING]
> - **Setting output fields instead of inputs.** The builders read fields that start with `#`. Writing `metadata: name:` yourself conflicts with what the builder produces.
> - **Expecting panel keys to follow names.** Keys follow positions (`1_0` is the first panel of the second group). Moving a panel changes its key.
> - **Forgetting `:model` on a schema import.** Without it, CUE looks for a package with the folder's name and does not find the plugin schema.
