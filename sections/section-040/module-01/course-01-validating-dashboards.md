# Validating Dashboards Before They Ship

A build that succeeds proves the code is valid CUE or Go. It does not prove the server will accept the dashboard: a plugin the server does not know, or a rule your organisation has for dashboard names, is only checked against the server. `percli lint` is the step between the build and the apply. This part shows what it checks, and the one way to call it that checks nothing at all.

## Lint the built dashboards

Build every dashboard of the repository, then lint the results without any flag:

<!-- astrona:playground:renew -->

```sh
dac() { kubectl -n dac exec -i deploy/dac-runner -- dac-run "$@"; }
dac sh -c 'rm -rf built && percli dac build -d dashboards -ojson && percli lint -d built'
```

`percli lint -d built` reads every `.json`, `.yaml` and `.yml` file in `built` and its subfolders, and reports that your resources look good. That sounds like a pass. Now give it a dashboard that is clearly wrong: copy one built file and change a panel's plugin to a kind that does not exist.

```sh
dac sh -c 'percli dac build -f dashboards/cue/prometheus-overview.cue -ojson -m stdout | jq ".spec.panels[\"0_0\"].spec.plugin.kind = \"NoSuchChart\"" > /tmp/bad.json && percli lint -f /tmp/bad.json'
```

It reports that the resources look good again. Without extra flags, `percli lint` only checks that each file can be read as a Perses resource. It has no plugin schemas to check the panels against, so it validates nothing else and still says the resources look good.

## Lint against the server

The flag `--online` sends each dashboard to the Perses server's validation endpoint. The server knows every plugin it has loaded, with its schema, and it applies the custom lint rules in its own configuration. Lint the broken file again, this time online:

```sh
dac percli lint -f /tmp/bad.json --online
```

This time the command fails, with an error from the server about the panel's plugin. The server rejected a dashboard that the plain lint called good. Lint the real built dashboards online, and they pass:

```sh
dac percli lint -d built --online
```

The other way to give `percli lint` something to check is `--plugin.path`, a folder with the plugin archives, such as the `plugins-archive` folder of the Perses release archive. `percli` then loads the plugin schemas itself and checks offline. Online linting is simpler in a pipeline that can reach the server, and it always uses the plugins the server really runs.

## Custom lint rules

An organisation can add its own rules, such as "dashboard names use lower case and hyphens only" or "every dashboard has at least one panel". Each rule has a `name`, a `target` (a JSONPath expression that picks part of the dashboard), an `assertion` (a CEL expression, the Common Expression Language, that must be true for that part), and a `message`. On the server, the rules go into the configuration under `dashboard.custom_lint_rules`, and `--online` applies them. A rules file passed with `--custom-rule.path` is only used together with `--plugin.path`; with `--online`, the server's rules apply instead.

You now know what `percli lint` checks, and that only `--online` or `--plugin.path` make it check anything beyond the file format. The open question is how to chain the build, the lint and the apply so that one failure stops all of it.

## Common pitfalls

> [!WARNING]
> - **Trusting a plain `percli lint`.** Without `--online` or `--plugin.path` it reports that the resources look good for almost anything it can read.
> - **Linting the source instead of the build.** `percli lint` reads Perses resources. Lint the files in `built`.
> - **Expecting `--custom-rule.path` to add to the server's rules.** With `--online`, the server's own rules are the ones applied.
