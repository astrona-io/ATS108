# Writing style for this repo

All study text here (course pages, lab docs, READMEs, comments in YAML and
scripts) is for people learning a technical subject, often for a
certification exam. Many of them are not native English speakers and have no
university degree.

## Technical documentation in plain English

This is technical documentation. Say exactly what the system does, with the
real technical terms, in clear and simple English. Never hide a concept
behind a metaphor, a made-up name or a vague word: the reader must learn the
words they will meet in the product, the logs and the exam.

Strict guidelines:

1. Use the correct technical term every time (request, response, pod,
   namespace, Service, sidecar proxy, certificate, mTLS, JWT, listener). The
   first time a term appears in a file, define it in one plain sentence that
   says what it is and what it does. Spell out every acronym on first use.
2. No metaphors or analogies in explanations. Not "the communications
   officer", but "the sidecar proxy (Envoy)"; not "a signal", but "a
   request"; not "the planet", but "the namespace".
3. Simple sentences. Target a Flesch-Kincaid Grade Level of 8 or 9 for the
   prose around the terms. Keep sentences direct; split long sentences into
   two. No corporate buzzwords.
4. Use short paragraphs (max 3-4 sentences per paragraph).
5. Use the active voice ("istiod sends the configuration", not "the
   configuration is sent").

## How this applies to course material

- **Know which file you are in.** A module has a short landing page, a few
  deep-dive parts and a summary page. The landing page is a map: goals, what
  to know first, the order of the parts. The real teaching goes in the parts.
  The summary closes the module. A lab
  has a task, a step-by-step solution and a short intro. Keep each file to its
  job. Do not add "Prerequisite: ... Next: ..." navigation lines to pages;
  the landing page and the course outline already give the order.
- **Keep each part short.** One idea per part, about 5 to 8 minutes of
  reading and at most about 8 command blocks, so a learner can finish it with
  the playground in one sitting of about 15 minutes. Split at a natural seam
  where each half ends with something the learner has seen work. Never split
  only to hit a number. When you split, renumber the files, fix every "Part N"
  reference in the module and `astrona.yaml`.
- **Read like a book, not like a web page.** Each part reads as a chapter of
  a technical book. Open with a short paragraph on the problem it solves and
  why it matters. Link each paragraph to the next with a transition sentence.
  Close with a paragraph that sums up what the reader now knows and the
  question still open, before `## Common pitfalls` and the mission. Write
  explanations as prose; keep bullets for real lists (fields, ordered steps,
  options). Use `##` only when the topic changes and `###` only inside a long
  section, never for a single command. Weave hands-on steps into the text:
  one or two sentences on what to run and why, the command, the real output,
  then a sentence or two on what it shows.
- **The module ends with a summary.** The last page of every module is
  `course-0N-summary.md` with the title `# Summary`: a few short prose
  paragraphs on what the reader learned, organised by idea, optionally with
  one short list of key facts. It names no parts, modules, sections or
  chapters, and has no links, lab table, quiz or commands. Its last line is
  `<!-- astrona:playground:destroy -->` on its own line; the platform turns it
  into the step that removes the playground.
- **Every heading gets an intro.** A `##` section that has `###`
  subsections starts with one to three sentences that say what the section
  is about and why it matters, before the first `###`. Never put a `###`
  directly under a `##`.
- **Every module stands on its own.** Never refer to other sections or
  modules: no "see section 040", "as module 3 showed", "you met this in
  section 000", and no links to pages in another module. If the reader needs
  a fact from elsewhere, state the fact directly in one or two sentences.
  This also goes for parts of the same module: never write "Part 2 shows",
  "from Part 1" or "as in Part 3". Say the fact itself ("the commands below
  need the `scout` `DestinationRule` applied"). This includes the summary.
  The landing page does not have a "Where this fits" section.
- **Write words out in full.** Do not use informal short forms in prose:
  write "communications", "configuration", "repository", "administrator",
  "for example" and "that is", never "comms", "config", "repo", "admin",
  "e.g." or "i.e.". Names in code, commands and file paths stay as they are.
- **Exam terms stay.** The product's own names are what the reader must learn
  (for example a resource kind, a field, a command). Use them as they are and
  define each one in plain technical words the first time it appears in a
  file. Spell out acronyms on first use, with a short plain meaning.
- **The space theme is only for examples.** Space appears in two places and
  nowhere else: the names of the example workloads (the Starfleet: `bridge`,
  `scout`, `shuttle`, `probe`, the `starfleet` and `outpost` namespaces) and
  the short scenario that opens a lab task or a practice exercise (for
  example "the `drifter` in `outpost` must keep reaching the probe"). The
  explanation around an example is plain technical text: write "the
  `shuttle` pod sends a request to the `probe` Service", never "the shuttle
  sends a signal to the probe ship". Do not address the reader as an
  astronaut, and do not use space metaphors (communications officer, mission
  control, badge, airlock, guest list, star chart) for Istio or Kubernetes
  concepts. Titles of pages and labs name the technical task ("Require mTLS
  With PeerAuthentication"), not a space story.
- **Show one real example before the rule.** Start with a concrete case the
  reader can run, then give the general rule.
- **Say which part does the work.** Readers often mix up the parts of a system
  that sit close together. Whenever something happens, say which component
  did it.
- **Never change code to fit the style.** Commands, configuration files, field
  names, resource names, log lines and command output stay exactly as they
  are. They were run and checked on a real system. Never make up command
  output. If you shorten it, say that you did.
- **Prose only.** The grade-level and sentence rules apply to explanations.
  They do not apply to code blocks, tables of field names or reference lists
  (those may stay short and dense).
- **Keep the page furniture the same.** Hands-on steps are part of the prose
  (see "Read like a book"), not boxes or headings of their own. A `> [!TIP]` box is
  only for a real tip: advice the reader can reuse beyond this one step (a
  habit, a shortcut, how to spot a problem, an exam habit). Everything else
  is a normal sentence: notes about the current step ("if the log line is
  old, run it again"), background facts, optional extra steps, and plain
  information. Never a command snippet, never two in a row, and most pages
  need zero or one tip. Each part ends with a
  `## Common pitfalls` `> [!WARNING]` block for that part only. Use a Mermaid
  diagram for a flow, an order or a state change, keep it under about 12
  boxes, and follow it with one sentence that says what it shows.
- **Labs come right after the part they practise.** Do not collect all
  graded labs at the end of a module. In `astrona.yaml`, put each lab (its
  `question.md` reading and the `lab` entry) right after the reading part it
  tests. If a part teaches a gradeable skill and no lab covers it, create a
  new lab. That part then ends with a `## Your mission: <lab title>` section:
  one sentence on what the reader can now do, one on what the mission asks,
  then pause the playground (`astrona stop <playground name>`), the
  `astrona run` and `astrona submit` commands, and finally
  `astrona destroy <lab name>` plus `astrona start <playground name>`.
- **Renew the playground before hands-on work.** Every reading part that
  runs commands has `<!-- astrona:playground:renew -->` exactly once, on its
  own line, right before the first hands-on step (the first "Save this as"
  or the first command block), so the playground timer is reset before the
  learner needs the playground. Not on landing pages (they carry
  `<!-- astrona:playground -->`), summary pages (they carry
  `<!-- astrona:playground:destroy -->`) or pages without commands.
- **Mermaid without HTML.** The platform renders Mermaid with HTML labels
  switched off, so `<br/>` and any other HTML tag break the drawing. Rules:
  - One line per box, no `<br/>`, no HTML. Keep the box to the thing's name
    (`"scout-v2"`, `"istiod"`, `"Service: scout"`).
  - Put the logic on the arrows: `E -->|"version: v2"| P2`,
    `I -->|"CDS"| C`, `A -->|"end-user: jason"| B`. Keep edge labels short.
  - Quote every label. Prefer `flowchart TB`; use `LR` only for a short chain.
  - Sequence diagrams: short participant aliases (`participant S as shuttle`)
    and short message text.
  - Anything longer (cluster names, full hostnames) goes in the sentence under
    the diagram.
- **Every course starts with an Introduction.** It lives in `sections/intro/`
  and is the first entry in `astrona.yaml` (`id: module-intro`, title
  "Introduction"). It has exactly these four pages, in this order:
  - `README.md`, `# Introduction`: what the introduction covers and its three
    pages, named in prose (no links), ending with the topic the course starts
    with.
  - `course-01-welcome.md`, `# Welcome To The Course`: who the course is for,
    the exam domain and what the reader can do at the end, the words the
    course uses, the example app, how the course is laid out and how to read
    a page.
  - `course-02-get-your-machine-ready.md`, `# Get Your Machine Ready`: the
    tools to install, the `astrona` commands used every day, and what to do
    when a start goes wrong.
  - `course-03-how-this-course-is-made.md`, `# How This Course Is Made`: how
    content is written and checked, the maintainers, how to report a mistake,
    and the license.
  The Introduction teaches no product content and has no playground, labs or
  summary. Its only links are the repository's contributors page, issues
  page and license.
- **No links to other course files.** A course page (every reading listed in
  `astrona.yaml`, the playground guide `docs/overview.md`, and a lab's
  `question.md` and `solution.md`) never links to or points the reader at
  another page or file of the repository: no links to parts, summaries,
  labs, `question.md`, other modules, sections or the Introduction, and no
  "see `practice.md`" or "open `config.yaml`". The platform shows the pages in
  the order of `astrona.yaml`, so a link only adds a second, often wrong,
  path. Name a thing in plain words when the reader needs it ("the task is on
  the next page"), and state a fact on the page itself instead of sending the
  reader somewhere else. Repository files for authors (the root `README.md`,
  a lab's or playground's `README.md`) may link.
- **No links to outside sources.** Course pages, labs and playground docs do
  not link to or point at outside websites (the one exception is the
  `resources` field of a lab entry in `astrona.yaml`) (official docs, GitHub, blogs,
  RFCs), and they have no "Reference" or "Official docs" lists. Everything the
  reader needs is explained on the page itself. Not affected: addresses the
  reader actually uses in a command or browser (`http://127.0.0.1:9080`,
  `curl https://httpbin.org`), and the Introduction's contributors and
  "report a mistake" links.
- **Configuration goes to a file first.** Whenever the reader should apply
  YAML (course parts, playground docs, labs), use three separate steps:
  1. "Save this as `virtualservice-scout.yaml`:" followed by a plain
     ` ```yaml ` block with only the YAML. No `cat > file <<'EOF'`, no
     `kubectl apply -f - <<EOF`, no shell around it.
  2. "Apply it:" followed by a ` ```sh ` block with only
     `kubectl apply -f virtualservice-scout.yaml`.
  3. "Then check the result:" followed by the check commands, if any.
  The file name says the kind and the object. If a value must come from the
  reader's cluster (an IP address), use a placeholder like `<PARTNER>` in the
  YAML and say how to get the value (`echo $PARTNER`); never put shell
  variables inside YAML. Apply an object the first time its YAML appears; do
  not show it once "to read" and paste it again later. Never tell the reader
  to apply something from the playground's `examples/` folder: they start the
  playground with `astrona run`, so that folder is not on their machine.
- **Helpers have readable names.** Shell helper functions and variables use
  names that say what they do (`check_route`, `count_versions`,
  `$SERVICE_URL`), never single letters.


## About this repo (ATS108 only)

Everything above is general and can be copied to other course repositories. This
section is only true for this one.

### What the student is trying to learn

- **The goal:** master the **Dashboard-as-Code With CUE & Go** domain of the
  **Perses** training path (`ATP021`). It is 25% of the path. There is no
  official Perses certification exam; the path's domains and weights are
  Astrona's own, set in `ATP021/path.yaml`.
- **What the domain really tests:** writing dashboards as code and shipping
  them safely: build a CUE or Go dashboard with `percli dac build`, reuse
  shared definitions, read a build error and fix it, find drift with
  `percli dac diff`, and run a pipeline that lints and refuses a broken
  commit. Every fix is proved with a build that succeeds and a dashboard on
  the server that equals what the code builds.
- **The sections:**

  | Section | Title | Topic |
  | --- | --- | --- |
  | 010 | Why Dashboard-As-Code | The workflow: repository, build, apply, diff |
  | 020 | CUE For Dashboards | The CUE SDK |
  | 030 | The Go SDK | The Go SDK |
  | 040 | A Pipeline For Dashboards | Lint, build and apply from a Kubernetes Job |

- **The versions:** **Perses v0.54.0** and **`percli` v0.54.0** (chart
  `perses` 0.23.3), **CUE v0.17.1**, **Go 1.26.5** (`golang:1.26.5-alpine`,
  the `go` directive of `perses/perses` v0.54.0). The plugin modules are the
  ones bundled with Perses v0.54.0: Prometheus **v0.58.0**, StatChart
  **v0.13.0**, TimeSeriesChart **v0.13.0**. CUE modules come from the CUE
  Central Registry (`registry.cue.works`); all six pinned module versions
  were confirmed there: `github.com/perses/perses/cue` v0.54.0,
  `github.com/perses/plugins/prometheus` v0.58.0, `.../statchart` v0.13.0,
  `.../timeserieschart` v0.13.0, `github.com/perses/shared/cue` v0.54.0,
  `github.com/perses/spec/cue` v0.2.0.
- **The main sources:** the Dashboard-as-Code pages of the Perses docs
  (<https://perses.dev/perses/docs/dac/getting-started/>, the CUE SDK and Go
  SDK pages), the `perses/perses` source at tag `v0.54.0`
  (`internal/cli/cmd/dac/`, `cue/dac-utils/`, `go-sdk/`), the plugin modules
  at the versions above, and <https://cuelang.org/docs/>.

### Status: built, not yet run

The first version of this repository was written **without a live run** of
any playground or lab. Until a maintainer runs them:

- Pages describe results in words. Do not add `text` output blocks until the
  output comes from a real run, and then paste it exactly.
- Treat every lab as unverified. Run `astrona validate` and `astrona test` on
  each one, one cluster at a time, before the course goes past `maturity:
  draft`.
- Remove this subsection when every lab has passed `astrona test`.

What was checked before publishing:

- **Go:** every Go file in the seed repositories was compiled, vetted,
  tested and run with Go against the pinned modules (`go vet`, `go test
  ./lib/...`, `go run main.go --output json`), and `go.sum` was generated
  from that run.
- **CUE: not run.** No `cue` binary was available to the author. Every CUE
  file was written from the SDK sources at the pinned versions. Check these
  first, in this order:
  1. `cue mod tidy` accepts `cue.mod/module.cue` as written (language
     version `v0.17.1`, `source: kind: "self"`, six `default: true` deps).
  2. The shared library pattern in `lib/panels/panels.cue`: each definition
     (`#TargetsUp`, `#SamplesAppended`, `#HeadSeries`) carries its own
     `#job` parameter and exposes the panel as `.panel`, and queries are
     built as `{#promQuery & {#expr: ...}}.query`. This keeps new
     definition fields out of the SDK's closed `v1.#Panel`.
  3. Imports of the main module's own package
     (`"example.com/dashboards/lib/panels"`) from a file evaluated alone by
     `cue eval <file> --concrete`.
  4. The capstone 020 faults produce build errors (`calculation: "average"`
     is not in the StatChart enum; a panel group without `#title`; a
     reference that is not concrete).

### Facts read from the v0.54.0 source (they shape the course)

- `percli dac setup` (CUE) needs an existing `cue.mod` (from `cue mod
  init`), writes `example.cue` and runs `cue mod tidy`; (Go) needs `go.mod`,
  writes `main.go` and runs `go get github.com/perses/perses@<version>`.
  Without a server connection it needs `--version`. It adds `built` to an
  existing `.gitignore`.
- `percli dac build` runs `cue eval <file> --out <json|yaml> --concrete` for
  a `.cue` file (from the current directory) and `go run <file> --output
  <format>` for a `.go` file (from the file's folder). With `-d` it walks the
  folder, skips `.git`, `.github`, `.idea`, `built` and `cue.mod`, evaluates
  **each CUE file on its own**, and runs **every `.go` file of package
  `main`**. Output goes to `built/<path without extension>_output.<format>`;
  `-m stdout` prints instead. Extra arguments after `--` go to Go programs.
- **Consequence:** a `_test.go` file in package `main` under a built folder
  breaks `percli dac build -d` (`go run` refuses test files). Go tests live
  in `lib/boards` (package `boards`), never next to a `main.go` in
  `dashboards/`. One Go dashboard per folder.
- Nothing a Go dashboard program prints may go to standard output except
  the dashboard (`exec.BuildDashboard` writes it there).
- `percli dac diff` compares each built dashboard's `spec` with the server's,
  writes `built/<project>-<name>.diff`, and reports a status per dashboard
  (a dashboard missing on the server is reported as new, without a diff).
- `percli lint -f|-d` checks resources statically; `--online` asks the
  server for extra validation (datasources and dashboards). **Without
  `--online` and without `--plugin.path`, `percli lint` only parses the files
  and validates nothing else**, then prints that the resources look good
  (`internal/cli/cmd/lint/lint.go`: `if o.sch == nil && !o.online { return nil }`).
  Section 040 builds on this: the starting pipeline lints without
  `--online`. `-d` reads `.json`, `.yaml` and `.yml` files in the folder and
  its subfolders, so the `.diff` files `percli dac diff` writes are ignored.
- `percli apply -f|-d` creates or updates; `--create-project` creates a
  missing project; a resource whose `metadata.project` differs from `-p`
  fails unless `--force`.
- `percli login <url>` against a server with authentication off only stores
  the URL in `~/.perses/config.json`. The Perses proxy kind is matched
  without regard to case (`HTTPProxy` and `httpproxy` both work).

### Terms, not metaphors

| Term | First-use definition (example wording) |
| --- | --- |
| Dashboard-as-Code (DaC) | Writing dashboards as source files in Git, building them into Perses resources and applying the result, instead of editing them in the browser |
| CUE | A configuration language where types and values are the same thing; unifying a value with a schema checks and completes it |
| Unification (`&`) | Combining two CUE values into one that satisfies both; it fails when they conflict |
| Definition (`#Name`) | A CUE schema or template that is not part of the output and is closed: it rejects fields it does not declare |
| Default (`*`) | The value CUE picks for a field when nothing else sets it, for example `string \| *"last"` |
| CUE module / package | A folder with `cue.mod/module.cue` and its dependencies / a set of files with the same `package` clause, imported by path |
| Perses CUE SDK | The builders in `github.com/perses/perses/cue/dac-utils` (dashboard, panel groups, variables) plus each plugin's schemas and helpers |
| Go SDK | The Go packages in `github.com/perses/perses/go-sdk` (dashboard, panel group, panel, variable builders) plus each plugin's `sdk/go` package |
| `sdk.NewExec()` / `exec.BuildDashboard` | The Go SDK convention that reads the `--output` flag and writes the built dashboard to standard output |
| `percli dac build` / `diff` / `setup` | Build DaC files into the `built` folder / compare built dashboards with the server / prepare a repository for the CUE or Go SDK |
| Drift | A difference between the dashboard on the server and the dashboard the code builds, usually from an edit in the browser |
| Pipeline | The automated steps from a commit to the server: fetch, build, lint, diff, apply |

### The example workloads

Everything from ATS106's canonical environment (Perses in `perses`,
Prometheus and `tester` in `observability`), plus:

| Name | What it is |
| --- | --- |
| Prometheus scrape jobs | `prometheus` (itself) and `perses` (`perses.perses:8080/metrics`), so `up` has two jobs |
| Project `inventory` with datasource `prometheus` | Created by the bootstrap through the API; every query in the course uses this datasource by name |
| Gitea (namespace `gitea`, Service `gitea-http`) | `gitea/gitea:28.2.0-rootless`, the in-cluster Git server, as in ATS094. User `gitops`, password `gitops-password` (lab-only). Repository `gitops/dashboards` |
| `dac-runner` (namespace `dac`) | `golang:1.26.5-alpine` with `git`, `curl`, `jq`, and `cue` v0.17.1 plus `percli` v0.54.0 in `/tools`. Every DaC command on a page runs here |
| CronJob `dashboards-pipeline` (namespace `dac`, section 040) | The pipeline, `suspend: true`; a run is started with `kubectl -n dac create job <name> --from=cronjob/dashboards-pipeline` |

The repository `gitops/dashboards`:

```text
cue.mod/module.cue          # CUE module example.com/dashboards@v0, pinned deps
go.mod, go.sum              # Go module example.com/dashboards, go 1.26.5
lib/panels/panels.cue       # shared CUE panel definitions (package panels)
lib/boards/                 # shared Go functions and their tests (package boards)
dashboards/cue/*.cue        # one CUE dashboard per file (package dashboards)
dashboards/go/<name>/main.go  # one Go dashboard per folder (package main)
```

### Environment facts the text must respect

- **Seen on a live run (2026-10-23):** git in the `dac-runner` pod refused to
  work in copied repositories ("detected dubious ownership"). Every Go
  container sets `safe.directory=*` through `GIT_CONFIG_COUNT`,
  `GIT_CONFIG_KEY_0` and `GIT_CONFIG_VALUE_0`; keep these env vars on any new
  container that runs git. `percli dac build` with CUE built and matched the
  server in lab 010.

- **Two addresses, one trick.** `http://perses.localtest.me:8080` and
  `http://gitea.localtest.me:3000` work in the cluster through CoreDNS
  `rewrite stop` blocks (answer name rewritten back) and on the reader's
  machine through `kubectl -n perses port-forward svc/perses 8080:8080` and
  `kubectl -n gitea port-forward svc/gitea-http 3000:3000`. Pages that clone
  or push start the Gitea port-forward in a second terminal and say so.
- **The reader edits on their machine and builds in the runner.** The reader
  clones `gitops/dashboards`, saves files, commits and pushes. Every DaC
  command runs in `dac-runner` through one helper:

  ```sh
  dac() { kubectl -n dac exec -i deploy/dac-runner -- dac-run "$@"; }
  dac percli dac build -d dashboards -ojson
  ```

  `dac-run` (from the ConfigMap `dac-runner-scripts`) resets
  `/work/dashboards` to `origin/main`, logs `percli` in to Perses if needed,
  and runs the command there. The runner's copy is a read-only mirror: an
  unpushed change does not exist for it. Say so on every page that builds.
- **Authentication is off** in every environment of this course. Pages
  describe how a pipeline logs in to a server with authentication on
  (`percli login --username/--password` from a Secret, or `--token`), but no
  lab switches it on.
- **Internet is needed** at build time: the Go module proxy and the CUE
  Central Registry, the first time each dependency is fetched in a runner.
  The bootstrap warms both caches.
- **Many environments start broken on purpose.** The fault is the material.
  Never "fix" it in the bootstrap.

### Where things are in this repo

The layout is the same as every Astrona course. Environment plumbing
(`config.yaml`, `bootstrap/`, `manifests/` including the seed repository in
`manifests/repo/`, `solution/apply.sh`, `testing/`, `validation/`, author
READMEs and `prerequisites.md`) was generated for all 12 environments by a
script outside the repository. Change a shared piece (the runner, `dac-run`,
the Gitea seeding, the CoreDNS block) in **every** environment.

### Lab metadata in `astrona.yaml`

`training:` block: id `ATS108`, domain `Dashboard-as-Code With CUE & Go`,
weight `25`. Lab entries carry `title`, `path`, `difficulty`,
`estimated_duration`, `topic`, `task_kind`, `tags`, `learning_goals`,
`resources`, in that order.

- `topic`: exactly one of `dac-workflow`, `cue`, `go-sdk`, `pipeline`.
- `task_kind`: `build`, `troubleshooting` or `migration`.
- `tags`: 4 to 8, only from this list: `percli-dac-build`,
  `percli-dac-diff`, `percli-dac-setup`, `percli-apply`, `percli-lint`,
  `built-folder`, `drift`, `git-workflow`, `cue-sdk`, `cue-definitions`,
  `cue-packages`, `schema-validation`, `panel-groups`, `list-variable`,
  `go-sdk`, `sdk-exec`, `go-tests`, `pipeline`, `kubernetes-job`,
  `fail-fast`.
- `resources`: 1 to 4 pages on `perses.dev` or `cuelang.org`. The only place
  outside links are allowed.

### Running things

```bash
astrona run --git ssh://git@github.com/astrona-io/ATS108.git -c sections/section-010/module-01/playground
astrona destroy ats-108-playground-010-01
astrona run --git ssh://git@github.com/astrona-io/ATS108.git -c sections/section-010/module-01/labs/lab-01
astrona submit -c sections/section-010/module-01/labs/lab-01
astrona destroy ats-108-lab-010-01
astrona test -c sections/section-010/module-01/labs/lab-01   # authors
```

Names: `ats-108-playground-<section>-<module>`, `ats-108-lab-<section>-<module>`,
`ats-108-capstone-<section>`. Graders check **behaviour**: they build the
code at the head of `main` in the runner and compare it with what the
Perses API serves (groups, panel names, plugin kinds, queries, variables),
run Go tests, and start pipeline Jobs. They reject the plausible but wrong
fix: a dashboard applied by hand from JSON written without code, a schema
weakened to make a build pass, a test deleted, a pipeline step made to
ignore its errors.

### Where to find trusted sources

- **DaC:** <https://perses.dev/perses/docs/dac/getting-started/>,
  <https://perses.dev/perses/docs/dac/cue/>,
  <https://perses.dev/perses/docs/dac/go/>,
  <https://perses.dev/perses/docs/concepts/dashboard-as-code/>
- **percli:** <https://perses.dev/perses/docs/cli/>
- **Source:** `perses/perses` at `v0.54.0`; `perses/plugins` modules at the
  versions above; GitHub Actions in `perses/cli-actions` (prose only)
- **CUE:** <https://cuelang.org/docs/>
