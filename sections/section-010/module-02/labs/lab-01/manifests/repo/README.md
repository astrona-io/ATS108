# dashboards

The Perses dashboards of the `inventory` project, as code.

| Path | What it holds |
| --- | --- |
| `cue.mod/module.cue` | The CUE module and its pinned dependencies |
| `go.mod`, `go.sum` | The Go module and its pinned dependencies |
| `lib/panels/` | Shared CUE panel definitions |
| `lib/boards/` | Shared Go functions and their tests |
| `dashboards/cue/` | One CUE dashboard per file |
| `dashboards/go/<name>/` | One Go dashboard per folder (`main.go`) |

Build everything with `percli dac build -d dashboards -ojson`; the results
land in `built/`, which Git ignores.
