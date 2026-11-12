---
id:            SEED-0003
title:         "IS/AS/BY Ontology and Manifestation Pipeline: Development Log"
genre:         Log
scope:         component
project:       Seed
component:     modulate2
language:      en
status:        Implemented
authors:
  - Andrew Sengul
approved-by:   Andrew Sengul
reviewed:      2026-11-12

provenance:
  assistant:   claude-opus-5-5
  session:     ses_1ffba4ccdffebiWc572stLkOTO
relates-to:
  - SEED-0004
  - SEED-0005
  - SEED-DRAFT-classicinterface
cites:
  - title:     "CLIM II Specification"
    locator:   "Part VI: Extended Stream Input Facilities, §23 Presentation Types"
    external:  true
  - title:     "WAI-ARIA 1.2"
    locator:   "W3C Recommendation, 2023"
    external:  true
  - title:     "Naked Objects"
    locator:   "Pawson, R. PhD thesis, Trinity College Dublin, 2004"
    external:  true
  - title:     "Glamorous Toolkit"
    locator:   "Girba, T. feenk.com"
    external:  true
  - title:     "Semiology of Graphics"
    locator:   "Bertin, J. University of Wisconsin Press, 1983 (French original 1967)"
    external:  true
decisions:
  - SEED-D13
  - SEED-D14
  - SEED-D15
  - SEED-D16
  - SEED-D17
  - SEED-D18
  - SEED-D19
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

### SEED-D13 — Three-axis IS/AS/BY ontology

**Status:** Implemented
**Context:** `(fx)` annotations needed to answer "what is this / why is it here /
how is it accessed" independently. A four-axis scheme (adding a separate
compositional-structure axis) was on the table.
**Decision:** Adopt exactly three annotation axes — IS (data character), AS
(semantic role), BY (interaction modality). Compositional structure is expressed
by the manifestation object's class, not by a fourth annotation axis.
**Alternatives:** The four-axis scheme was rejected as redundant: structure is
already implied by whether a value is atomic or a collection, so encoding it
twice (as class and as annotation) invited drift.

### SEED-D14 — IS carries two strata; stratum 2 is never presumptuously inferred

**Status:** Implemented
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

### SEED-D15 — Manifestation class hierarchy with IS/AS/BY as slot data

**Status:** Implemented
**Context:** The object tree needed a small structural spine while keeping the
three axes as data consulted at render time.
**Decision:** Define `manifestation` as the base class with slots for value, is,
as, by, name, path, adapting, and controls; specialize it as `mfn-atom`
(leaf / compound-atomic), `mfn-sequence` (ordered members, optional valence), and
`mfn-container` (structured members). The axes are slot values, not subclasses.
**Alternatives:** Encoding each axis combination as its own class (as the
original `uic-*`/`uicc-*` catalogue did) was rejected as combinatorial and
brittle.

### SEED-D16 — Two-tier processor pipeline

**Status:** Implemented
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

### SEED-D17 — Registration-hook bridge between modulate and modulate2

**Status:** Implemented
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

### SEED-D18 — `:bare` suppresses Tier-1 defaults

**Status:** Implemented
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
  `modulate/modulate.lisp:*express-foreign*@aeedefb` and
  `modulate/modulate.lisp:*generate-foreign*@aeedefb` are filled by `modulate2`
  at load time; `modulate/modulate.lisp:*generate-bouncing*@aeedefb` guards
  against infinite mutual delegation.
- `modulate/modulate.lisp:express-new-grammar-p@aeedefb` detects a new-grammar
  form: an `(fx)` form whose metadata carries at least one of `:is`/`:as`/`:by`
  and no `:fx`. Because every existing data file uses `:fx`, this disambiguates
  cleanly.
- `modulate/modulate.lisp:express@aeedefb` gained a `&key processors` parameter
  and a branch that, when the hook is set and the form is new-grammar, delegates
  to `*express-foreign*`; otherwise it runs the unchanged legacy path.
- A catch-all method `modulate/modulate.lisp:generate@aeedefb` specialized on
  `(uim-web t)` delegates any component with no native method to
  `*generate-foreign*`, so a manifestation embedded in a legacy tree still
  renders; the bouncing guard turns an unrecognized component into a clean error
  rather than a loop.

### `modulate2/package.lisp`

The `seed.modulate2` package (`modulate2/package.lisp@aeedefb`) uses `cl`, `symbol-munger`,
and `spinneret`; shadow-imports `uim-web` and `render` from `seed.modulate`; and
exports the pipeline entry points (`express-new`, `manifest`,
`apply-named-processors`, `apply-modality-defaults`, `make-control`, `generate`),
the spec parsers, the manifestation classes and accessors, the IS inferrer, and
the vocabulary constants.

### `modulate2/modulate2.lisp`

The subsystem proper.

- **IS inference.** `modulate2/modulate2.lisp:infer-data-character@aeedefb`
  maps a value to a stratum-1 keyword by `typecase`.
- **Vocabularies.** `modulate2/modulate2.lisp:+as-program-roles+@aeedefb`,
  `modulate2/modulate2.lisp:+as-atomic-roles+@aeedefb`,
  `modulate2/modulate2.lisp:+as-interface-roles+@aeedefb`, and
  `modulate2/modulate2.lisp:+by-modalities+@aeedefb` enumerate the AS and BY
  vocabularies; `+by-modalities+` includes `:bare`.
- **Classes.** `modulate2/modulate2.lisp:manifestation@aeedefb` and its
  subclasses `modulate2/modulate2.lisp:mfn-atom@aeedefb`,
  `modulate2/modulate2.lisp:mfn-sequence@aeedefb`,
  `modulate2/modulate2.lisp:mfn-container@aeedefb`.
- **Spec parsing.** `modulate2/modulate2.lisp:parse-by-spec@aeedefb` separates
  flat modality keywords from the structured `(:valence ...)` and
  `(:adapting ...)` sub-forms;
  `modulate2/modulate2.lisp:parse-fx-metadata@aeedefb` splits an `(fx)` form's
  metadata into the axis values.
- **Expression.** `modulate2/modulate2.lisp:express-new@aeedefb` walks a form
  into a manifestation tree, inferring IS, resolving BY defaults by context, and
  using `modulate2/modulate2.lisp:atomic-as-p@aeedefb` so that a list value with
  an atomic `:as` role (`:fn-called`, `:definition`, `:code`, …) stays an
  `mfn-atom` rather than being read as a sequence.
- **Tier 2.** `modulate2/modulate2.lisp:apply-named-processors@aeedefb` walks
  the tree depth-first (children before parent) applying `:adapting` closures
  from the lexicon; `modulate2/modulate2.lisp:manifest@aeedefb` composes
  `express-new` then Tier 2.
- **Tier 1.** `modulate2/modulate2.lisp:apply-modality-defaults@aeedefb` is a
  generic on `(medium node)`; the `(uim-web mfn-sequence)` method injects
  affordances unless the node is `:bare`. `:reducing` is injected and rendered
  by `modulate2/modulate2.lisp:apply-reducing-default@aeedefb`, which pushes a
  remove control (built by `modulate2/modulate2.lisp:make-control@aeedefb`,
  targeting the member's path) into each member's header. The rendered controls
  carry `data-action` and `data-target` attributes; client-side dispatch to
  make them functional is not yet wired.
  `modulate2/modulate2.lisp:apply-sorting-default@aeedefb` and
  `modulate2/modulate2.lisp:apply-extending-default@aeedefb` are stubs.
- **Rendering.** The `:around` method of
  `modulate2/modulate2.lisp:generate@aeedefb` on `(uim-web manifestation)`
  applies Tier-1 defaults once, then the primary methods render.
  `modulate2/modulate2.lisp:emit-header@aeedefb` places injected controls and
  valence header members in a shared `mfn-header`;
  `modulate2/modulate2.lisp:split-by-valence@aeedefb` divides members into
  header and body groups. The `seed.modulate::render` method on
  `(uim-web manifestation)`, defined in `modulate2/modulate2.lisp@aeedefb`,
  serializes the tree via spinneret.
- **Bridge registration.** At load time the file sets
  `modulate/modulate.lisp:*express-foreign*@aeedefb` to a closure over
  `manifest` and `modulate/modulate.lisp:*generate-foreign*@aeedefb` to a
  closure over `generate`.


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
matched the intended header/body structure. The test script was not kept; a
modulate2 test suite is listed in Outstanding Work.


## Files

Table: Files changed or created for the IS/AS/BY ontology. The work spans
several commits; `aeedefb` is the pinned snapshot.

| File | Action | Description |
|------|--------|-------------|
| `modulate2/modulate2.lisp` | **New** | IS/AS/BY ontology, manifestation classes, expression, two-tier pipeline, generate/render, bridge registration. |
| `modulate2/package.lisp` | **New** | `seed.modulate2` package: pipeline exports, classes, vocabularies. |
| `modulate2/seed.modulate2.asd` | **New** | ASDF system, depending on `seed.modulate`. |
| `modulate/modulate.lisp` | Modified | Registration-hook variables, `express-new-grammar-p`, new-grammar delegation branch in `express`, catch-all `generate`. |
| `modulate/package.lisp` | Modified | Commented-out import from `seed.modulate2`, superseded by the registration-hook bridge (SEED-D17). |
| `modulate/seed.modulate.asd` | Modified | Commented-out dependency on `seed.modulate2`, superseded by the registration-hook bridge (SEED-D17). |


## Outstanding Work

- **Client-side dispatch for `:activating` controls.** The rendered
  `data-action`/`data-target` attributes have no listener. This is the
  first prerequisite for the Classic interface mode
  (SEED-DRAFT-classicinterface, step A1).
- **Tier-1 `:sorting` and `:extending`.** Both are stubs. `:sorting` should
  inject a per-item drag-handle wrapper (uim-web: htmx/Alpine drag-and-drop);
  `:extending` should inject an add-item control into the sequence's own header.
- **A modulate2 test suite.** The functional test script used during
  verification was not kept. A FiveAM suite should be created to pin the
  pipeline's behaviour.
- **Deep mixed-grammar nesting.** The bounce guard makes new-inside-old and
  old-inside-new render correctly at one level, but pathological deep alternation
  can reach the guard and error rather than render. Acceptable during migration;
  revisit if it arises, likely by extracting the shared base of
  SEED-D17.
- **Contextual IS inference directives.** The mechanism to let a marked code
  region authorize stratum-2 inference (e.g. "here, key/value lists are plists")
  is designed-for but not built.
- **`mfn-container` named regions.** The container currently holds an ordered
  member list like a sequence; addressing members by named region awaits a
  concrete use case.
- **Retirement of `seed.modulate`.** The bridge is transitional. As forms migrate
  to the new grammar, the legacy expression and component classes are to be
  removed, at which point SEED-D17's shared-base option
  should be reconsidered.


## Update 2026-11-12 — The IS/AS boundary for formats and languages

During the design of the Classic interface mode (SEED-DRAFT-classicinterface),
a question arose: where do format annotations like `:markdown` and `:lexis`
sit in the IS/AS taxonomy? Classic's `:format` slot option assigns a source
format to body data, and the Classic→fx bridge must map this to one of the
axes.

### SEED-D19 — IS stratum-2 is for CL-level structural properties; external-language formats are AS program-semantic roles

**Status:** Implemented

**Context:** IS stratum-2 was defined as "conventional interpretation the
developer asserts" (SEED-D14), with examples `:properties`, `:associations` and
`:pathname`. Format annotations like `:markdown`, `:lexis` and `:sql`
also describe a datum beyond its Lisp type. The boundary between IS
stratum-2 and AS needed to be made explicit. This decision refines
SEED-D14.

**Decision:** The distinguishing test is whether Common Lisp itself has
native vocabulary for the property. IS stratum-2 covers structural
properties the Lisp program traverses through CL-level APIs:
`:properties` (plist access via `getf`), `:associations` (alist access
via `assoc`), `:pathname` (pathname operations via `namestring`,
`merge-pathnames`). External-language formats — `:markdown` (needs a
parser like 3bmd), `:lexis` (needs the Lexis reader), `:sql` (needs a
database driver) — require external software or specialised libraries to
interpret. They describe the datum's role in the application's topology
of software utilities: what the string is *for* within the program at the
application level. They are therefore **AS program-semantic roles**,
extending the existing `+as-program-roles+` vocabulary.

**Alternatives:** Placing formats under IS stratum-2 (rejected: it would
make IS a catch-all for any assertion about a value, erasing the boundary
with AS). Creating a third AS sub-vocabulary for formats (rejected:
formats describe program-level role, the same concern as the existing
program-semantic sub-vocabulary).
