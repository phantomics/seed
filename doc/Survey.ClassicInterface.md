---
id:            SEED-DRAFT-classicinterface
title:         "The Classic Interface Mode: A CMS Proving Ground for IS/AS/BY"
genre:         Survey
scope:         project
project:       Seed
language:      en
status:        Draft
provenance:
  assistant:   claude-opus-5-5
relates-to:
  - SEED-0003
  - SEED-0004
  - SEED-0005
  - SEED-DRAFT-editormodels
  - SEED-DRAFT-branches
  - SEED-DRAFT-smalltalk
  - VOX-DRAFT-vox
  - CLASSIC-0007
  - CLASSIC-0011
  - CLASSIC-0008
  - CLASSIC-0021
cites:
  - title:     "Lexis: Lisp EXpressions as Interchange Syntax"
    locator:   "~/src/lisp/lexis/README.md"
    external:  true
  - title:     "Lexis Specification"
    locator:   "~/src/lisp/lexis/doc/spec.md"
    external:  true
  - title:     "Magritte — Meta-Described Web Application Development"
    locator:   "Renggli, L. PhD thesis, University of Bern, 2009"
    external:  true
  - title:     "3bmd — Markdown Processor in CL Using Esrap"
    locator:   "https://github.com/3b/3bmd"
    external:  true
  - title:     "Vox: Declarative Work and Data Exchange Between Lisp Images"
    locator:   "VOX-DRAFT-vox, ~/src/lisp/vox/doc/Survey.Vox.md"
    external:  true
  - title:     "Impulse: Interactive Manifold Process-Uniting Lexicon as Symbolic Expressions"
    locator:   "ORIGIN-0006, ORIGIN-0008"
    external:  true
open-questions:
  - SEED-DRAFT-classicinterface-O1
  - SEED-DRAFT-classicinterface-O2
  - SEED-DRAFT-classicinterface-O3
  - SEED-DRAFT-classicinterface-O4
  - SEED-DRAFT-classicinterface-O5
  - SEED-DRAFT-classicinterface-O6
  - SEED-DRAFT-classicinterface-O7
  - SEED-DRAFT-classicinterface-O8
  - SEED-DRAFT-classicinterface-O9
---

# The Classic Interface Mode: A CMS Proving Ground for IS/AS/BY

This document surveys the design space for a Classic interface mode in
Seed — a content management system (CMS) authoring interface, comparable in
scope to WordPress's admin pages, built on the IS/AS/BY taxonomy implemented
in modulate2. Seed provides only the authoring interface; public-facing views
are the responsibility of Classic's Composer and theming systems.

The Classic interface mode is the first real-world consumer of IS/AS/BY. The
Philo catalog demo (`demo.access` `:catalog`) exercises the new grammar on
static data; the CMS exercises it on data with lifecycle, workflow, persistence
and inter-entity relationships. If IS/AS/BY can express a working CMS without
hand-written rendering code, it has proved its thesis. If it cannot, the gaps
it reveals are the most valuable finding.

Chart editing (`systems/abcd`) shares infrastructure with the CMS — especially
Tier-1 manipulation defaults — but its specific concerns are deferred to a
separate Survey.


## Motivation

Seed's IS/AS/BY ontology claims that a datum can carry enough metadata to
derive its own interface. The claim is documented in
SEED-0003 and SEED-0004 and exercised by
the Philo demo. But Philo is a catalog of static values with no persistence,
no workflow and no user identity. A CMS is where these forces converge:

- **Persistence.** Articles are stored, retrieved, and updated through
  Classic's imprint API.
- **Workflow.** Articles move between draft, published, archived and deleted
  states, with permissions gating each transition.
- **Relationships.** Articles belong to categories, link to other articles
  and wiki pages, and carry authorship.
- **Rich editing.** Article bodies are documents in their own right, with
  structure (headings, lists, emphasis) and cross-references.
- **Multiple views.** The same data appears as a list item, a metadata form,
  a text editor and a rendered preview.

Building the CMS on IS/AS/BY forces each of these concerns through the
taxonomy and reveals where annotations suffice, where defaults must be
richer, and where the bridge between Classic's self-describing model and
Seed's must be designed with care.


## Starting Point

All code references in this section are pinned to revision `6a9aa8e`.

### The demo.access system

`systems/demo.access/seed.lisp@6a9aa8e` defines two tabs:

- **`:catalog`** — the Philo demonstration. It already renders new-grammar
  `fx` through the bridge into modulate2: `express` builds a manifestation
  tree, `generate` renders it to HTML. This tab exercises `:observing`,
  `:entering`, `:choosing`, `:reducing`, `:sorting`, `:extending` and
  `:activating` annotations.
- **`:cms`** — a working Classic blog editor with an article list, a create
  form, and a CodeMirror edit view. It is written entirely in the old
  grammar (`dx`, `uic-series`, `uicc-button`, `uicc-field`, `uir-*` roles)
  and is the migration target for this work.

### The old-grammar CMS

The `:cms` branch in `systems/demo.access/seed.lisp@6a9aa8e` is a hand-written
version of the branch-object model described in SEED-DRAFT-branches. Its
handler is a `cond` over string-compared `action` values (`"new"`,
`"create"`, `"edit"`, `"back"`) plus a separate text protocol for CodeMirror
load and save. Three helper functions produce the views:

- `render-cms-list` — builds an old-grammar `dx` tree with a `uic-series`
  per article and a `uicc-button` per edit action.
- `render-cms-create` — a form with `uicc-field` inputs and inline
  JavaScript for the create action.
- `render-cms-edit` — a CodeMirror editor (`uicc-field :type (:code)`) with
  inline JavaScript for save.

The inline JavaScript constructs `fetchContact` calls by hand, builds
payloads from DOM queries, and relies on global `seedData` state. This is the
debt the migration must retire.

### The gap in activating controls

`modulate2/modulate2.lisp@6a9aa8e` can produce `:activating` atoms through
`make-control`. The `generate` method renders them as `<button>` elements
with `data-action` and `data-target` attributes. But no client-side code
listens to those attributes. The `:reducing` remove buttons in the Philo
demo, and any CMS controls built the same way, do nothing when clicked.
Wiring `:activating` controls to `fetchContact` (or an equivalent) is an
early prerequisite for any CMS work.

### Classic's setup

`systems/demo.access/setup.lisp@6a9aa8e` creates an in-memory Classic blog
imprint (`*blog*`) and a default writer account (`*default-account*`). The
CMS uses `classic.models.common` functions (`write-article`, `get-articles`,
`edit-article`) keyed by list index.


## Classic's Self-Describing Model

Classic is not merely a storage backend. Its CLOS metaclass and theming
system form a self-describing layer that is a close relative of IS/AS/BY.
Understanding this layer is necessary for designing the bridge.

### MOP slot metadata (CLASSIC-0007)

`classic-class`, Classic's metaclass, extends CLOS slot definitions with
four custom options:

| Option | Values | Purpose |
|--------|--------|---------|
| `:persistence` | `:identity`, `:triple`, `:relation`, `:blob`, `:derived` | How the slot is stored |
| `:predicate` | An RDF predicate string | Semantic identity of the slot |
| `:format` | `:markdown`, `:html`, `:sexp` | Source format for `:blob` slots |
| `:validate` | A function designator | Input validation |

These annotations are introspectable: the persistence layer reads them to
determine storage, the rendering layer reads them to determine presentation,
and the federation layer reads them to determine syndication. An article's
`body` slot defaults to `:persistence :blob :format :markdown`; per-class
overrides allow `:sexp`, `:html` or other formats.

### Workflow (CLASSIC-0008)

Articles carry a `current-state` that progresses through a lifecycle:
draft → published → archived → deleted, with hard-delete (purge) as a
terminal step. Each transition is gated by `account-has-permission-p`:
writers can draft and edit but not publish; editors can publish and archive.

### Themes and lenses (CLASSIC-0011)

A theme associates each content class with **lens specs** for various
purposes (`:default`, `:infobox`, `:label`). Each lens lists the slots to
show and how to show them:

- **Display modes:** `:text`, `:image`, `:link`, `:uri`, `:html`,
  `:markdown`, `:date`, `:list`. The Composer uses the mode to convert a
  slot value into a Lexis node for rendering.
- **Sublens rendering:** for `:relation` slots, a `:sublens` and `:purpose`
  specify how to render the related entity inline.

When `:display` is omitted, the Composer cascades: if the slot's MOP
`:format` is `:markdown` or `:html`, use the matching mode; if `:persistence`
is `:relation` and a `:sublens` exists, follow it; otherwise fall back to
`:text`.

### The wiki (CLASSIC-0021)

Classic's wiki preset adds typed page classes (`wiki-computer`, `wiki-cpu`,
`wiki-person`) whose MOP-annotated slots drive lens-based infobox rendering.
Cross-references use `[[Anchor]]` and `[[Anchor|Display]]` syntax.
`parse-wiki-links` extracts references from body text; `resolve-page-links`
resolves them against existing pages and identifies broken links;
`add-backlinks` and `heal-broken-links` maintain a bidirectional link graph.


## The Classic→fx Bridge

The Smalltalk Eval (SEED-DRAFT-smalltalk) observed that Magritte describes
classes while `fx` describes individual values. Classic's lenses play
Magritte's role: they are class-level defaults that say how each slot should
be presented. The bridge between Classic and Seed is an adapter that reads a
Classic instance's slot metadata, lens specs and workflow state, and produces
annotated `fx` data for `express-new`. Seed then derives the interface
without hand-written rendering code for each view.

### The mapping

Table: How Classic's metadata maps to the IS/AS/BY axes.

| Classic concept | fx axis | fx annotation | Notes |
|-----------------|---------|---------------|-------|
| `:format :markdown` on a `:blob` slot | AS | `:markdown` | The format is the role the string plays; see "AS for source formats" below |
| `:format :lexis` (proposed) | AS | `:lexis` | Lexis-native bodies |
| `:persistence :triple` (scalar) | BY | `:entering` | Editable text field |
| `:persistence :relation` | BY | `:choosing` or `:navigating` | Depends on whether the user selects or follows the link |
| `:persistence :derived` | BY | `:observing` | Computed values are not editable |
| `:persistence :blob` | BY | `:provision-text` | CodeMirror, mode selected by format |
| Workflow transitions the account may perform | BY | `:activating` | One control per permitted transition |
| A lens for a purpose | — | Class-level defaults generating `fx` | Per-value overrides remain possible |
| Display mode `:list` | AS | `:extending` / `:reducing` | List-valued slots |

### AS for source formats

A body string stored as Markdown carries `:format :markdown` in Classic's
MOP metadata. In IS/AS/BY terms, this is an **AS annotation**: it declares
the string's role in the containing system — the language it carries, which
determines how to edit and render it. It is not IS, because IS (even
stratum-2) concerns the structural character of the datum itself (alist,
plist, hash table), not the higher-level language it represents. A Markdown
string and a SQL string are both strings at the IS level; their difference
is one of role.

The bridge turns Classic's `:format` into an AS annotation:
`(:as :- :markdown)`, `(:as :- :lexis)`, `(:as :- :sql)`, and so on.
The provisioning system reads this annotation to select the CodeMirror
mode, the preview renderer, and the save pipeline.

### Lenses as class-level defaults

A Classic lens spec says "for this class, show these slots in this order
with these display modes." The bridge reads this and generates an `fx` form
for each slot value, with AS and BY annotations derived from the lens entry
and the slot's MOP metadata. Individual values can still carry their own
`fx` annotations to override the class-level default.

This is the Magritte pattern made concrete: the class describes; the
instance customises; Seed renders.


## Document Representation and Editing Modes

### Lexis as the canonical rich-document format

Lexis is Classic's base document representation. Theme templates and slot
fills are Lexis fragments. The Composer converts slot values to Lexis nodes
for rendering. Making Lexis the canonical body format for rich publications
eliminates a conversion boundary: the edited form is the stored form, and
Lexis's HTML renderer produces the same Spinneret tree that Seed's
`generate` emits.

Lexis can express everything Classic needs — sections, paragraphs, emphasis,
code blocks, links, images, tables, definition lists, notes, asides — using
a semantic tag vocabulary that maps naturally to HTML output. Its
s-expression form is readable by `cl:read`, storable, embeddable and
transformable by any Lisp program.

### Text-sourced documents and the fidelity principle

Not every document is Lexis-native. Wiki pages are authored in Markdown
with `[[wikilinks]]`, the modern default for wiki input formats (GitHub,
GitLab, Obsidian, Logseq, Wiki.js). MediaWiki wikitext is relevant mainly
for importing existing wikis. For these text-sourced documents, converting
to Lexis and back loses fidelity: Lexis tags like `definition-list`, `note`
and `aside` have no standard Markdown equivalent.

The fix is clear roles for each representation:

1. **Each document declares its source format.** Classic already has the
   mechanism: the `:format` slot option. This is the single source of truth
   for how the body is stored, edited and rendered.
2. **For text-sourced documents, the stored text is authoritative.** Lexis
   is derived from it one-way for display — preview, Composer output, link
   extraction — and never written back.
3. **Converting between source formats is a deliberate user action** with a
   warning, not an implicit process. Promoting a Markdown post to a
   Lexis-native document is a one-way migration.
4. **For rich publications, Lexis is the source.** The authoring interface
   steers users towards Lexis through a ProseMirror editor whose schema
   mirrors Lexis's tag vocabulary, with raw Lexis available as a power-user
   mode.

### The three editing views, in order of implementation

1. **Raw Lexis in CodeMirror** with Lisp mode (`:provision-text`). This
   comes first, defines the baseline interaction with Lexis, and serves
   developers and power users. The demo blog starts here, with body format
   `:lexis`.
2. **Markdown in CodeMirror** with Markdown mode (`:provision-text`). For
   wiki pages and text-sourced blog posts. Requires a Markdown→Lexis reader
   for preview and link extraction; the body text itself is stored as
   Markdown.
3. **A ProseMirror rich editor** (`:provision-document`, later). A
   ProseMirror schema mirroring Lexis's tag vocabulary gives visual editing
   with structural fidelity. `pla.browser.maple` already bundles
   ProseMirror with `prosemirror-schema-basic`; the Lexis schema would
   replace it. This is the endpoint for non-technical users.

A later structural Lexis editor — where paragraphs become `:entering` text
atoms, sections become containers, and lists become `:sorting`/`:extending`
sequences — would exercise IS/AS/BY at its deepest. That is a research
goal, not a near-term deliverable.

### Reading discipline

Article text comes from users, so reading Lexis bodies requires hardened
`cl:read`: `*read-eval*` bound to `nil`, a restricted readtable that
interns only known Lexis tag symbols, a size limit, and no free interning
into arbitrary packages. This is the same discipline Impulse and Vox use
for untrusted payloads. Reader errors must produce good feedback — line
and column markers in CodeMirror — or raw Lexis becomes frustrating.


## The CMS Views

Each view is described in terms of what it presents and what IS/AS/BY
annotations it needs.

### The article list

An `:observing` sequence of article summaries. Each summary shows the
headline, the current workflow state and the creation date. Each carries
`:activating` controls: "edit" always, "publish" / "archive" / "delete"
filtered by the current account's permissions and the article's state.

### The create form

A container with:

- The title: `:entering` (a text field).
- The body: `:provision-text` with the CodeMirror mode determined by the
  article class's body format (Lisp mode for Lexis, Markdown mode for
  Markdown).
- Controls: "create" (`:activating`, effect class `:effecting`) and
  "cancel" (`:activating`, `:safe`).

### The edit view

Like the create form, but pre-populated. The CodeMirror editor loads the
article's body through the text protocol. Save is `:effecting`; back is
`:safe`. The metadata panel (title, categories, status) is produced by the
Classic→fx bridge: each slot's MOP metadata and lens entry generates an
`fx` annotation, and the rendering pipeline does the rest.

### The metadata panel

A container of fields generated by the bridge. For each slot in the class's
lens spec:

- Scalar slots (`:persistence :triple`) → `:entering` text fields.
- Relation slots (`:persistence :relation`) → `:choosing` among related
  entities, or `:navigating` links.
- List-valued slots (e.g. categories) → `:extending`/`:reducing` sequences,
  requiring Tier-1 manipulation defaults to actually work.
- Derived slots (`:persistence :derived`) → `:observing` displays.

### Workflow controls

One `:activating` control per permitted workflow transition, filtered by
`account-has-permission-p` for the current session's account. Each carries
an effect class from SEED-DRAFT-branches: "publish" is `:effecting`,
"archive" is `:effecting`, "delete" is `:effecting`, "restore" is
`:idempotent`.

### The preview

For Lexis-native bodies: Lexis's `render-html-tree` produces a Spinneret
tree that `generate` can embed in the CMS output. For
Markdown-sourced bodies: the Markdown→Lexis reader (see "Suggested Lexis
changes" below) produces a Lexis tree, then the same rendering path
applies. The preview is read-only and carries no `fx` annotations.

### The wiki views

The wiki extends the CMS with:

- A page list with broken-link indicators.
- `[[wikilink]]` completion in CodeMirror (autocompletion from
  `all-wiki-pages`).
- Backlink display for each page (from `resolve-page-links` and the
  backlink graph).
- Infobox rendering for typed pages through lens-driven `fx` generation.
- Revision history (a later step, once branches support history as a
  stage or a separate branch per SEED-DRAFT-branches).


## The Incremental Path

### Rules

1. **A working CMS at every step.** Each increment ends with the full
   flow working: list, create, edit, save. Each passes a short manual
   checklist and any automated tests.
2. **Only one foundational subsystem changes at a time.** The rendering
   grammar (old `dx` → new `fx`), the branch model (lambdas → objects
   with operations) and the carrier (direct calls → in-image Vox stage)
   are never in flux together.
3. **Replace parts behind the existing bridges.** The `express`, `dx` and
   `generate` hooks already let old and new grammar mix within one tree.
   One view can move to the new grammar while the others stay put, and the
   old path is removed only once the new one proves itself.
4. **CMS features pull infrastructure in.** For example, a category list
   needs Tier-1 `:extending` and `:reducing` to actually work; those are
   finished when the category list needs them.
5. **Tests grow alongside.** modulate2 and the Classic bridge should get
   tests as they change.

### Increment ladder

Table: Proposed increments, what each changes, and the infrastructure
it pulls in. A Plan will decide the final sequence.

| Step | What changes | Infrastructure pulled in |
|------|-------------|--------------------------|
| A1 | Article list in new-grammar `fx`, with edit controls as `:activating` atoms | Wiring `:activating` to client-side dispatch |
| A2 | Editor uses `:provision-text` with Lisp mode; inline JS disappears; body format `:lexis` | CodeMirror mode selection through the AS annotation |
| A3 | Metadata panel (title, categories, state) from the Classic→fx bridge | The bridge itself; Tier-1 `:extending`/`:reducing` for categories |
| B | Workflow: publish, archive, delete, restore as permission-filtered `:activating` controls | Account context in the session |
| C | Rendered preview | `lexis.html` integration; for Markdown sources, the Markdown→Lexis reader |
| D | Wiki: page list, `[[link]]` completion, backlinks, broken-link indicators, typed-page infobox | Wiki-link handling over Lexis bodies; lens-to-fx generation |
| E | Branch-object migration: operations with effect classes, Classic writes as queued effects | SEED-DRAFT-branches first two tiers; Vox in-image stage |

Steps A1–A3 can proceed without changes to Classic. Step B needs account
context but uses Classic's existing workflow API. Steps C and D depend on
the Markdown→Lexis reader and wiki-link handling, which are Lexis and
Classic work respectively. Step E is the branch modernisation and is
decoupled from the CMS feature work.


## Where Branch and Vox Work Fits

Step E is where the CMS meets SEED-DRAFT-branches. The current `:cms`
handler is a `cond` over string-compared action names — it is already a
hand-written branch-object pattern. Migrating it means:

1. Defining a branch class with operations named by keywords rather than
   strings.
2. Each operation declares an effect class (`:safe`, `:idempotent`,
   `:effecting`) and an ending (`answer`, `transfer`, `fail`).
3. Classic writes (`write-article`, `edit-article`, `publish-article`, etc.)
   become queued effects, executed at commit.
4. A mandatory `describe` operation replaces the "default render" path.

The in-image Vox stage (VOX-DRAFT-vox) replaces `grow` for branch-to-branch
calls. Because in-image calls copy payloads, the transition is transparent:
the branch's operations do not depend on the medium.


## Suggested Classic Extensions

These changes would make the Classic→fx bridge cleaner. They are suggestions
for a dedicated Classic conversation, not dependencies for early CMS work.

1. **URI-keyed accessors.** Classic's `show-article`, `edit-article`,
   `publish-article` and related functions identify articles by 1-based
   list index, which breaks when the list changes. Accessors keyed by
   URI (the stable identity Classic already assigns) would be safer.
2. **A richer format vocabulary.** The current `:format` options —
   `:markdown`, `:html`, `:sexp` — are incomplete. `:lexis` should be
   added for Lexis-native bodies. The display mode `:html` is described
   as "pass-through (already Lexis)" in CLASSIC-0011, which conflates
   HTML with Lexis. A clean vocabulary would include `:lexis`,
   `:markdown`, `:html`, and leave room for others.
3. **Format-dispatched wiki-link handling.** `parse-wiki-links` scans raw
   strings. For Lexis-native bodies, link extraction should walk `classic-link`
   and `cross-ref` nodes rather than scanning text. The wiki functions
   should dispatch on the body's format.
4. **Composer `:markdown` display mode.** CLASSIC-0011 specifies a
   `:markdown` display mode ("Lexis tree from Markdown parse") but nothing
   implements it. The Markdown→Lexis reader (see below) would provide the
   missing implementation.


## Suggested Lexis Changes

These are observations for the Lexis project, recorded here because the
CMS design depends on their resolution.

### A Markdown→Lexis reader

Lexis has no block-level reader and no Markdown→Lexis parser. Classic's
Composer `:markdown` display mode is specified but unimplemented.

The recommended approach is to adapt an existing library rather than write
a parser. **3bmd** (already available via Quicklisp) is a Markdown parser
that produces a clean Lisp list structure, not HTML. Its parse tree maps
almost node-for-node to Lexis tags:

| 3bmd node | Lexis tag |
|-----------|-----------|
| `(:heading :level N :contents ...)` | `(section (@ :title ...))` (nested) |
| `(:paragraph ...)` | `(paragraph ...)` |
| `(:emph ...)` | `(emphasis ...)` |
| `(:strong ...)` | `(strong ...)` |
| `(:code ...)` | `(code ...)` |
| `(CODE-BLOCK :lang ... :content ...)` | `(code-block (@ :language ...) ...)` |
| `(:block-quote ...)` | `(blockquote ...)` |
| `(:bullet-list ...)` | `(unordered-list ...)` |
| `(:counted-list ...)` | `(ordered-list ...)` |
| `(:list-item ...)` | `(item ...)` |
| `(:explicit-link :label ... :source ...)` | `(web-link (@ :uri ...) ...)` |
| `(WIKI-LINK :label ... :args ...)` | `(classic-link ...)` |

The adapter is estimated at 200–300 lines plus tests: a tree walk that
translates nodes, a section-nesting pass that groups flat headings into
nested `section` elements, and text reassembly (3bmd splits text into
separate word strings). The main risk is double interpretation: an
escaped `\*` in Markdown could be reinterpreted by Lexis's own inline
processing if the adapter does not mark translated text as literal.

3bmd follows the original Markdown behaviour rather than the CommonMark
specification, so edge cases in nested lists and emphasis will differ. For
blog posts and wiki pages this is acceptable. If CommonMark conformance
becomes important, the adapter's entry point (`markdown->lexis`) can be
backed by cl-cmark (C bindings to libcmark) without changing the rest of
the system. Running the CommonMark spec examples against 3bmd would
quantify the gap.

3bmd has extensions for fenced code blocks, tables, wiki links and
definition lists, all of which map to Lexis tags.

The adapter would live in the Lexis repository as a system named
`lexis.markdown`, since it concerns Lexis's representation. Classic's
Composer would then use it.

### Link order and bare-target semantics

Lexis writes `[[display|uri]]` (display-first). Classic's wiki, MediaWiki,
Obsidian and 3bmd all put the target first: `[[Target|Display]]`. Lexis is
the outlier.

A bare `[[target]]` in Lexis becomes a `cross-ref` — a link to an anchor
in the same document (`#target`). In Classic's wiki and every wiki format,
it is a link to another page.

The suggestion: Lexis should change to target-first `[[target|display]]`
and allow contexts (like wiki mode) to interpret a bare `[[target]]` as
a page link rather than an intra-document cross-reference.

### Bare `[[target]]` in wiki contexts

Rather than changing the global semantics of `[[target]]`, Lexis's text
processing could accept a context parameter. In wiki contexts, a bare
`[[target]]` produces a `classic-link`; in document contexts, it remains
a `cross-ref`. The source format (AS annotation `:markdown` vs `:lexis`)
or an explicit flag would determine the context.


## Later Goals

### ProseMirror rich editing (`:provision-document`)

A `:provision-document` BY modality would cover structured rich-document
editing through ProseMirror. Its schema would mirror Lexis's tag vocabulary,
giving visual editing with structural fidelity. This is the endpoint for
non-technical users and a later priority.

### Structural Lexis editor

A Seed-native view where paragraphs become `:entering` text atoms, sections
become containers, and lists become `:sorting`/`:extending` sequences. This
would exercise IS/AS/BY at its deepest, treating the Lexis document tree
as an `fx` tree. It is a research goal.

### Compass documents via the wiki

Compass documents are Markdown with YAML front-matter and cross-referencing
identifiers. Editing Seed's own `doc/` through the wiki mode would be a
strong test of the whole system. It requires either the Markdown editing
view or a dependable Lexis↔Markdown round trip. The round trip is inherently
lossy (Lexis tags like `definition-list` and `aside` have no Markdown
equivalent), so the Markdown editing view is the more practical path.
This goal needs its own Survey to address front-matter handling,
identifier management and the interaction with `compass check`.


## Honest Limits

1. **Classic's API uses list indices.** `show-article`, `edit-article` and
   the other article functions identify articles by 1-based position in the
   persistence store's list. Concurrent modifications or deletions can
   shift indices and cause the wrong article to be edited. The CMS must
   work around this until URI-keyed accessors are available.
2. **The `:activating` gap is real.** Until client-side dispatch is wired,
   no CMS control works. This is the first blocker.
3. **Inline JavaScript debt.** The current CMS has ~15 lines of hand-written
   JavaScript for create and save actions. These must be replaced by
   declarative `:activating` controls with server-determined payloads.
4. **No Markdown→Lexis parser exists yet.** Preview for Markdown-sourced
   documents and the wiki's link resolution depend on it. Until it is
   built, the demo blog is Lexis-native and wiki functionality is blocked.
5. **Lexis's link order is wrong for wikis.** The display-first
   `[[display|uri]]` conflicts with every wiki format. This must be
   resolved in Lexis before wiki `[[links]]` work as expected.
6. **No account context in the session.** Workflow controls need to know
   which account is acting. The demo currently uses `*default-account*`
   globally; real permission filtering requires session-scoped identity.
7. **ProseMirror schema work is unbounded.** Building a ProseMirror schema
   that mirrors Lexis faithfully — especially for nested inline markup,
   tables and extension tags — is a significant front-end effort. It is
   explicitly deferred.


## Relationship to Other Work

- **SEED-0003 and SEED-0004** define
  IS/AS/BY. This Survey is the first real-world test of those definitions.
- **SEED-0005** places Seed's approach in the landscape
  of interface models. The Classic bridge is the Magritte-like pattern
  that survey anticipated.
- **SEED-DRAFT-editormodels** covers editor strategies. The three editing
  views (raw Lexis, Markdown, ProseMirror) correspond to its taxonomy.
- **SEED-DRAFT-branches** defines the branch-object model that step E
  migrates to. The stage model (decode/act/encode), operations with
  effect classes, and queued effects all apply to the CMS.
- **VOX-DRAFT-vox** defines the interlink that replaces `grow` in step E.
- **CLASSIC-0007** (Ontological Model Reference) documents the MOP
  extensions the bridge reads.
- **CLASSIC-0011** (Theme System Reference) documents the lens and
  Composer systems the bridge maps from.
- **CLASSIC-0021** (Wiki Preset Guide) documents the wiki model that
  step D integrates.
- **Lexis** (external) is the document format for rich publications and
  Classic's internal representation.
- **Chart editing** (`systems/abcd`) shares Tier-1 manipulation defaults
  (`:sorting`, `:extending`, `:reducing`) with the CMS. It exercises
  valence and layout, which the CMS does not. A separate Survey will
  address it.


## Open Questions

### SEED-DRAFT-classicinterface-O1 — Bridge granularity

Should the Classic→fx bridge generate annotations at the slot level (one
`fx` form per slot value) or at the instance level (one compound `fx`
form for the whole object)? Slot-level gives finer control;
instance-level keeps the bridge simpler and matches how lenses are
specified.

### SEED-DRAFT-classicinterface-O2 — Format migration UX

When a user promotes a Markdown document to Lexis-native, what does the
interface show? A diff? A preview of the converted document? A warning
about tags with no Markdown equivalent? The fidelity principle says the
conversion is one-way, but the user needs to understand what they gain
and what they cannot undo.

### SEED-DRAFT-classicinterface-O3 — CodeMirror mode switching

The AS annotation determines the CodeMirror mode (Lisp for Lexis,
Markdown for Markdown). Can the mode change dynamically if the source
format changes, or must the editor be reloaded?

### SEED-DRAFT-classicinterface-O4 — Wiki-link completion source

Should CodeMirror's `[[` completion query the server (through the
branch) or preload the full page list? Small wikis favour preloading;
large ones need server-side search. The answer may depend on a
threshold.

### SEED-DRAFT-classicinterface-O5 — Lexis reader hardening

What is the right restricted readtable for untrusted Lexis input? Lexis
tags should intern into the `lexis` package only; unknown symbols should
signal a condition. Does this need a dedicated safe-reader, or can
Lexis's existing `parse-document` be extended with a binding for
`*readtable*`?

### SEED-DRAFT-classicinterface-O6 — The AS vocabulary for formats

How large should the format vocabulary grow? `:markdown`, `:lexis`,
`:html` are clear. Should `:wikitext` (for MediaWiki import), `:org`
(for Org-mode), or `:rst` (for reStructuredText) be anticipated in the
AS taxonomy, or added ad hoc when needed?

### SEED-DRAFT-classicinterface-O7 — Preview rendering location

Should Markdown→Lexis→HTML happen server-side (keeping Seed independent
of the medium) or client-side (lower latency for live preview)?
Server-side is the recommendation, but live preview may want a
client-side fallback.

### SEED-DRAFT-classicinterface-O8 — Revision history model

Should article history be a branch-level concern (a history stage per
SEED-DRAFT-branches), a Classic-level concern (revision objects stored
by the persistence backend), or both? The wiki already has revision
objects; the branch stage model offers a uniform approach.

### SEED-DRAFT-classicinterface-O9 — The `[[target]]` resolution rule

If Lexis changes bare `[[target]]` to mean "page link" in wiki contexts
and "cross-ref" in document contexts, what determines the context? The
source format (AS annotation), a flag on the Lexis processing call, or
the presence of a wiki imprint in scope?
