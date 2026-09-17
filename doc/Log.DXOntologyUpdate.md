---
id:            SEED-DRAFT-dxontologyupdate
title:         Unifying (dx) Forms Under IS/AS/BY — Development Log
genre:         Log
scope:         component
project:       Seed
component:     modulate2
language:      en
status:        Draft
provenance:
  assistant:   claude-opus-4-6
relates-to:
  - SEED-DRAFT-tripleontology
decisions:
  - SEED-D7
  - SEED-D8
  - SEED-D9
  - SEED-D10
  - SEED-D11
---

# Unifying (dx) Forms Under IS/AS/BY: Development Log

This document chronicles the extension of the IS/AS/BY ontology to cover `(dx)`
forms — runtime-constructed interface elements — so that the same three-axis
taxonomy governs both data at rest (`fx`) and data in motion (`dx`). It also
records the implementation of provisioning generate methods (including a working
CodeMirror integration for `:provision-text`) and CSS grid layout rendering for
manifestation sequences.

This work follows directly from the initial IS/AS/BY implementation documented
in `SEED-DRAFT-tripleontology`.


## Problem

The IS/AS/BY ontology was designed for `(fx)` forms — self-describing data at
rest, stored in files and expressed into manifestation trees. But Seed's `(dx)`
forms construct interface elements at runtime in branch code, and they remained
outside the ontology, producing old-grammar `uic-*` instances through a
class-name-based macro. This left two problems:

1. **Two incompatible grammars.** Branch code that mixed `(fx)` expression and
   `(dx)` construction produced two different kinds of objects (manifestations
   vs. `uic-*` instances), preventing unified rendering and requiring separate
   composition patterns.

2. **The aspect system was a workaround.** The `ui-aspect` class hierarchy
   (`uia-primal-dual-bank-pane`, `uia-based-pane-series`, etc.) with its `amake`
   generic and `aspect` macro existed because raw `(dx)` / `uic-*` construction
   was too low-level and repetitive for standard interface patterns. These
   aspects were implicitly encoding IS/AS/BY classifications — a
   `dual-bank-pane` is a container with `:as :workspace` and a header/body/footer
   valence; a `pane-series` is a sequence with a horizontal layout — but
   expressing them through bespoke class hierarchies rather than the ontology.

Additionally, the manifestation system lacked two capabilities needed for
real-world interface construction:

3. **No provisioning.** Rich content widgets (code editors, charts, spreadsheets,
   graph editors) were set up through `xfurnish` methods on provisioning role
   classes (`uir-pro-text`, `uir-pro-chart`, etc.). These needed equivalents in
   the manifestation system.

4. **No layout.** The spatial arrangement of sequence members (CSS grid
   positioning) was handled by the `locate` method on `uic-series`. Manifestation
   sequences had no layout support.


## Design Decisions

### SEED-D7 — (fx) and (dx) share the IS/AS/BY ontology; both produce manifestations

**Status:** Accepted
**Context:** The `(fx)` pipeline was producing manifestations classified by
IS/AS/BY. The `(dx)` pipeline was producing `uic-*` instances classified by
class name and role mixins. Branch code needed a unified object model.
**Decision:** Both `(fx)` and `(dx)` forms express the same IS/AS/BY ontology.
`(fx)` describes data at rest; `(dx)` describes data in motion. Both produce
manifestation objects. The difference is temporal, not ontological.
**Alternatives:** Keeping `(dx)` on the old grammar with a bridge adapter was
rejected as it would perpetuate two parallel object models and prevent the
retirement of the aspect system.

### SEED-D8 — AS has two sub-vocabularies; layout is a structured AS sub-form

**Status:** Accepted
**Context:** AS answers "what is your role in the containing whole?" — but
the containing whole differs between `(fx)` and `(dx)`. In `(fx)`, it is the
program; in `(dx)`, it is the interface. Layout directives describe how an
element organizes its children within the interface — a structural-role
concern.
**Decision:** AS carries two sub-vocabularies: program-semantic roles
(`:fn-called`, `:definition`, etc., applicable in `fx`) and
interface-structural roles (`:workspace`, `:controls`, `:navigation`, etc.,
applicable in `dx`). Layout is a structured sub-form under AS:
`(:as :workspace (:layout :horizontal :even))`. A `parse-as-spec` function
separates flat role keywords from `(:layout ...)` sub-forms, parallel to how
`parse-by-spec` handles `(:valence ...)` and `(:adapting ...)`.
**Alternatives:** Placing layout under BY was considered, but layout describes
an element's structural role (how it organizes its children), not how a human
engages with it. The orthogonality test confirmed they vary independently: a
horizontal series (AS: layout) can contain text editors or charts (BY:
provisioning).

### SEED-D9 — Provisioning widgets are abstract BY modalities

**Status:** Accepted
**Context:** Rich content widgets (CodeMirror, dygraph, canvas-datagrid) needed
a place in the ontology. They could sit under AS (the element's role is to be a
code editor) or BY (the element is engaged through a code editor).
**Decision:** Provisioning is BY. A widget describes how a human engages with
the content, not the element's structural role in the interface. The same element
can have different AS roles (`:workspace`, `:summary`) while keeping the same BY
(`:provision-text`), and vice versa — confirming orthogonality.
Provisioning names are abstract (`:provision-text`, not `:provision-codemirror`)
so the medium's generate methods choose the concrete widget. A `uim-web`
`:provision-text` yields CodeMirror; a future `uim-terminal` might yield a TUI
editor. The vocabulary: `:provision-text`, `:provision-sheet`,
`:provision-chart`, `:provision-graph`, `:provision-form`.
**Alternatives:** Naming concrete widgets in BY was rejected as it would tie the
ontology to specific browser libraries and break medium-independence.

### SEED-D10 — The dx macro gains a grammar-detection branch

**Status:** Accepted
**Context:** The `dx` macro in `seed.modulate` needed to support both old-grammar
(class-name-based) and new-grammar (IS/AS/BY keyword) specs during migration.
**Decision:** Follow the same pattern as `express`: the `dx` macro checks
whether the spec list starts with a keyword (new grammar) or a class symbol
(legacy grammar). New-grammar specs are delegated at runtime to a `*dx-foreign*`
hook filled by `seed.modulate2` at load time. Structured sub-forms like
`(:layout ...)` in the spec list are quoted by the macro to prevent them from
being evaluated as function calls.
**Alternatives:** A separate `dx2` macro in `modulate2` was considered but
rejected in favour of extending the existing `dx` macro for seamless migration.

### SEED-D11 — Layout positioning is applied per body group within valence

**Status:** Accepted
**Context:** Layout (CSS grid positioning) and valence (header/body grouping)
can coexist on the same sequence. The question was whether layout applies
globally to all members or per group.
**Decision:** Layout positioning is applied per body group. Each group is an
independent grid context; items within a group are positioned according to the
layout directive. Header members from valence are not positioned by layout — they
sit in the header region above the grid.
**Alternatives:** Global layout (positioning all members in one grid regardless
of valence grouping) was rejected as it would break the independence of valence
groups and produce confusing CSS grid numbering.


## Implementation

All code references are pinned to revision `53907b6`.

### `modulate/modulate.lisp`

- **`*dx-foreign*` hook** (`seed.modulate::*dx-foreign*@53907b6`): added
  alongside the existing `*express-foreign*` and `*generate-foreign*`. Accepts a
  spec plist and children list, returns a manifestation.
- **`dx-new-grammar-p@53907b6`**: compile-time predicate (wrapped in
  `eval-when`) that detects new-grammar specs by checking whether the first
  element is a keyword.
- **`dx` macro** (`seed.modulate::dx@53907b6`): gains a detection branch. When
  `dx-new-grammar-p` returns true, the macro quotes structured sub-forms to
  prevent evaluation, then emits a runtime call to `*dx-foreign*`. The legacy
  path is unchanged.

### `modulate2/package.lisp`

Updated exports (`modulate2/package.lisp@53907b6`): added `construct`,
`ensure-manifestation`, `parse-as-spec`, `parse-dx-spec`, `mfn-layout`.

### `modulate2/modulate2.lisp`

**Vocabulary updates:**

- `+as-interface-roles+@53907b6`: updated docstring clarifying that AS in `(dx)`
  describes structural role in the interface, and that layout directives are
  structured sub-forms.
- `+by-modalities+@53907b6`: added `:provision-text`, `:provision-sheet`,
  `:provision-chart`, `:provision-graph`, `:provision-form`.
- `parse-as-spec@53907b6`: new function separating flat AS role keywords from
  `(:layout ...)` sub-forms, returning two values.
- `%layout` slot added to both `mfn-sequence@53907b6` and
  `mfn-container@53907b6`.

**Expression updates:**

- `express-new@53907b6`: updated to call `parse-as-spec` on the AS spec and
  thread the parsed layout directive into sequences via the `:layout` initarg.

**Construction (the dx-side counterpart of expression):**

- `parse-dx-spec@53907b6`: walks the evaluated spec list from the `dx` macro,
  separating axis keywords and their values (including nested sub-forms like
  `(:layout ...)` and `(:valence ...)`) into a structured result. Unlike
  `parse-fx-metadata` which operates on alist-shaped metadata, this handles the
  flat interleaved keyword syntax that `(list ,@specs)` produces.
- `construct@53907b6`: the runtime counterpart of `express-new`. Builds a
  manifestation directly from a parsed spec and child values. Lists of children
  become `mfn-sequence`; single values become `mfn-atom`. Children that are
  already manifestations pass through unchanged; other values are wrapped by
  `ensure-manifestation@53907b6`.
- Bridge registration: `seed.modulate::*dx-foreign*` is set at load time to a
  closure over `construct`.

**Provisioning generate methods:**

- `provisioning-modality@53907b6`: scans a BY spec for the first `:provision-*`
  keyword.
- `generate-provisioned@53907b6`: dispatches on provisioning modality. Called
  from both the `mfn-atom` and `mfn-sequence` primary `generate` methods when a
  provisioning modality is present.
- `:provision-text` (full implementation): emits a CodeMirror container div.
  For server-fetched content (value is `(system branch)`), generates an `x-init`
  JavaScript attribute via `ps*` that registers the element in
  `window.seedElements`, calls `fetchContact` for text, and creates a CodeMirror
  instance. For direct content (value is a string), emits a div with
  `data-content`. Uses `ps*` (runtime JS generation) rather than `psl`
  (compile-time) to avoid package issues with Parenscript pseudo-variables
  (`$el`, `window`, `mode`) when compiling in the `seed.modulate2` package.
- `:provision-sheet`, `:provision-chart`, `:provision-graph`, `:provision-form`:
  structural stubs emitting properly classed divs ready for widget wiring.

**Layout rendering:**

- `locate-item@53907b6`: ports the CSS grid positioning logic from
  `seed.modulate::locate`. Handles `(:horizontal :even)`, `(:vertical :even)`,
  `(:horizontal :of N p1 p2 ...)`, and `(:vertical :of N p1 p2 ...)`. Injects
  `grid-column-start`/`grid-column-end` (or row equivalents) style attributes
  into the item's HTML tree.
- `generate-item-list@53907b6`: helper that renders members with layout applied
  per-item.
- `generate (uim-web mfn-sequence)@53907b6`: updated to add a `grid-layout` CSS
  class when a layout directive is present, and to apply layout positioning per
  body group within valence via `generate-item-list`.


## Verification

Loaded and exercised under SBCL 2.3.4 via `(asdf:load-system :seed.modulate2)`;
the system compiles clean (one pre-existing style warning, no errors).

A functional test script drove the full pipeline against a `uim-web` medium and
confirmed:

- `parse-as-spec` separating flat roles from layout directives;
- provisioning modalities present in `+by-modalities+`;
- `express-new` threading layout into `mfn-sequence` instances;
- new-grammar `dx` producing `mfn-atom` (single child) and `mfn-sequence`
  (multiple children) with correct AS, BY, name, and layout;
- nested `dx` forms: manifestation children passing through `construct`
  unchanged;
- legacy `dx` still producing `uic-series` instances;
- `:provision-text` rendering a CodeMirror div with `x-init` JavaScript
  (server-fetched) and a `data-content` div (direct content);
- stub provisioning modalities (sheet, chart, graph) emitting structural HTML;
- `(:horizontal :even)` layout emitting `grid-column-start`/`grid-column-end`
  style attributes on each item;
- `(:vertical :of 3 1 1 1)` layout emitting `grid-row` positioning;
- layout + valence: header in `mfn-header`, body groups with per-group grid
  positioning;
- regressions: `:reducing` controls (2 per 2-member sequence), legacy `dx`,
  bridge delegation, nested `dx` — all unchanged.

Result: all checks passed. Rendered HTML inspected for CodeMirror provisioning,
horizontal-even layout, and layout-plus-valence; all matched intended structure.


## Files

| File | Action | Description |
|------|--------|-------------|
| `modulate/modulate.lisp` | Modified | `*dx-foreign*` hook, `dx-new-grammar-p`, `dx` macro grammar-detection branch. |
| `modulate2/package.lisp` | Modified | Exports for `construct`, `ensure-manifestation`, `parse-as-spec`, `parse-dx-spec`, `mfn-layout`. |
| `modulate2/modulate2.lisp` | Modified | Provisioning BY vocabulary, `parse-as-spec`, `%layout` slots, `express-new` AS parsing, `parse-dx-spec`, `construct`, `ensure-manifestation`, `generate-provisioned` (CodeMirror + stubs), `locate-item`, `generate-item-list`, layout-aware sequence rendering, `*dx-foreign*` registration. |


## Outstanding Work

- **Provisioning widget wiring.** `:provision-sheet` (canvas-datagrid),
  `:provision-chart` (dygraph), `:provision-graph` (SVG graph editor), and
  `:provision-form` are stubs emitting structural HTML only. Full JavaScript
  setup remains to be ported from the `xfurnish` methods.
- **Aspect system retirement.** The `ui-aspect` class hierarchy, the `aspect`
  macro, `amake`, and the helper functions (`uia-cpanel-sandwich`,
  `%uia-cpanel-sw2`) can be removed once all branch code is converted to direct
  manifestation construction with IS/AS/BY.
- **Layout vocabulary expansion.** Only `(:horizontal :even)`,
  `(:vertical :even)`, `(:horizontal :of ...)`, and `(:vertical :of ...)` are
  implemented. Grid patterns and other layout directives will be added as usage
  demands.
- **Portal development with new dx.** The next milestone is developing
  `demo.access` using the new `(dx)` ontology end-to-end, which will exercise
  provisioning, layout, and the full expression/construction pipeline in a real
  portal.
