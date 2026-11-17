---
id:            SEED-DRAFT-classiccms
title:         "The Classic CMS in the New Grammar: Development Plan"
genre:         Plan
scope:         project
project:       Seed
language:      en
status:        Accepted
authors:
  - Andrew Sengul
approved-by:   Andrew Sengul
reviewed:      2026-11-16
provenance:
  assistant:   claude-opus-5-5
relates-to:
  - SEED-0011
  - SEED-0003
  - SEED-0004
  - SEED-0008
  - SEED-0009
  - SEED-0012
  - SEED-0014
cites:
  - title:     "Exact: Essential eXpression Articulating Coherent Topology"
    locator:   "~/src/chat/Exact.md"
    external:  true
decisions:
  - SEED-DRAFT-classiccms-D1
  - SEED-DRAFT-classiccms-D2
  - SEED-DRAFT-classiccms-D3
  - SEED-DRAFT-classiccms-D4
  - SEED-DRAFT-classiccms-D5
  - SEED-DRAFT-classiccms-D6
open-questions:
  - SEED-DRAFT-classiccms-O1
  - SEED-DRAFT-classiccms-O2
  - SEED-DRAFT-classiccms-O3
  - SEED-DRAFT-classiccms-O4
  - SEED-DRAFT-classiccms-O5
  - SEED-DRAFT-classiccms-O6
  - SEED-DRAFT-classiccms-O7
---

# The Classic CMS in the New Grammar: Development Plan

This plan turns the Classic interface Survey (SEED-0011) into
work. It moves the CMS in `systems/demo.access` from the old interface grammar
to the IS/AS/BY grammar of `modulate2` (SEED-0003, SEED-0004) one view at a
time, building in `modulate2` the pieces each view needs: tests first, then
client dispatch for `:activating` controls, then submittable forms. Its first
deliverable is a working Create, which is broken today. The plan details steps
0–7, which cover the Survey's increments A1–A3, and keeps the later increments
(B–E) in outline. It is expected to change as the work shows what is needed.

All code references are pinned to revision `7a82b07`.


## Problem

The CMS is the main development target for the new grammar, but the two
documents behind it describe concepts, not the code that exists. The
Survey sets the direction and the increments; SEED-0003 and SEED-0004 record
the ontology and the first implementation. Neither says what `modulate2` can
and cannot yet do, and the first increment the Survey proposes depends on
infrastructure that does not exist.

Meanwhile the CMS's Create button does not work, so the rule the Survey sets —
a working CMS at every step — is already broken.

### Starting point: modulate2

`modulate2` expresses data annotated with IS/AS/BY as a tree of
*manifestations* and renders the tree for a medium:

- **Expression.** `modulate2/modulate2.lisp:express-new@7a82b07` walks a stored
  `fx` form into `mfn-atom` and `mfn-sequence` nodes, resolving IS (with the
  `:-` sentinel for "inferred type plus asserted specializers", in
  `modulate2/modulate2.lisp:resolve-is@7a82b07`) and defaulting BY by context.
  `modulate2/modulate2.lisp:construct@7a82b07` builds the same nodes from live
  values when the `dx` macro sees a keyword spec list
  (`modulate/modulate.lisp:dx@7a82b07`). `mfn-container` is defined but
  neither path constructs it.
- **Processors.** `modulate2/modulate2.lisp:manifest@7a82b07` applies a
  branch's named `:adapting` processors (Tier 2). Tier-1 defaults run at
  generation: `:reducing` injects remove controls
  (`modulate2/modulate2.lisp:apply-reducing-default@7a82b07`); `:sorting`
  and `:extending` are stubs
  (`modulate2/modulate2.lisp:apply-sorting-default@7a82b07`,
  `modulate2/modulate2.lisp:apply-extending-default@7a82b07`).
- **Rendering.** `generate` renders atoms by modality — `:observing` as text,
  `:entering` as a labelled named input, `:choosing` as a select, `:cycling`
  as a button — and sequences as item lists with optional valence and grid
  layout. Of the provisioning modalities
  (`modulate2/modulate2.lisp:generate-provisioned@7a82b07`), only
  `:provision-text` works, creating a CodeMirror editor that loads its text
  through the branch's text protocol. The editor is always in Lisp mode:
  the client's constructor takes no language argument, and the client build
  imports only the Lisp and Python languages
  (`platform/browser/pla.browser.maple/maple.lisp:build-script-cmirror@7a82b07`).
  `@codemirror/lang-markdown` is present in the CodeMirror npm interface's
  `node_modules` only as an indirect dependency, pulled in at version 6.0.0
  by `@nextjournal/clojure-mode`; the interface's `package.json` does not
  declare it. `:provision-sheet`, `:provision-chart`, `:provision-graph` and
  `:provision-form` emit empty placeholder elements.
- **Bridges.** Old and new grammar mix in one tree in both directions, through
  the `*express-foreign*`, `*generate-foreign*` and `*dx-foreign*` hooks.

Three gaps matter for the CMS:

1. **Controls do nothing.** `modulate2/modulate2.lisp:make-control@7a82b07`
   builds `:activating` atoms, rendered as buttons with `data-action` and
   `data-target` attributes, but no client code responds to them. Branch code
   can call `make-control` (it is exported), but it takes no arguments beyond
   action, label and target — there is no `data-args` — and a `dx` form with
   a list value becomes a sequence, not a control.
2. **There are no forms.** `:provision-form` renders an empty `<form>` and
   drops its members; nothing gathers named fields and submits them.
3. **There are no tests.** SEED-0004 records that its test script was not
   kept; `test/` holds only Philo's tests.

A smaller defect: `construct` uses an explicit IS as given, without
`resolve-is`, so the `:-` sentinel works in stored `fx` forms but not in
`dx`.

### Starting point: the CMS

The `:cms` branch in `systems/demo.access/seed.lisp@7a82b07` is old grammar
throughout. Its handler is a `cond` over action strings, plus a text protocol
for CodeMirror. Its three views are built by
`systems/demo.access/seed.lisp:render-cms-list@7a82b07`,
`systems/demo.access/seed.lisp:render-cms-create@7a82b07` and
`systems/demo.access/seed.lisp:render-cms-edit@7a82b07`; the create and edit
views post their data with inline JavaScript strings.

Create has not been diagnosed. Reading the code suggests three candidates:

- The title field is an old-grammar `uicc-field`, whose generated input posts
  each change of its value through
  `platform/browser/pla.browser.maple/maple.lisp:field-in@7a82b07`. The `:cms`
  branch does not recognise that payload, so it falls through to its default
  case and renders the create view on the server. The response is encoded as
  JSON like any other (by `json-convert-to`, in
  `platform/browser/pla.browser.maple/maple.lisp:implement-start-controls@7a82b07`),
  so the client receives it without error; whether the stray request and its
  render interfere with Create is to be confirmed.
- The button's script finds the fields by walking the page
  (`closest('.series')`, then `[name=title]`), which depends on the rendered
  nesting.
- Classic's `write-article` checks the account's write permission and that
  the title and text are strings, and signals an error otherwise.

Two pieces of the old grammar already do part of what a form needs.
`platform/browser/pla.browser.maple/maple.lisp:form-input@7a82b07` builds the
data of the nearest enclosing `<form>` and posts it through `fetch-contact`,
and an old-grammar series with the `uir-form` role renders as a `<form>`
(`modulate/modulate.lisp:uic-series@7a82b07`). The CMS uses neither.

**Correction (step 0):** `form-input` does not reach the browser.  Both
`form-input` and `field-in` are registered under the same key
(`:form-input-def`) in `enter-js-element`, and the second registration
overwrites the first.  The built client (`int.js`) contains `fieldIn` and
no `formInput`.  Step 3 must write the form gathering fresh rather than
extending `form-input`, and the duplicate key should be fixed.


## Goals

- **Create works**, through a new-grammar form, before anything else moves.
- **No inline JavaScript in the CMS's views.** Controls and forms are
  described in IS/AS/BY and rendered by `modulate2`.
- **One form description renders and validates.** The fields a form declares
  are the fields the branch accepts and checks.
- **`modulate2` has a test suite**, growing with each step.
- **The CMS works at every step,** as the Survey requires — restored at step
  4, when Create works again. Until then, steps 0–3 must not break the list or
  the edit view. Each step is checked by a short manual checklist and by the
  tests.
- **The documents catch up with the code:** this plan describes `modulate2`
  as it is; a Log records each step as it lands.


## Settled Decisions

### SEED-DRAFT-classiccms-D1 — The create form is the first view to move

**Status:** Accepted
**Context:** The Survey orders the views list, edit, metadata (A1–A3). But
Create is broken, small, and needs exactly the two missing pieces —
working controls and form submission — that every later view also needs.
**Decision:** Replace the create view first, directly in the new grammar,
without repairing the old one. Then the list, then the edit view, then the
metadata panel.
**Alternatives:** Repair the old-grammar Create first, keeping the Survey's
order — rejected, as effort spent on code that the next step deletes.
Migrate the list first — it needs controls but not forms, so it would leave
Create broken longer.

### SEED-DRAFT-classiccms-D2 — How a form is submitted

**Status:** Accepted
**Context:** The old views assemble payloads by hand in inline scripts, and
an old-grammar field posts each change on its own.
**Decision:** A `:provision-form` node renders its members inside a
`<form>`. A submit is an `:activating` control among its members. On
submit, the client gathers every named field in the form — inputs and
selects through the form's data, and each `:provision-text` editor's
content from its CodeMirror instance, under the editor's field name — and
posts one flat payload, the action plus one key per field, to the branch.
Fields inside a form post nothing until the form is submitted. A
successful submit is followed by a refresh.
The gathering is a new function (since `form-input` does not reach the
browser — see the correction under "Starting point: the CMS"), adding
the editors' content and the action.
**Alternatives:** Nesting the fields under a `fields` key — workable, since
`adapt-from-json` normalises nested keys against the same declared list, but
rejected as the more complex shape: a flat payload matches the way the
branch already receives its input, as one plist of declared keys.
Per-field posting as the old `uicc-field` does — rejected for forms, where a
partial article is not a meaningful state.

### SEED-DRAFT-classiccms-D3 — One client dispatcher for controls

**Status:** Accepted
**Context:** `:activating` controls render with `data-action` and
`data-target` but nothing handles them.
**Decision:** Add one function to the shared client code in `maple.lisp`,
called from each control's generated click handler with the control's
element and the `mode` in scope, as the old grammar's generated handlers
already pass it. The function reads the control's action and its arguments
from data attributes, submits the enclosing form when the control is inside
one (SEED-DRAFT-classiccms-D2), otherwise posts the action and arguments
through `fetch-contact`, and then refreshes. Controls carry arguments — an
article's index, for example — as a `data-args` attribute alongside the
target path. `make-control` is already exported; it gains an `:args`
keyword so controls can carry arguments.
**Alternatives:** A single listener on the document for every
`[data-action]` click — cleaner markup, but it must recover the Alpine scope
for each element; kept open as SEED-DRAFT-classiccms-O5.

### SEED-DRAFT-classiccms-D4 — The form's description validates its submission

**Status:** Accepted
**Context:** The tree a form was rendered from does not exist when its
submission arrives in a later request. Checks written separately in the
branch would repeat what the form already states (Exact's Implied Checks,
cited).
**Decision:** A form is produced by a function of its inputs — for the CMS,
one that returns the article form. The branch calls the same function when
a submission arrives, and checks the submitted fields against the IS each
field declares. On failure, the branch keeps the submitted values and the
errors in session state, and the refresh re-renders the form with both. A
condition from Classic, such as a permission error, is reported the same
way, as an error on the form. The principle is settled here; how
constraints such as "required" are written (SEED-DRAFT-classiccms-O1) and
how errors are represented (SEED-DRAFT-classiccms-O2) are open.
**Alternatives:** Validation only on the client — rejected; the branch must
check what it writes. Separate validation code in the branch — rejected, as
a second description that can drift from the form.

### SEED-DRAFT-classiccms-D5 — Actions are keywords from a closed set

**Status:** Accepted
**Context:** The handler compares action strings in a `cond`. A mistyped or
unknown action matches no clause and falls through to the default case,
which renders the current view: the client sees no error, and the request
silently does nothing. Turning the client's strings into keywords by
interning them would let any client add symbols to the image.
**Decision:** The branch maps an incoming action string to a keyword only if
it is one of the actions it declares (`:new`, `:create`, `:edit`, `:save`,
`:back` to begin with), and sends each to one function per action. Unknown
actions are rejected with an error rather than interned or ignored. The
`cond` stays until the branch-object migration (Survey increment E,
SEED-0009), which replaces it.
**Alternatives:**
- A dispatch table keyed by the action strings themselves — closed in the
  same way, but it keeps the branch's vocabulary in strings, unlike the
  rest of Seed's keyword-named interfaces.
- A generic function dispatching on `eql` keyword specializers, one method
  per action — close to the operations of the branch-object model, and so
  better deferred to increment E than introduced in a `cond`-based branch.
- Interning whatever the client sends — rejected for the reason above.

### SEED-DRAFT-classiccms-D6 — Create and edit are one form

**Status:** Accepted
**Context:** The Survey describes the edit view as "like the create form,
but pre-populated". The old edit view saves its body through the text
protocol and cannot change the title.
**Decision:** One article form serves both views: empty with a "create"
action, or filled from an article with a "save" action carrying the
article's index according to edit-article's 1-based count. The body is
`:provision-text` (CodeMirror) in both, loading its text through the text
protocol — which already returns an empty string when no article is being
edited — and submitting with the form. The text protocol's save path is
retired once the edit view moves.

The editor's mode follows the body's format, stated as an AS role on the
body field: `(:as :markdown)` for the demo blog, whose articles declare
`:format :markdown` in Classic, as the Survey's first editing view
proposes. Until the Classic→fx bridge (step 7) derives the role from the
slot's `:format`, the form function writes it directly. The
`:provision-text` generate method reads the role and passes the matching
language to the client's editor constructor; a body with no format role
gets the constructor's default. Lisp mode for Lexis bodies (`(:as :lexis)`)
follows when Classic gains a `:lexis` format.
**Alternatives:** A plain multi-line field for Create — simpler, but the two
views would diverge and the editor would have to be added again later.


## Design

### The round trip of a form

1. The branch's form function returns a `:provision-form` node whose members
   are its fields and controls.
2. `generate` renders a `<form>` containing the fields. `:entering` fields
   are named inputs; a `:provision-text` field is a CodeMirror element that
   also carries its field name; each control is a button whose click handler
   calls the dispatcher.
3. On submit, the dispatcher gathers the fields
   (SEED-DRAFT-classiccms-D2) and posts `{action, field…}` through
   `fetch-contact`.
4. The branch maps the action (SEED-DRAFT-classiccms-D5), rebuilds the
   form, checks the fields (SEED-DRAFT-classiccms-D4), and either calls
   Classic or stores the values and errors.
5. The refresh re-renders the view: the list after a successful create, or
   the form again with its values and errors.

### A sketch of the article form

Illustrative, not a specification. `control` stands for the exported control
constructor of SEED-DRAFT-classiccms-D3.

```lisp
(defun cms-article-form (&key article index errors)
  (dx (:as :article-form :by :provision-form :name :article)
      (dx (:is :- :required :by :entering :name :title)
          (if article (headline article) ""))
      (dx (:as :markdown :by :provision-text :name :body) (list *system* :cms))
      (if article
          (control :save "Save" :args (list :index index))
          (control :create "Create"))
      (control :back "Back")
      (when errors (dx (:as :errors) errors))))
```

### What modulate2 must gain

- Controls with arguments (`make-control` gains `:args`).
- `:provision-form` rendering its members inside the form.
- A field name on `:provision-text` elements, so the form can gather them.
- Editor mode chosen from the field's AS format role
  (SEED-DRAFT-classiccms-D6): a language argument to the client's
  `create-codemirror`, which today always uses Lisp mode, and CodeMirror's
  Markdown language declared as a direct dependency and imported into the
  client build.
- The dispatcher, in `maple.lisp`.
- `construct` resolving IS through `resolve-is`.
- A representation of field errors for rendering (SEED-DRAFT-classiccms-O2).
- Tests for each.

### Tests

A `seed.modulate2.test` system beside `test/seed.generate.test.asd`, written
to the Square standard (FiveAM and cl-hamcrest, wired to ASDF's `test-op`).
The tests check manifestation trees and the generated HTML trees, not
rendered strings, so that they survive changes of markup. The client
dispatcher is checked by the manual checklist until there is a way to test
client code.


## Scope and Non-Goals

- **In scope:** steps 0–7 below — the CMS's create, list, edit and metadata
  views in the new grammar, and the `modulate2` pieces they need.
- **Not in scope here:** workflow controls, the preview, the wiki, and the
  branch-object migration (the Survey's increments B–E), which are outlined
  in the Roadmap and will be planned in detail when they come; Vox; the
  retirement of the old aspect system; ProseMirror editing.
- **One foundational subsystem at a time.** The steps change the rendering
  grammar only. The branch model stays a `cond` until increment E.
- **Dependent work.** Steps 2–3 — working controls and submittable forms —
  are prerequisites for two other documents' steps: the derived properties
  panel of the chart-editing Survey (SEED-0012, step C7) and the layer-list
  editor of the drawing-tool Survey (SEED-0014, step P5). Both cite these
  steps by number, so a renumbering here should be reflected there.


## Tensions and Risks

**Index-keyed articles.** The CMS addresses articles by their position in
`get-articles`, and Classic's `edit-article` takes an index. An index in a
control rendered earlier can name a different article after a create. This
is tolerable for a single-user demonstration; see
SEED-DRAFT-classiccms-O6.

**Two different indices.** The list is built from `get-articles` with its
default arguments and counts from 0. Classic's `edit-article` counts from 1,
over `get-articles` with `:include-deleted t`; the old code converts with
`(1+ edit-idx)`. The two agree only while no article has been deleted. Once
deletion arrives (increment B), a position in the list and an index for
`edit-article` can name different articles. SEED-DRAFT-classiccms-D6
settles that the save action carries `edit-article`'s 1-based index, so the
list's edit controls must produce that index — not their 0-based position
among current articles — once deleted articles exist.

**The CodeMirror token.** `:provision-text` names its editor after the
system and branch, so one branch can hold only one server-fetched editor at
a time. The CMS shows one at a time; a form with two text fields could not
(SEED-DRAFT-classiccms-O4).

**Client code is untested.** The dispatcher and form gathering are checked
by hand until there is a client test harness.


## Open Questions

### SEED-DRAFT-classiccms-O1 — How are constraints written?

The sketch writes a required title as `(:is :- :required)`, an IS stratum-2
specializer. Is "required" a property of the data's character, or a
constraint that belongs elsewhere — a BY property of entry, or a separate
`:constraints` sub-form? The same question will arise for lengths, formats
and ranges.

### SEED-DRAFT-classiccms-O2 — How are errors represented?

Are field errors manifestations with an AS role such as `:error`, attached
to the field they concern, or annotations on the field itself that the
medium renders? Where are form-level errors, such as a permission error,
shown?

### SEED-DRAFT-classiccms-O3 — Effect classes on controls now?

SEED-0009 gives each operation an effect class (`:safe`, `:idempotent`,
`:effecting`). Should controls carry it from the start — so that, for
example, an effecting control can be disabled while its request is in
flight — or only from increment E?

### SEED-DRAFT-classiccms-O4 — Naming editors

Should a `:provision-text` editor's token include its field name, so that a
form can hold more than one, and two forms can share a page?

### SEED-DRAFT-classiccms-O5 — Generated handlers or one listener?

SEED-DRAFT-classiccms-D3 calls the dispatcher from a click handler
generated on each control. A single listener on the document would remove
the handlers from the markup, but must find each element's Alpine scope. Is
that worth doing, and when?

### SEED-DRAFT-classiccms-O6 — Addressing articles

Should controls address articles by URI — which `write-article` returns —
rather than by index, with a Classic function to edit by URI? This would
fit Classic's model better and remove the risk of a stale index. It would
also remove the mismatch between the list's 0-based positions over current
articles and `edit-article`'s 1-based index over all articles, deleted ones
included, which matters from increment B, when articles can be deleted.

### SEED-DRAFT-classiccms-O7 — Context without the old panes

The dispatcher relies on the `mode` that the old grammar's frames and panes
place in scope to address the branch. When the old aspect system is
retired, what provides that context — a manifestation-level attribute
naming the system and branch, or something the branch-object model supplies?


## Prior Art

Except for Seaside, which the Smalltalk Eval (SEED-0008) examines, the
systems below are named from general knowledge; their details were not
re-checked for this plan.

Table: Prior systems and what this plan draws from each.

| System | What to draw from |
|---|---|
| HTML forms and `FormData` | Gathering named fields from a form, used directly by the dispatcher |
| Phoenix LiveView forms and Ecto changesets | Validation against a declared schema on the server, with errors and submitted values re-rendered in the form |
| Rails strong parameters | Accepting only declared parameters (SEED-DRAFT-classiccms-D5, and the flat payload of SEED-DRAFT-classiccms-D2) |
| Seaside (evaluated in SEED-0008) | Forms whose controls are bound to server-side actions, with no hand-written client code |
| The old grammar's `uir-call` roles | Generated click handlers that pass the scope's `mode` to `fetch-contact` |


## Roadmap

From step 4 on, each step ends with the CMS's list, create, edit and save
flow working and the checklist passed; steps 0–3 leave the list and the edit
view working while Create is rebuilt. Each step is recorded in a Log as it
lands.

1. **Step 0 — Diagnose Create.** Reproduce the failure with the browser's
   console and network panel and the server log, and record the cause. The
   old view will be replaced, but the cause may lie in shared code
   (`fetch-contact`, the refresh, Classic's checks) that the new form also
   uses.
2. **Step 1 — A test suite for modulate2.** Tests for what exists:
   expression of atoms and sequences, IS resolution including `:-`, `dx`
   construction, valence and layout, `:reducing` controls, `:provision-text`
   output, and the bridges. Fix `construct` to resolve IS.
3. **Step 2 — Controls that work.** The exported control constructor,
   controls with arguments, and the dispatcher (SEED-DRAFT-classiccms-D3);
   tests for the generated buttons.
4. **Step 3 — Forms.** `:provision-form` rendering its members; field names
   on `:provision-text`; form gathering as a new client function in the
   dispatcher (SEED-DRAFT-classiccms-D2); tests, including a
   `:provision-text` field whose value is a list (expressed as a sequence)
   and a form with a `nil` member.
5. **Step 4 — The create view.** The article form
   (SEED-DRAFT-classiccms-D6) in create mode, its body editor in Markdown
   mode selected through `(:as :markdown)`, with `@codemirror/lang-markdown`
   declared explicitly in the `package.json` of the npm interface the client
   build imports it from; the `:create` action with
   validation (SEED-DRAFT-classiccms-D4) and closed actions
   (SEED-DRAFT-classiccms-D5); `render-cms-create` and its inline script
   deleted. Create works.
6. **Step 5 — The article list** (Survey A1). Headline, state and date as
   `:observing` atoms, with an edit control per article carrying its index;
   `render-cms-list` deleted.
7. **Step 6 — The edit view** (Survey A2). The article form in save mode,
   loading its body through the text protocol; the `:save` action calling
   `edit-article` with title and text; `render-cms-edit`, its inline script
   and the text protocol's save path deleted.
8. **Step 7 — The metadata panel** (Survey A3). Fields generated from
   Classic's slot metadata (CLASSIC-0007) through the Classic→fx bridge; the
   `:extending` and `:reducing` defaults finished for the category list.
   This step will be detailed in a revision of this plan, once steps 4–6
   have shown the form in use.
9. **Later — Survey increments B–E,** in outline: workflow controls filtered
   by permission (B); the rendered preview (C); the wiki views (D); the
   branch-object migration, with operations, effect classes and Classic
   writes as queued effects (E, SEED-0009). Each is planned when it comes.
