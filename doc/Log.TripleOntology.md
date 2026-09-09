---
id:            SEED-DRAFT-tripleontology
title:         IS/AS/BY Ontology and Manifestation Pipeline Development Log
genre:         Log
scope:         component
project:       Seed
component:     modulate2
language:      en
status:        Draft
provenance:
  assistant:   claude-opus-4-8
decisions:
  - SEED-D1
  - SEED-D2
  - SEED-D3
  - SEED-D4
  - SEED-D5
  - SEED-D6
---

# IS/AS/BY Ontology and Manifestation Pipeline: Development Log

This document chronicles the design and first implementation of `seed.modulate2`
— a new expression subsystem that reads `(fx)`-annotated data through a
three-axis ontology (**IS / AS / BY**), builds a *manifestation* object tree
from it, and renders that tree to a medium. `modulate2` is the successor to the
`ui-component` / `ui-role` machinery in `seed.modulate`. It is introduced
alongside the original system, bridged to it, so that forms can be migrated to
the new grammar one at a time before the original is retired.

The design is captured by a single formula settled during this work:

> Triple identity resolved by triple ontology manifest through triple faculty,
> enabling fourth-degree control to harmonize dual domains as a unitary system.

The *triple identity* is what an `(fx)` form carries at once — code, data, and
interaction specification. The *triple ontology* is IS/AS/BY. The *triple
faculty* is Seed's three operations: generate, modulate, sublimate. *Fourth-degree
control* names write-time control, one degree beyond the conventional three
(run-time, compile-time, read-time). The *dual domains* are mechanism and
expression — the internal structure and the outward presentation — which Seed
unifies because an `(fx)` form is at once the program and its interface.


## Problem

Seed's promise is *self-describing data*: a datum annotated with an `(fx)` form
carries its own interaction profile, enabling write-time control over how it is
expressed, edited, and processed. Realizing that promise requires a robust
ontology for the annotations. The original `seed.modulate` grammar did not
provide one.

In the original system an `(fx)` form names a concrete UI class directly, e.g.
`(:fx :uicc-field)`, `(:fx :uic-series)`, and decorates it with `(:type ...)`
and `(:role ...)` metadata. This couples the data to a fixed catalogue of
component classes and a parallel catalogue of role mixins (`uir-sortable`,
`uir-reducable`, `uir-toggle`, and the rest). The taxonomy had grown to serve a
range of cases but could not cleanly express three orthogonal questions that a
self-describing datum must answer:

- **What is this?** — its intrinsic data character (a number, a string, a
  key/value list) and finer structural identity.
- **Why is it here?** — its semantic role in the surrounding program or
  interface.
- **How is it accessed?** — the interaction modality by which a user observes
  or changes it.

Conflating these under a single "pick a component class" decision made the data
brittle and the renderer a growing thicket of conditionals. The goal was a
grammar in which those three axes are named independently, the intrinsic axis is
inferred where possible, and interface affordances are attached by rule rather
than by hand.


## Investigation

The taxonomy was derived from a study of five systems for composable object
specification and interface design. Each contributed a distinct idea; none was
adopted wholesale.

- **CLIM 2 presentation types.** The CLIM type lattice (`integer` ⊂ `rational`
  ⊂ `real` ⊂ `number`; the "one-of"/"some-of" completion types; the `or`/`and`
  meta-types) is the model for the **IS** axis: a datum's presentation follows
  from its type, and types compose. IS keeps CLIM's insight that the intrinsic
  character of a value is normally derivable from its Lisp type, and only needs
  explicit statement at the edges.

- **WAI-ARIA roles.** ARIA's split between *widget* roles (interaction surfaces
  such as `slider`, `textbox`, `option`) and *structure* roles (`section`,
  `group`, `landmark`) informed the division between the **BY** axis
  (interaction modality) and the interface side of the **AS** axis (structural
  role). ARIA demonstrates that "how it behaves" and "what part it plays" are
  separate classifications.

- **Naked Objects (behavioural completeness).** The thesis that user views
  should be generated automatically from behaviourally complete objects, with
  generic and selective views derived rather than hand-drawn, is the direct
  ancestor of the *manifestation* idea and of the two-tier processor model:
  standard affordances follow generically from an object's declared modality;
  context-specific ones are layered on per view.

- **Girba's Glamorous Toolkit.** GT's principle that a single object supports
  many intrinsic views (list, tree, columned, Mondrian, text) reinforced that
  IS/AS/BY should describe the datum, not commit it to one rendering — the same
  manifestation can be generated differently per medium and per context.

- **Bertin's *Semiology of Graphics*.** Bertin's matching of graphical metaphors
  to information types underwrites the eventual medium layer: choosing the right
  presentation for a datum's character is a rule keyed on IS/AS/BY, not a
  property baked into the data.

Two conclusions from the design sessions shaped the axes further. First, the
**IS** axis has two strata: a *structural identity* the type system can verify
(`:integer`, `:string`, `:list`) and a *conventional interpretation* the
developer asserts (`:properties`, `:associations`, `:pathname`). The latter is
not provable from the data — a key/value list is not intrinsically a property
list, just as IBM System Z packed decimal carries digits and sign but no decimal
point; the fixpoint reading lives in the program, not the format. Stratum-2
identity is therefore never inferred presumptuously; it comes from explicit
annotation (and, eventually, from an explicit contextual directive that
authorizes an inference). Second, an earlier four-axis proposal (data character,
data role, interaction modality, compositional structure) was reduced to three:
compositional structure became the *class* of the manifestation object rather
than an annotation axis, leaving IS/AS/BY as the annotation ontology.


## Design Decisions

### SEED-D1 — Three-axis IS/AS/BY ontology

**Status:** Accepted
**Context:** `(fx)` annotations needed to answer "what is this / why is it here /
how is it accessed" independently. A four-axis scheme (adding a separate
compositional-structure axis) was on the table.
**Decision:** Adopt exactly three annotation axes — IS (data character), AS
(semantic role), BY (interaction modality). Compositional structure is expressed
by the manifestation object's class, not by a fourth annotation axis.
**Alternatives:** The four-axis scheme was rejected as redundant: structure is
already implied by whether a value is atomic or a collection, so encoding it
twice (as class and as annotation) invited drift.

### SEED-D2 — IS carries two strata; stratum 2 is never presumptuously inferred

**Status:** Accepted
**Context:** Sub-classifications like "plist" or "pathname" are developer
assertions, not facts derivable from the value.
**Decision:** Split IS into stratum-1 structural identity (inferred from the
Lisp type by `infer-data-character`) and stratum-2 conventional interpretation
(supplied explicitly, e.g. `(:is :- :properties)`, where `:-` means "inferred
base type plus these specializers"). The inferrer emits only stratum-1 keywords.
**Alternatives:** Heuristic detection of plist/alist shape was rejected as
presumptuous — the packed-decimal analogy. A contextual-directive mechanism that
*authorizes* such inference in a marked code region is noted as future work, not
built now.

### SEED-D3 — Manifestation class hierarchy with IS/AS/BY as slot data

**Status:** Accepted
**Context:** The object tree needed a small structural spine while keeping the
three axes as data consulted at render time.
**Decision:** Define `manifestation` as the base class with slots for value, is,
as, by, name, path, adapting, and controls; specialize it as `mfn-atom`
(leaf / compound-atomic), `mfn-sequence` (ordered members, optional valence), and
`mfn-container` (structured members). The axes are slot values, not subclasses.
**Alternatives:** Encoding each axis combination as its own class (as the
original `uic-*`/`uicc-*` catalogue did) was rejected as combinatorial and
brittle.

### SEED-D4 — Two-tier processor pipeline

**Status:** Accepted
**Context:** Some affordances belong to any element of a given modality
(a removable list wants remove buttons); others are branch-specific (an upload
dialog for an empty entity list). Wrapping nil values to serve buttons was
identified as an anti-pattern.
**Decision:** Run expression in two tiers. Tier 2 is named `:adapting`
processors: branch-supplied closures, declared as hooks in the form's `:by`
spec, applied to the manifestation tree in series, with silent absence when a
hook has no matching processor. Tier 1 is modality-driven defaults: affordances
attached automatically from a node's `:by` modalities. Tier 2 runs first so its
additions can be picked up by Tier 1.
**Alternatives:** An `:attaching` point-to-point model (the form names a slot the
branch fills) was rejected in favour of postprocessors that inspect the whole
tree and respond to discovered conditions.

### SEED-D5 — Registration-hook bridge between modulate and modulate2

**Status:** Accepted
**Context:** `seed.modulate2` depends on `seed.modulate` (for `uim-web` and
`render`). Making `seed.modulate` call into `seed.modulate2` would close a
dependency cycle that ASDF forbids.
**Decision:** Keep the ASDF graph acyclic (`modulate2 → modulate`). `modulate`
exposes hook variables (`*express-foreign*`, `*generate-foreign*`) that
`modulate2` fills at load time. `modulate` delegates new-grammar work through the
hooks; `modulate2`, which may name `modulate` directly, delegates back via a
catch-all `generate` method. A guard variable prevents infinite mutual bouncing.
**Alternatives:** Extracting a shared base system holding the media classes and
generics (the "most correct" long-term shape) was deferred as churn that would be
discarded when `modulate` is retired. Merging the two systems was rejected: the
migration requires them separate.

### SEED-D6 — `:bare` suppresses Tier-1 defaults

**Status:** Accepted
**Context:** A form may want a modality's semantics without its auto-generated
controls.
**Decision:** A `:bare` keyword in a node's `:by` spec suppresses all Tier-1
default affordances for that node. Render-method shadowing remains the escape
hatch for finer control.
**Alternatives:** Per-modality suppression keywords were rejected as heavier than
the common case warrants; whole-node opt-out covers it.


## Implementation

All code references are pinned to revision `aeedefb`.

### `modulate/modulate.lisp`

The bridge from the original system to the new one lives here, entirely in
additive terms — no existing behaviour changed.

- Three hook variables were added after the `generate` generic:
  `seed.modulate::*express-foreign*@aeedefb` and
  `seed.modulate::*generate-foreign*@aeedefb` are filled by `modulate2` at load
  time; `seed.modulate::*generate-bouncing*@aeedefb` guards against infinite
  mutual delegation.
- `seed.modulate::express-new-grammar-p@aeedefb` detects a new-grammar form: an
  `(fx)` form whose metadata carries at least one of `:is`/`:as`/`:by` and no
  `:fx`. Because every existing data file uses `:fx`, this disambiguates
  cleanly.
- `seed.modulate::express@aeedefb` gained a `&key processors` parameter and a
  branch that, when the hook is set and the form is new-grammar, delegates to
  `*express-foreign*`; otherwise it runs the unchanged legacy path.
- A catch-all method `seed.modulate::generate@aeedefb` specialized on
  `(uim-web t)` delegates any component with no native method to
  `*generate-foreign*`, so a manifestation embedded in a legacy tree still
  renders; the bouncing guard turns an unrecognized component into a clean error
  rather than a loop.

### `modulate2/package.lisp`

`seed.modulate2` (`modulate2/package.lisp@aeedefb`) uses `cl`, `symbol-munger`,
and `spinneret`; shadow-imports `uim-web` and `render` from `seed.modulate`; and
exports the pipeline entry points (`express-new`, `manifest`,
`apply-named-processors`, `apply-modality-defaults`, `make-control`, `generate`),
the spec parsers, the manifestation classes and accessors, the IS inferrer, and
the vocabulary constants.

### `modulate2/modulate2.lisp`

The subsystem proper.

- **IS inference.** `seed.modulate2::infer-data-character@aeedefb` maps a value
  to a stratum-1 keyword by `typecase`.
- **Vocabularies.** `+as-program-roles+`, `+as-atomic-roles+`,
  `+as-interface-roles+`, and `+by-modalities+` (all `@aeedefb`) enumerate the
  AS and BY vocabularies; `+by-modalities+` includes `:bare`.
- **Classes.** `seed.modulate2::manifestation@aeedefb` and its subclasses
  `mfn-atom`, `mfn-sequence`, `mfn-container` (all `@aeedefb`).
- **Spec parsing.** `seed.modulate2::parse-by-spec@aeedefb` separates flat
  modality keywords from the structured `(:valence ...)` and `(:adapting ...)`
  sub-forms; `parse-fx-metadata@aeedefb` splits an `(fx)` form's metadata into
  the axis values.
- **Expression.** `seed.modulate2::express-new@aeedefb` walks a form into a
  manifestation tree, inferring IS, resolving BY defaults by context, and using
  `atomic-as-p@aeedefb` so that a list value with an atomic `:as` role
  (`:fn-called`, `:definition`, `:code`, …) stays an `mfn-atom` rather than being
  read as a sequence.
- **Tier 2.** `seed.modulate2::apply-named-processors@aeedefb` walks the tree
  depth-first (children before parent) applying `:adapting` closures from the
  lexicon; `manifest@aeedefb` composes `express-new` then Tier 2.
- **Tier 1.** `seed.modulate2::apply-modality-defaults@aeedefb` is a generic on
  `(medium node)`; the `(uim-web mfn-sequence)` method injects affordances unless
  the node is `:bare`. `:reducing` is implemented end to end by
  `apply-reducing-default@aeedefb`, which pushes a remove control (built by
  `make-control@aeedefb`, targeting the member's path) into each member's header.
  `apply-sorting-default@aeedefb` and `apply-extending-default@aeedefb` are
  stubs.
- **Rendering.** A `generate :around` method on `(uim-web manifestation)`
  (`@aeedefb`) applies Tier-1 defaults once, then the primary methods render.
  `emit-header@aeedefb` places injected controls and valence header members in a
  shared `mfn-header`; `split-by-valence@aeedefb` divides members into header and
  body groups. The `render` method on `manifestation` (`@aeedefb`) serializes the
  tree via spinneret.
- **Bridge registration.** At load time the file sets
  `seed.modulate::*express-foreign*` to a closure over `manifest` and
  `seed.modulate::*generate-foreign*` to a closure over `generate`.


## Verification

Loaded and exercised under SBCL 2.3.4 via
`(asdf:load-system :seed.modulate2)`; the system compiles clean.

A functional test script drove the full pipeline against a `uim-web` medium and
confirmed, per case:

- data-character inference for a bare atom;
- the atomic-`:as` fix — `(fx (+ 1 2) (:as :fn-called))` yields an `mfn-atom`,
  while a list of `(fx)` members yields an `mfn-sequence`;
- `parse-by-spec` separating modalities, valence, and adapting hooks;
- Tier-1 `:reducing` injecting exactly one remove control per member, each with
  the correct `data-target` path;
- `:bare` suppressing that injection;
- a named `:adapting` processor running and replacing a node, and a declared
  hook with no matching processor being silently skipped;
- the bridge: `seed.modulate:express` returning a manifestation for a
  new-grammar form and an unchanged `uic-series` / `uicc-field` for legacy
  forms.

Result: all checks passed; the legacy expression path was confirmed unchanged.
Rendered HTML for the `:reducing` and `:valence (-1 2)` cases was inspected and
matched the intended header/body structure.


## Files

Files touched by this work. `New` marks files first written for the subsystem;
`Modified` marks additive changes to the original system.

| File | Action | Description |
|------|--------|-------------|
| `modulate2/package.lisp` | **New** | `seed.modulate2` package: pipeline exports, classes, vocabularies. |
| `modulate2/seed.modulate2.asd` | **New** | ASDF system, depending on `seed.modulate`. |
| `modulate2/modulate2.lisp` | **New** | IS/AS/BY ontology, manifestation classes, expression, two-tier pipeline, generate/render, bridge registration. |
| `modulate/modulate.lisp` | Modified | Registration-hook variables, `express-new-grammar-p`, new-grammar delegation branch in `express`, catch-all `generate`. |


## Outstanding Work

- **Tier-1 `:sorting` and `:extending`.** Both are stubs. `:sorting` should
  inject a per-item drag-handle wrapper (uim-web: htmx/Alpine drag-and-drop);
  `:extending` should inject an add-item control into the sequence's own header.
- **Deep mixed-grammar nesting.** The bounce guard makes new-inside-old and
  old-inside-new render correctly at one level, but pathological deep alternation
  can reach the guard and error rather than render. Acceptable during migration;
  revisit if it arises, likely by extracting the shared base of SEED-D5.
- **Contextual IS inference directives.** The mechanism to let a marked code
  region authorize stratum-2 inference (e.g. "here, key/value lists are plists")
  is designed-for but not built.
- **`mfn-container` named regions.** The container currently holds an ordered
  member list like a sequence; addressing members by named region awaits a
  concrete use case.
- **Retirement of `seed.modulate`.** The bridge is transitional. As forms migrate
  to the new grammar, the legacy expression and component classes are to be
  removed, at which point SEED-D5's shared-base option should be reconsidered.
