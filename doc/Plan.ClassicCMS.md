---
id:            SEED-0015
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
  - SEED-0016
cites:
  - title:     "Exact: Essential eXpression Articulating Coherent Topology"
    locator:   "~/src/chat/Exact.md"
    external:  true
decisions:
  - SEED-D25
  - SEED-D26
  - SEED-D27
  - SEED-D28
  - SEED-D29
  - SEED-D30
  - SEED-D31
  - SEED-D32
  - SEED-D33
  - SEED-D34
  - SEED-D35
  - SEED-D36
  - SEED-D37
  - SEED-D38
  - SEED-D39
  - SEED-D40
  - SEED-D41
  - SEED-DRAFT-classiccms-D18
open-questions:
  - SEED-O46
  - SEED-O47
  - SEED-O48
  - SEED-O49
  - SEED-O50
  - SEED-O51
  - SEED-O52
  - SEED-O53
  - SEED-O54
  - SEED-DRAFT-classiccms-O10
---

# The Classic CMS in the New Grammar: Development Plan

This plan turns the Classic interface Survey (SEED-0011) into
work. It moves the CMS in `systems/demo.access` from the old interface grammar
to the IS/AS/BY grammar of `modulate2` (SEED-0003, SEED-0004) one view at a
time, building in `modulate2` the pieces each view needs: tests first, then
client dispatch for `:activating` controls, then submittable forms. Its first
deliverable was a working Create, which was broken when the plan was written.
The plan details steps
0–8, which cover the Survey's increments A1–A3 and keyboard navigation, and
keeps the later increments (B–E) in outline. It is expected to change as the
work shows what is needed.

The revision of 2026-11-18, made after steps 0 and 1 had landed, settles the
client protocol that steps 2 and 3 build on: how markup declares context,
widget state, refreshes and form collections, with the browser as a generic
interpreter of that markup and the interface model kept on the server
(SEED-D31 to SEED-D36). It revises
SEED-D26 and SEED-D27 to match, and adds
step 8, keyboard navigation and sorting (SEED-D37 to
SEED-D41).

The revision of 2026-11-19 makes the control banks the standard place for a
view's controls that are not tied to a part of it
(SEED-DRAFT-classiccms-D18), and adds their preparation to step 2. Its
records are Proposed.

Code references are pinned to revision `7a82b07`, except those added by the
revision of 2026-11-18, which are pinned to `f55f092`, and those added by
the revision of 2026-11-19, which are pinned to `0478c2e`.


## Problem

The CMS is the main development target for the new grammar, but the two
documents behind it describe concepts, not the code that exists. The
Survey sets the direction and the increments; SEED-0003 and SEED-0004 record
the ontology and the first implementation. Neither says what `modulate2` can
and cannot yet do, and the first increment the Survey proposes depends on
infrastructure that does not exist.

Meanwhile the CMS's Create button did not work when the plan was written, so
the rule the Survey sets — a working CMS at every step — was already broken.
Step 0 found and fixed the fault (see the corrections under "Starting point:
the CMS").

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

**Correction (step 0, diagnosed):** Create failed because Alpine 3 rejected
its handler: an `x-on:` attribute is read as an expression unless it begins
with `let`, `const` or `if`, and the script began with `var`. Changing the
first `var` to `let` fixed Create in the old grammar
(`systems/demo.access/seed.lisp:render-cms-create@bdf7f99`); the edit view's
Save script had the same fault and was fixed at `f55f092`. The candidates
listed above were not the cause. The Log (SEED-0016) records
the diagnosis.

### Starting point: the client protocol

The old grammar places three objects in each component's Alpine scope
(`modulate/modulate.lisp:generate@f55f092`, the `:around` method on
`(uim-web ui-component)`):

- **`mode`** holds two kinds of state at once: the *address* — the system and
  branch a request goes to — and *widget state*, such as a chart's
  interaction state or a toggle's index. An inner `x-data` that defines
  `mode` hides the outer one, so every widget that needs state must restate
  the address too.
- **`methods`** holds client functions, generated as JavaScript text into
  each `x-data` attribute and rebuilt on every render.
- **`patch`** is a registry in which frames record themselves by name, so
  that a method can trigger a refresh of a named region. The client guesses
  which regions a change affects.

Generated handlers are also JavaScript text in attributes — the fault that
broke Create at step 0.

The old grammar's `:meta-path` attribute, a positional path set by `express`,
has one reader in the client: the drag-and-drop sort handler
(`platform/browser/pla.browser.maple/maple.lisp:mcode-drop-target@f55f092`),
which posts the path and two item positions
read from `index` attributes. Mousetrap is loaded but nothing binds keys with
it; keyboard navigation does not exist yet.


## Goals

- **Create works**, through a new-grammar form, before anything else moves.
- **No JavaScript in generated markup.** Controls, forms and widgets are
  described in IS/AS/BY and rendered by `modulate2` as declarative attributes;
  all client behaviour is written once, in `maple.lisp`.
- **The interface model lives on the server.** Context, focus, field drafts,
  form membership and navigation are decided by Seed and rendered as markup
  that the browser interprets generically, so that a terminal medium can
  share the same model rather than duplicate it in the browser.
- **One form description renders and validates.** The fields a form declares
  are the fields the branch accepts and checks.
- **`modulate2` has a test suite**, growing with each step.
- **The CMS works at every step,** as the Survey requires. Create was
  restored in the old grammar at step 0, so no step may break the list,
  create or edit flows. Each step is checked by a short manual checklist and
  by the tests.
- **The documents catch up with the code:** this plan describes `modulate2`
  as it is; a Log records each step as it lands.


## Settled Decisions

### SEED-D25 — The create form is the first view to move

**Status:** Accepted
**Context:** The Survey orders the views list, edit, metadata (A1–A3). But
Create is broken, small, and needs exactly the two missing pieces —
working controls and form submission — that every later view also needs.
(Step 0 found the fault to be one word in the old view's script and fixed
it there, so Create no longer waits for step 4. The decision stands on its
second reason: Create exercises both missing pieces.)
**Decision:** Replace the create view first, directly in the new grammar,
without repairing the old one. Then the list, then the edit view, then the
metadata panel.
**Alternatives:** Repair the old-grammar Create first, keeping the Survey's
order — rejected, as effort spent on code that the next step deletes.
Migrate the list first — it needs controls but not forms, so it would leave
Create broken longer.

### SEED-D26 — How a form is submitted

**Status:** Accepted
**Context:** (Revised 2026-11-18. The decision was Accepted in its earlier
form, which is kept among the alternatives.) The old views assemble payloads by hand in inline scripts, and
an old-grammar field posts each change on its own. HTML forms cannot nest:
an inner form cannot submit only its own fields while the outer form
submits both. Requests now carry more than an action and fields — control
arguments, focus, reported widget state and field drafts
(SEED-D32, SEED-D34) — so a flat payload's
top-level keys would collide with field names such as `action` or `focus`.
**Decision:** A form is a collection (SEED-D35), rendered
as an element with the ARIA role `form` and an accessible name, not as an
HTML `<form>`. A `:submitting` control gathers the named fields of the
collection it submits — native inputs and selects by their value, and
widgets such as the `:provision-text` editor through their component's
value accessor (SEED-D32) — and posts one envelope to the
branch:

```json
{"action": "update-meta", "args": {}, "target": null, "collection": "meta",
 "fields": {"status": "draft", "category": "news"},
 "drafts": {"title": "A new title"}, "focus": "status", "state": {}}
```

`target` holds the navigation key of the node a control acts on, from its
`data-target` attribute (SEED-D40), or `null`. `fields` holds every field
of the submitted collection; `drafts` holds changed fields outside it whose
drafts have not yet been sent (SEED-D34). Every request has
the same envelope, with `collection` and `fields` empty when no collection
is submitted. The branch validates only `fields`, against the collection
the form function declares (SEED-D28), and rejects any
field it does not declare. A successful submit is followed by the refreshes
the response names (SEED-D33).
The gathering is a new function (since `form-input` does not reach the
browser — see the correction under "Starting point: the CMS").
**Alternatives:**
- A flat payload, the action plus one key per field — this decision's
  earlier form, rejected now that reserved keys would collide with field
  names. `adapt-from-json` normalises nested keys against the declared
  list, so the envelope costs the branch nothing.
- Rendering forms as HTML `<form>` elements — rejected: they cannot nest,
  and an input can belong to only one form. Enter is handled as the primary
  trigger (SEED-D39), so `<form>` would add only browser
  autofill, which the CMS does not need.
- Per-field posting as the old `uicc-field` does — rejected for forms,
  where a partial article is not a meaningful state; drafts are reported
  but never committed until submitted.

### SEED-D27 — One client dispatcher for controls

**Status:** Accepted
**Context:** (Revised 2026-11-18. The decision was Accepted in its earlier
form, which is kept among the alternatives.) `:activating` controls render with `data-action` and
`data-target` but nothing handles them. Step 0 showed how fragile handler
code in attributes is: Create failed because Alpine rejected the first
token of a generated script.
**Decision:** One delegated listener on the document, defined once in
`maple.lisp`, handles the activation of every element with a `data-action`
attribute. Generated markup carries no handler code; where an `x-on:`
attribute must still be generated, it contains exactly one function call.
On activation the listener:

1. reads the action, the arguments from a `data-args` attribute holding
   JSON, and the target from a `data-target` attribute, when there is one;
2. finds the system and branch from the nearest enclosing context
   attributes (SEED-D31);
3. if the control is `:submitting`, gathers the collection it submits
   (SEED-D26, SEED-D35); a plain
   `:activating` control gathers nothing;
4. posts the envelope of SEED-D26 through `fetch-contact`,
   with any drafts not yet sent, the focus and reported widget state
   (SEED-D34);
5. triggers the refreshes the response names (SEED-D33).

`make-control` is already exported; it gains an `:args` keyword, and
`modulate2` renders the arguments as `data-args`.
**Alternatives:**
- A function called from a click handler generated on each control, passed
  the `mode` in Alpine scope — this decision's earlier form, rejected: it
  depends on the old grammar's scope and keeps code in markup.
- Submitting the enclosing form whenever a control is inside one — the
  earlier form, rejected: a Back control inside a form would submit it.
  Only `:submitting` nodes submit (SEED-D35).
- Inline scripts per view, as the old CMS views have — rejected for the
  fragility step 0 exposed.

### SEED-D28 — The form's description validates its submission

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
constraints such as "required" are written (SEED-O46) and
how errors are represented (SEED-O47) are open.
**Alternatives:** Validation only on the client — rejected; the branch must
check what it writes. Separate validation code in the branch — rejected, as
a second description that can drift from the form.

### SEED-D29 — Actions are keywords from a closed set

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

### SEED-D30 — Create and edit are one form

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

### SEED-D31 — Context is declared in data attributes

**Status:** Accepted
**Context:** The old grammar's `mode` mixes the address a request goes to
with widget state, and inner scopes that define `mode` must restate the
address (see "Starting point: the client protocol"). The address is fixed
for everything beneath a branch's root and nothing should change it.
**Decision:** The root element of each `modulate2` branch view carries the
address as attributes, `data-seed-system` and `data-seed-branch`. Client
code finds it with `closest('[data-seed-branch]')`; widgets never write it.
Because no Alpine scope is needed to find the address, one delegated
listener can handle every control (SEED-D27). During the
migration, `modulate2` must know the system and branch when it renders a
root; whether they come from a dynamic binding made while the branch
renders or from the medium is to be settled at step 2.
**Alternatives:**
- One inherited, read-only context object in Alpine scope, placed at the
  branch's root — workable, but every control would still depend on Alpine
  scope, and a delegated listener would have to recover it.
- Keeping `mode` as the old grammar builds it — rejected for the reasons in
  the context.

### SEED-D32 — Widgets are registered components with data parameters

**Status:** Accepted
**Context:** The old grammar generates each widget's functions as
JavaScript text into its `x-data` attribute on every render, and keeps the
widget's state in `mode` beside the address.
**Decision:** Each kind of widget has its behaviour written once, in
Parenscript in `maple.lisp`, and registered as an Alpine component with
`Alpine.data` at `alpine:init`. The markup names the component and carries
its parameters as JSON produced by the server's encoder, for example
`x-data="seedChart"` with `data-seed-params='{"xAxisLabel":"time"}'`. Each
component keeps its state under one top-level key named for its kind
(`chart`, `editor`, `toggle`), so nested widgets cannot hide each other's
state. A widget that holds a field's value, such as the `:provision-text`
editor, exposes a value accessor that form gathering calls
(SEED-D26).

State in the browser is limited to what changes between requests without
the server knowing — a drag in progress, a chart's zoom, an editor's text
before submission. Anything meaningful to the program is held by the
server and arrives as parameters. A widget declares which of its state
keys are *reported*; the client adds them to every request, as it does the
focus (SEED-D34). Other state is discarded on refresh.
**Alternatives:**
- Functions generated into each `x-data` attribute — the old `methods`,
  rejected: rebuilt on every render, and copied into markup per instance.
- An `x-data` attribute holding a JavaScript object literal of parameters —
  rejected as generated JavaScript text.

### SEED-D33 — The server names what to refresh

**Status:** Accepted
**Context:** The old grammar's `patch` registry lets client code trigger a
refresh of named regions, so the client guesses which regions a change
affects. The server knows what changed.
**Decision:** A region that can be refreshed is marked with
`data-seed-region` and its name, and listens for a namespaced `seed:refresh`
event. The root of every branch view is a region, so every control has an
enclosing region. A branch's response carries `refresh`, a list of region
names; the dispatcher triggers those regions. A response that names none
refreshes the nearest region containing the control that made the request,
which keeps the behaviour of today's `{next: 'refresh'}`. A request that
only sends drafts (SEED-D34) refreshes nothing.
**Alternatives:**
- The `patch` registry — rejected for the reason in the context.
- Returning the re-rendered HTML in the contact response, saving the second
  request — deferred; it changes the response format, and can follow
  without changing how regions are named.

### SEED-D34 — Focus and field drafts are reported state, owned by the server

**Status:** Accepted
**Context:** A refresh replaces DOM nodes, losing the focus and any unsaved
edits. A partial submit — a nested collection's control — re-renders the
view and would discard unsaved edits elsewhere in the form; refreshing
only the submitted region is not enough when a change affects more than
one region. A terminal medium holds focus and field values on the server
in any case.
**Decision:** Every request carries the navigation key of the focused
element. A *draft* is the value of a field the view declares, when it
differs from the value the field was rendered with. The client sends a
field's draft when the field changes — on its change event, or after a
pause in typing for a text widget — as a request that names no action and
refreshes nothing (SEED-D33); a request made before a pending draft has
been sent carries it in `drafts` (SEED-D26).

The server keeps, per branch view in the session, the focus, the
last-visited memory of navigation (SEED-D38) and the
drafts, and renders from them; the client focuses the element the server
marks. Only the submitted collection is validated and written. This also
provides SEED-D28's "keeps the submitted values". Drafts are governed by
four rules:

- **Keyed by record.** Each draft is stored under its field, its
  collection and the record the collection edits — for the CMS, the
  article's index, later its URI (SEED-O51). The branch learns which record
  each collection edits by rebuilding the view's forms, as it does to
  validate them (SEED-D28). A draft for one article never appears in the
  form for another, and the create form has its own record.
- **Declared fields only.** The server stores drafts only for fields the
  view declares and rejects others, as it rejects undeclared submitted
  fields (SEED-D26).
- **Lifetime.** A successful submit clears the drafts of the submitted
  collection, for its record. An action may also discard the drafts of the
  view it leaves; for the CMS, `:back` does.
- **Widgets that load their own value.** A widget that fetches its value by
  a separate request, as the `:provision-text` editor does through the
  branch's text protocol, receives the draft when there is one, so a
  refresh after a partial submit does not replace an unsaved body with the
  stored one. For the CMS, the text protocol's load returns the body's
  draft when it has one.
**Alternatives:**
- Each group remembering its last focused child in the browser — rejected:
  the model would live in the browser, and a terminal medium would need a
  second copy.
- Protecting unsaved edits only by refreshing the submitted region —
  rejected as insufficient, above.
- Keeping the last rendered manifestation tree of each branch view in the
  session, so that markup carries only node identifiers and every action
  names a node (Seaside's approach, evaluated in SEED-0008) — deferred to
  increment E, where a branch object holding its view is the natural home
  for it. SEED-D28's rebuilding of the form suffices until
  then, and a kept tree needs a generation identifier per render, because
  two tabs showing one branch would overwrite each other's tree.

### SEED-D35 — Forms are collections of named fields

**Status:** Accepted
**Context:** A CMS article form has a title, a body editor and property
fields such as status and category, which WordPress-like editors place in
separate panels, each with its own update control, while the main save
submits everything. The layout tree and the grouping of fields for
submission often differ: a property panel sits in a sidebar column, a Save
control in a toolbar.
**Decision:** A collection is a manifestation with the modality
`(:by :collecting)` and a `:name`, which identifies it. `:collecting`
replaces `:provision-form`.

- **Membership comes from nesting:** a named field belongs to every
  collection that encloses it.
- **`(:as (:member …))` adds memberships**, naming collections the item
  also belongs to wherever it sits, for example
  `(:as (:member :article :meta))`. It adds to the memberships nesting
  gives; it does not replace them (SEED-O53).
- **A collection can be a member of a collection.** A nested collection is
  a member of the collections enclosing it, and `(:as (:member …))` on a
  `:collecting` node includes all its members in the named collections.
  Collections including collections needs no other mechanism.
- **A control submits with `(:by :submitting)`**, which submits its nearest
  enclosing collection, or `(:by (:submitting :article))`, which submits
  the named collection wherever the control sits. `:submitting` implies
  `:activating`. Only `:submitting` nodes gather fields
  (SEED-D27).
- **A field outside every collection submits its single datum.** It acts
  as a collection of one, named by its field name: a control submits it by
  name, as `(:by (:submitting :key))`, and the field submits itself when it
  is activated, if it carries `:submitting` of its own — as when Enter is
  pressed in a named text field (SEED-D39). A field that submits itself
  names its action as a control does. A field inside a collection
  that carries `:submitting` of its own submits its nearest enclosing
  collection, as a control does.

The server resolves membership when it renders: one function walks the
tree, applies nesting, `:member` and inclusion, and renders each field with
`data-seed-field` (its name) and `data-seed-in` (every collection it
belongs to), and each submitting node with `data-seed-submits`. The
client gathers a collection with `[data-seed-in~="meta"]` within the branch
root. Collection names and field names must be unique within a branch
view, and no field outside a collection may share a collection's name,
because gathering, submission by name and drafts (SEED-D34) all match by
name; the server checks this while resolving membership and signals an
error rather than render an ambiguous form. `parse-as-spec` and `parse-by-spec`
(`modulate2/modulate2.lisp:parse-as-spec@f55f092`,
`modulate2/modulate2.lisp:parse-by-spec@f55f092`) each gain a branch for
the new sub-form, and manifestations gain slots for membership and the
collection a control submits.
**Alternatives:**
- Membership by nesting only — rejected: it forces the collection tree to
  follow the layout tree.
- Membership by explicit identifier only, as HTML's `form` attribute gives
  an input — rejected as not seamless, since the common case would need an
  annotation on every field; HTML also allows one form per input.
- A plain `:activating` control inside a collection submitting it —
  rejected (SEED-D27).
- Membership and submission as identity slots beside `:name`, outside
  IS/AS/BY — rejected (SEED-D36).

### SEED-D36 — AS roles may be relational

**Status:** Accepted
**Context:** SEED-D19 places a datum's role in the program — what it is for
— under AS, with formats such as `:markdown` and `:sql` as examples. Those
roles describe the node alone. Membership in a collection describes a
node's role in relation to others: these values are changed in concert and
entered as a group. AS already holds a structured sub-form that is not a
one-word role: `(:layout …)`, which arranges a node's members.
**Decision:** An AS role may name other nodes. `(:member …)` is the first
such role: a program-semantic, medium-independent statement that the item
is changed in concert with the other members of the named collections. Like
`(:layout …)`, it is written as a structured sub-form,
`(:as (:member :article :meta))`, because `parse-as-spec` reads flat
keywords as roles and lists beginning with a keyword as sub-forms. The
modality of acting on a collection — `:collecting`, `:submitting` — is BY.
This refines SEED-D19.
**Alternatives:**
- Identity slots beside `:name`, outside the three axes — rejected:
  membership is a role in the program, and the ontology should describe it.
- Writing `(:as :member (:article :meta))` — rejected: the parser would read
  `:member` as a flat role and drop the list.

### SEED-D37 — Navigation is movement through spaces, chosen by mode

**Status:** Accepted
**Context:** Seed's interaction model treats input as movement of a point
through a space: the same directional keys always move the point, and the
active mode decides which space it moves through — the visible branches,
a branch's interface, the text in an editor, history, the clipboard. The
same model must serve the browser, a terminal and other input devices.
**Decision:** Navigation has an abstract vocabulary of four directions and
four triggers — primary (Enter), secondary (Space), cross (Tab) and anti
(Escape). Each medium translates its raw input into that vocabulary:
Mousetrap in the browser, and later the terminal and other devices. Key
bindings are declared once in Lisp, with arrows by default and `hjkl` as a
configurable alternative; `maple` renders the declaration as Mousetrap
bindings. The server owns the mode and the point. The first space, built at
step 8, is the form's tree within a branch view
(SEED-D38). Moves within it run in the browser from the
rendered projection, so that a key press needs no request. Other modes —
top-level movement between branches and the sidebar, history, the
clipboard — are outside this plan; each move in them changes server state,
so each is naturally a request.
**Alternatives:**
- The browser's own Tab order alone, with no model of movement — rejected:
  it moves through every focusable element in document order, one
  dimension only, and exists only in the browser.
- A client-side roving-focus library — rejected: the navigation model
  would live in the browser, and a terminal medium would need a second
  copy of it.
- Each mode's keys as unrelated bindings, rather than one vocabulary of
  directions and triggers — rejected: keys would mean different things in
  each mode, and every medium would have to map each mode's bindings
  separately.
- Ad hoc keyboard shortcuts per view — rejected: they would not port
  between media, and would grow without a model.

### SEED-D38 — The first space is the form's tree

**Status:** Accepted
**Context:** Movement can follow the rendered layout, the on-screen
geometry, or the structure of the forms the interface is derived from.
Layout-driven movement changes which key moves to a sibling as groups of
different orientations nest; geometric movement needs the browser's
geometry, so it would be a browser-only algorithm. Movement over the
structure ports to a terminal unchanged and corresponds to the Lisp forms
beneath the interface.
**Decision:** A medium-independent `modulate2` function computes a
*navigation projection* of the manifestation tree, after the Tier-1
defaults have added their controls:

- **Stops:** atoms whose BY is interactive — `:entering`, `:choosing`,
  `:cycling`, `:activating`, `:submitting`, and the widget modalities.
- **Groups:** sequences and containers holding stops.
- **Elided:** `:observing` atoms, decoration and status; the wrappers
  rendering adds (`mfn-item`, `mfn-header`, layout cells); a group with a
  single stop, which collapses into it; an `:observing` sequence of rows
  with no controls. A node may override the elision with an explicit
  navigation annotation, as `:bare` overrides the Tier-1 defaults
  (SEED-D18), for when these rules guess wrong.

Movement is over the projection drawn as a tree, root at the top and
children left to right:

- **Up and down** change depth. Depth is counted in the projection, so
  there are no invisible levels. Down goes to the last-visited child, or
  else the first.
- **Right and left** move to the next or previous branch: the nearest
  ancestor with a child after (or before) the one containing the point;
  into that child, to the same depth relative to that ancestor, or to the
  deepest level of that branch if it is shallower.
- **At the target depth,** the point goes to the last-visited node, or else
  the first in the projection's order — not the leftmost on screen, which
  varies with the rendering.

The server keeps the last-visited memory (SEED-D34). The
web rendering marks the projection with `data-nav` (stop or group) and
`data-nav-key` (SEED-D40), with ARIA roles and a roving
`tabindex`, so that focus stays real DOM focus, followed by screen readers.
The visual order will sometimes differ from the structure — the next
article in a vertical list is *right*, not down. This is accepted as a
learned convention, as in paredit, and the server shows the focused group's
depth and sibling direction in every medium.
**Alternatives:**
- Sibling movement along each group's `:layout` axis, crossing axes by
  moving to the parent — rejected: keys change meaning as layouts nest.
- Geometric movement to the nearest element on screen, as in the W3C's
  spatial-navigation proposal — rejected: browser-only, and arbitrary
  across groups.
- Rotating the axes by layout, as ARIA's tree-view convention does for
  vertical lists — held in reserve, if use shows the mismatch hurts.
- Neighbour links precomputed by the server for each stop — rejected: links
  crossing a refreshed region go stale.

### SEED-D39 — Triggers map to BY modalities, and fields have an edit mode

**Status:** Accepted
**Context:** Mousetrap ignores keys inside inputs, selects and
contenteditable elements, CodeMirror among them, so a field holding DOM
focus would capture navigation keys.
**Decision:** A field at the point is in navigation mode: DOM focus rests
on the field's wrapper, and the directional keys move the point. The
primary trigger enters edit mode, focusing the input or editor itself; the
anti-trigger leaves it. The triggers act by modality:

Table: What each trigger does, by the BY modality at the point.

| Trigger | Key | Action |
|---|---|---|
| Primary | Enter | Fires an `:activating` or `:submitting` control; enters edit mode on an `:entering` or `:choosing` field or a text widget |
| Secondary | Space | Acts on `:cycling` controls; picks an item up for a move (SEED-D41) |
| Cross | Tab | Moves between top-level spaces, such as the branch panes and the sidebar |
| Anti | Escape | Leaves edit mode or the current mode; cancels |

In edit mode, Enter does nothing on a single field unless the field
carries `:submitting` of its own, when it submits as SEED-D35 describes; in
a text widget, Enter is text. These details are to be discussed further at
step 8.

Using Tab as the cross trigger replaces the browser's default Tab order, so
step 8 must confirm that keyboard and screen-reader users can still leave
the page.
**Alternatives:** A custom Mousetrap `stopCallback` or the `bindGlobal`
plugin so that navigation keys work inside focused fields — rejected as the
primary means: it fights the fields for their keys, where edit mode
separates them.

### SEED-D40 — Data addresses are separate from navigation keys

**Status:** Accepted
**Context:** The old grammar's `:meta-path` serves as a data address for
write-back, set only by `express`, and positional paths go stale after an
insert or a sort (SEED-O55). Navigation needs keys that
survive a refresh.
**Decision:** `mfn-path`, the source position `express-new` records, stays
a server-side data address for write-back and is not rendered. A node's
navigation key, rendered as `data-nav-key`, is its `:name`, or the datum's
identity for data rows (a URI once SEED-O51 is settled),
with its position used only for anonymous members.
**Alternatives:** One positional path serving both purposes, as
`:meta-path` does — rejected for the reasons in the context.

### SEED-D41 — Sorting is a move operation

**Status:** Accepted
**Context:** The old drag-and-drop sort posts a positional path and two
positions read from the DOM, so the client does the bookkeeping and a
stale view moves the wrong item. Sorting is also needed without a mouse.
**Decision:** The Tier-1 `:sorting` default, a stub today
(`modulate2/modulate2.lisp:apply-sorting-default@f55f092`), marks the
sequence with `data-seed-sort` and each item with its key, as navigation
keys are formed (SEED-D40). One drag handler, registered
once, binds Pragmatic drag-and-drop to each sortable sequence; a drop sends
`{action: "move", args: {item, before}}` through the dispatcher
(SEED-D27). The server resolves the keys against the
current data; a key it cannot find rejects the move and refreshes, so a
stale view fails visibly. `:move` is an action each branch declares in its
closed set (SEED-D29), and its handler is the branch's own: for stored `fx`
forms it writes back at the sequence's data address, for live data it
changes the data as the branch requires. The same operation has a keyboard path: the secondary trigger
picks an item up, the directions move it, the primary trigger places it and
the anti-trigger cancels. The old grammar's sort, with `:meta-path`, stays
until its views migrate.
**Alternatives:** Porting the old protocol of path and positions —
rejected: positions go stale, and the browser would keep data addresses.

### SEED-DRAFT-classiccms-D18 — Control banks hold a view's controls that are not tied to a part of it

**Status:** Accepted
**Context:** Most branch views show two banks of controls beside their
content; the CMS's "new" button is in one. The old dual-bank pane
(`modulate/modulate.lisp:amake@0478c2e`, the method on
`uia-primal-dual-bank-pane`) fills them by calling the branch with
`(:uimod :header-controls)` and `(:uimod :footer-controls)`, names that tie
the banks to one layout, a bank above and a bank below. The pane renders
the banks with the page, and the content in its own frame request, so the
banks sit outside the content in the page. The bank contents are built
while the branch's function runs but rendered later, during the `:view`
branch's render. A standard place for controls that act on the whole view
lets every medium present them uniformly, however much space it has.
**Decision:** A branch view has two control banks, *primary* and
*secondary*:

- **Primary and secondary, not top and bottom.** The primary bank holds the
  controls most used; the secondary bank holds the rest. The branch fills
  each for the current view state by answering `(:uimod :cbank-primary)`
  and `(:uimod :cbank-secondary)` with a `(:as :controls)` sequence of
  new-grammar controls. These names replace `:header-controls` and
  `:footer-controls` in every system that uses them.
- **Placement belongs to the medium.** The dual-bank pane places the
  primary bank above the content and the secondary below. Where space is
  scarce, a medium may show only the primary bank, with a hint that brings
  up the secondary bank when a narrow area is clicked or tapped; a terminal
  might place the banks in a status line.
- **Bank controls act on the view or on a collection by name,** as
  `(:by (:submitting :article))`, never by position.
- **The banks share the view's context, collections and refresh.** The old
  grammar's `:join` root — the pane enclosing both banks and the content —
  renders the context and region attributes (SEED-D31, SEED-D33), so it is
  the branch view's root: a bank control finds its context there, and
  gathering a collection searches the whole pane. Bank controls are built
  during the branch's own call, so they carry its context, which is
  captured when a manifestation is built rather than when it is rendered
  (SEED-0016).
- **Banks hold controls only.** The banks and the content are rendered in
  separate requests, so the uniqueness of names (SEED-D35) cannot be
  checked across them. A dispatcher that finds no fields for the collection
  a bank control submits signals an error rather than posting an empty
  submission, and the branch rejects a collection the view does not
  declare (SEED-D26).
- The web rendering marks each bank with the ARIA role `toolbar`.

When the old panes are retired (SEED-O52), the banks become part of the
view's own description rather than separate `:uimod` requests.
**Alternatives:**
- Keeping `:header-controls` and `:footer-controls` — rejected: the names
  couple the banks to one layout.
- View-wide controls placed in the content, wherever each view puts them —
  rejected: without a standard place, a medium cannot rearrange them for
  its space, and navigation cannot treat them uniformly.
- More than two ranked banks — not needed now: two cover the layouts in
  use, and the primary/secondary division matches the trigger taxonomy of
  SEED-D37. More can be added if a use appears.
- The banks declared in the view's own description now — deferred: while
  the panes fetch the content in a separate request, the banks are built by
  separate calls.


## Design

### The client protocol

The web medium renders the interface model as attributes, and the client
code in `maple.lisp` interprets them generically. No attribute holds
JavaScript beyond a component name.

Table: Attributes the web medium renders for the client, and the decisions that define them.

| Attribute | On | Meaning | Decision |
|---|---|---|---|
| `data-seed-system`, `data-seed-branch` | The root of a branch view | The address requests go to | SEED-D31 |
| `data-seed-region` | A region that can be refreshed | Its name, for the response's `refresh` list | SEED-D33 |
| `data-action`, `data-args` | Controls | The action, and its arguments as JSON | SEED-D27 |
| `data-target` | Controls acting on another node | The target's navigation key, not its path, sent as the envelope's `target` | SEED-D26, SEED-D40 |
| `data-seed-submits` | `:submitting` controls | The collection submitted | SEED-D35 |
| `data-seed-field`, `data-seed-in` | Fields | The field's name, and every collection it belongs to | SEED-D35 |
| `role="toolbar"` | The primary and secondary control banks | A bank of view-wide controls | SEED-DRAFT-classiccms-D18 |
| `x-data`, `data-seed-params` | Widgets | The registered component's name, and its parameters as JSON | SEED-D32 |
| `data-nav`, `data-nav-key`, `role`, `tabindex` | Stops and groups (step 8) | The navigation projection | SEED-D38, SEED-D40 |
| `data-seed-sort`, with item keys | Sortable sequences (step 8) | The move operation | SEED-D41 |

Every request posts the envelope of SEED-D26, carrying the
focus, any drafts not yet sent and reported widget state (SEED-D34), and
every response may name the regions to refresh (SEED-D33). A field's
draft is also sent on its own when the field changes.

### The round trip of a form

1. The branch's form function returns a `:collecting` node whose members
   are its fields, nested collections and controls
   (SEED-D35).
2. `generate` resolves membership and renders the collection as an element
   with the role `form`. `:entering` fields are named inputs; a
   `:provision-text` field is a registered editor component carrying its
   field name; each control is a button with `data-action`. Fields are
   filled from the session's drafts for the record the form edits, where
   there are any; as the user edits, each changed field's draft is sent.
3. When a `:submitting` control is activated, the dispatcher gathers the
   collection it submits and posts the envelope through `fetch-contact`
   (SEED-D26, SEED-D27).
4. The branch stores the drafts and focus, maps the action
   (SEED-D29), rebuilds the form, checks the submitted
   collection's fields (SEED-D28), and either calls Classic
   or stores the errors.
5. The response names the regions to refresh: the list after a successful
   create, or the form again with its values and errors.

### A sketch of the article form

Illustrative, not a specification. `control` stands for the exported control
constructor of SEED-D27, with `:submitting t` producing
`(:by :submitting)` and `:submitting :article` producing
`(:by (:submitting :article))`.

```lisp
(defun cms-article-form (&key article index errors)
  (dx (:as :article-form (:layout :horizontal) :by :collecting :name :article)
      (dx (:as :editing)
          (dx (:is :- :required :by :entering :name :title)
              (if article (headline article) ""))
          (dx (:as :markdown :by :provision-text :name :body) (list *system* :cms)))
      (dx (:as :properties :by :collecting :name :meta)   ; nested, like a WordPress meta box
          (dx (:by :choosing :name :status) …)
          (dx (:by :choosing :name :category) …)
          (control :update-meta "Update" :submitting t))  ; sends :status and :category
      (if article
          (control :save "Save" :submitting t :args (list :index index)) ; sends all four
          (control :create "Create" :submitting t))
      (control :back "Back")                              ; sends no fields
      (when errors (dx (:as :errors) errors))))
```

A field placed outside the form's subtree joins it with
`(:as (:member :article))`, and a Save control in a toolbar outside it is
`(control :save "Save" :submitting :article)`. The `:update-meta` action
joins the branch's closed set of actions (SEED-D29) when
the metadata panel arrives (step 7).

### What modulate2 must gain

For controls (step 2):

- Controls with arguments (`make-control` gains `:args`), rendered as
  `data-args`.
- Context attributes on each branch view's root
  (SEED-D31) and region names (SEED-D33).
- The delegated listener and dispatcher, the envelope, and refresh by name,
  in `maple.lisp`.

For forms (step 3):

- The `:collecting` and `:submitting` modalities and the `(:member …)` AS
  sub-form, in `parse-by-spec` and `parse-as-spec`, with manifestation
  slots for them (SEED-D35, SEED-D36).
- Membership resolution, with the uniqueness checks, and the field
  attributes it renders.
- The `:provision-text` editor as a registered component with a field name
  and a value accessor (SEED-D32).
- Drafts and focus in the session, and rendering from them
  (SEED-D34).
- Editor mode chosen from the field's AS format role
  (SEED-D30): a language argument to the client's
  `create-codemirror`, which today always uses Lisp mode, and CodeMirror's
  Markdown language declared as a direct dependency and imported into the
  client build.
- A representation of field errors for rendering (SEED-O47).

For navigation and sorting (step 8): the navigation projection, its
attributes, the key declaration and the client walker
(SEED-D37 to SEED-D40), and the
`:sorting` default with the `:move` operation (SEED-D41).

Tests for each. (`construct` resolving IS through `resolve-is` landed at
step 1.)

### Tests

A `seed.modulate2.test` system beside `test/seed.generate.test.asd`, written
to the Square standard (FiveAM and cl-hamcrest, wired to ASDF's `test-op`).
The suite as it landed at step 1 uses FiveAM's own assertions only; adopting
cl-hamcrest's matchers is outstanding. The tests check manifestation trees
and the generated HTML trees, not rendered strings, so that they survive
changes of markup. Membership resolution and the navigation projection are
server-side functions over the manifestation tree, so they are tested like
the rest. The client code — the dispatcher, form gathering and the
navigation walker — is checked by the manual checklist until there is a way
to test client code.


## Scope and Non-Goals

- **In scope:** steps 0–8 below — the CMS's create, list, edit and metadata
  views in the new grammar, the `modulate2` pieces they need, and keyboard
  navigation and sorting over `modulate2` views.
- **Not in scope here:** navigation in old-grammar views, which take no
  part: an old-grammar region inside a new-grammar view is a single stop
  that cannot be entered. Navigation modes other than the form's tree
  (SEED-D37).
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
SEED-O51.

**Two different indices.** The list is built from `get-articles` with its
default arguments and counts from 0. Classic's `edit-article` counts from 1,
over `get-articles` with `:include-deleted t`; the old code converts with
`(1+ edit-idx)`. The two agree only while no article has been deleted. Once
deletion arrives (increment B), a position in the list and an index for
`edit-article` can name different articles. SEED-D30
settles that the save action carries `edit-article`'s 1-based index, so the
list's edit controls must produce that index — not their 0-based position
among current articles — once deleted articles exist.

**The CodeMirror token.** `:provision-text` names its editor after the
system and branch, so one branch can hold only one server-fetched editor at
a time. The CMS shows one at a time; a form with two text fields could not
(SEED-O49).

**Client code is untested.** The dispatcher, form gathering and the
navigation walker are checked by hand until there is a client test harness.

**Where the root learns its context.** `modulate2` must render each branch
view's address (SEED-D31) while old-grammar panes still
supply `mode`. This was settled before step 2 (SEED-0016): each branch's
function binds the system and branch dynamically
(`generate/generate.lisp:channel-fns@0478c2e`), and a manifestation records
the binding when it is built, because some, such as the controls in a
bank, are rendered after their branch's call has returned
(SEED-DRAFT-classiccms-D18). It still bears on SEED-O52: once the old
panes are gone, something must make the same binding.

**Ambiguous names.** Gathering matches collections and fields by name, so a
duplicate name would gather the wrong fields. The server's check while
resolving membership (SEED-D35) must be tested, not
assumed.

**Draft size.** A draft is sent when its field changes, so a changed
article body is sent again after each pause in typing (SEED-D34). This is
acceptable for the CMS; a view with very large text fields might need
drafts sent as changes to the previous draft rather than whole values.

**Structure against appearance.** Movement over the form's tree will
sometimes contradict what the eye sees (SEED-D38). The
convention is accepted and the focused group's direction is shown; if use
shows it hurts, the reserved alternative is rotating the axes by layout.

**Tab as the cross trigger.** Taking over Tab removes the browser's own
keyboard order (SEED-D39); step 8 must keep the page
usable by keyboard and screen-reader users.


## Open Questions

### SEED-O46 — How are constraints written?

The sketch writes a required title as `(:is :- :required)`, an IS stratum-2
specializer. Is "required" a property of the data's character, or a
constraint that belongs elsewhere — a BY property of entry, or a separate
`:constraints` sub-form? The same question will arise for lengths, formats
and ranges.

### SEED-O47 — How are errors represented?

Are field errors manifestations with an AS role such as `:error`, attached
to the field they concern, or annotations on the field itself that the
medium renders? Where are form-level errors, such as a permission error,
shown?

### SEED-O48 — Effect classes on controls now?

SEED-0009 gives each operation an effect class (`:safe`, `:idempotent`,
`:effecting`). Should controls carry it from the start — so that, for
example, an effecting control can be disabled while its request is in
flight — or only from increment E?

### SEED-O49 — Naming editors

Should a `:provision-text` editor's token include its field name, so that a
form can hold more than one, and two forms can share a page?

### SEED-O50 — Generated handlers or one listener?

As first accepted, SEED-D27 called the dispatcher from a click handler
generated on each control. A single listener on the document would remove
the handlers from the markup, but must find each element's Alpine scope. Is
that worth doing, and when?

The revision of 2026-11-18 proposes an answer: with the context in data
attributes (SEED-D31), a listener needs no Alpine scope,
and SEED-D27 now uses one delegated listener from step 2.
The resolution is recorded when that is accepted.

### SEED-O51 — Addressing articles

Should controls address articles by URI — which `write-article` returns —
rather than by index, with a Classic function to edit by URI? This would
fit Classic's model better and remove the risk of a stale index. It would
also remove the mismatch between the list's 0-based positions over current
articles and `edit-article`'s 1-based index over all articles, deleted ones
included, which matters from increment B, when articles can be deleted.

### SEED-O52 — Context without the old panes

The dispatcher relies on the `mode` that the old grammar's frames and panes
place in scope to address the branch. When the old aspect system is
retired, what provides that context — a manifestation-level attribute
naming the system and branch, or something the branch-object model supplies?

SEED-D31 answers the client side: the address is rendered
as attributes on each branch view's root, and the dispatcher no longer
uses `mode`. What remains open is the server side — what gives `modulate2`
the system and branch when it renders the root, once the old panes are
gone.

### SEED-O53 — Exclusive and subtractive membership

`(:as (:member …))` adds to the memberships nesting gives
(SEED-D35). A field may sometimes need to sit inside a
collection without being submitted with it — a search box within a form —
or to belong only to the collections it names. Should a later form express
exclusive membership, or remove memberships that would otherwise apply,
and how is it written?

### SEED-O54 — Naming the widget modalities

`:provision-form` becomes `:collecting` (SEED-D35). The
other `:provision-*` modalities — text, sheet, chart, graph — name abstract
widgets. Is "provision" the right term for them, or should they be renamed
in the same way, before more code depends on the names?

### SEED-DRAFT-classiccms-O10 — Reaching the control banks by keyboard

Under SEED-D38 a pane's primary bank, content and secondary bank are
siblings in the navigation tree, so reaching a bank from deep in the
content means moving up to the pane, then across. If the banks are the
standard place for a view's controls (SEED-DRAFT-classiccms-D18), should
there be a quicker way to them — the cross trigger cycling through the
content and the banks within a pane, or a key for each bank — and how does
that fit the cross trigger's role of moving between top-level spaces
(SEED-D39)? To be settled at step 8.


## Prior Art

Except for Seaside, which the Smalltalk Eval (SEED-0008) examines, the
systems below are named from general knowledge; their details were not
re-checked for this plan.

Table: Prior systems and what this plan draws from each.

| System | What to draw from |
|---|---|
| HTML forms and `FormData` | Gathering named fields; the `form` attribute, which associates an input with a form elsewhere on the page, is the precedent for `(:as (:member …))` — limited to one form per input (SEED-D35) |
| Phoenix LiveView forms and Ecto changesets | Validation against a declared schema on the server, with errors and submitted values re-rendered in the form; change events reporting unsaved values to the server (SEED-D34) |
| Rails strong parameters | Accepting only declared parameters (SEED-D29, and the `fields` of SEED-D26) |
| WordPress's post editor | Property panels beside the main text, each with its own update control, inside one post form (SEED-D35) |
| Seaside (evaluated in SEED-0008) | Forms whose controls are bound to server-side actions, with no hand-written client code; its server-side registry of rendered callbacks is the deferred kept-tree alternative of SEED-D34 |
| Alpine's `Alpine.data` components | Behaviour registered once and named from markup (SEED-D32) |
| htmx's `HX-Trigger` response header | The server naming the events, and so the regions, a response triggers (SEED-D33) |
| Paredit and structural editors | Movement over the tree of forms rather than over text or the screen (SEED-D38) |
| WAI-ARIA tree views and roving `tabindex` | Keyboard focus that stays real DOM focus; the tree view's axes, held in reserve (SEED-D38) |
| The W3C's CSS spatial-navigation proposal | Geometric movement, considered and rejected (SEED-D38) |
| The old grammar's `uir-call` roles | Generated click handlers that pass the scope's `mode` to `fetch-contact` — superseded by the delegated listener (SEED-D27) |


## Roadmap

Each step ends with the CMS's list, create, edit and save flow working and
the checklist passed; Create was restored in the old grammar at step 0.
Each step is recorded in a Log (SEED-0016) as it lands.

1. **Step 0 — Diagnose Create.** Done: the cause was a `var` at the start
   of an Alpine handler (see "Starting point: the CMS").
2. **Step 1 — A test suite for modulate2.** Done at `7564294`: tests for
   expression of atoms and sequences, IS resolution including `:-`, `dx`
   construction, valence and layout, `:reducing` controls, `:provision-text`
   output, and the bridges; `construct` resolves IS.
3. **Step 2 — Controls that work.** The exported control constructor with
   arguments; the branch context bound by each branch's function and
   recorded by a manifestation when it is built; context and region
   attributes on the branch view's root (SEED-D31,
   SEED-D33) — for the old panes, the `:join` root, which encloses the
   control banks (SEED-DRAFT-classiccms-D18); the delegated listener, the
   envelope and refresh by name (SEED-D27, SEED-D26,
   SEED-D33), each region falling back to a refresh of the whole page; the
   duplicate `:form-input-def` key in `maple.lisp` fixed.
   `:header-controls` and `:footer-controls` renamed `:cbank-primary` and
   `:cbank-secondary` in every system that uses them, and the banks marked
   with the role `toolbar`. Two old-grammar buttons are replaced by
   new-grammar controls, so the checklist exercises the dispatcher before
   any form exists: Back in the edit view, inside the content, and "new" in
   the primary bank, outside it. The branch already handles both actions.
   They are test fixtures for the dispatcher, not moves of their views,
   which move at steps 4–6, so the order of SEED-D25 is unchanged. Tests
   for the generated buttons and their attributes, including `data-args`
   and `data-target`; for the context recorded at construction and kept
   when rendered under another branch's binding; and for the attributes of
   a `:join` root.
4. **Step 3 — Forms.** Collections (SEED-D35,
   SEED-D36): `:collecting`, `:submitting` and
   `(:member …)` parsed; membership resolved, with the uniqueness checks;
   the field attributes rendered. The `:provision-text` editor as a
   registered component with a field name and value accessor
   (SEED-D32). Form gathering in the dispatcher
   (SEED-D26), and fields outside every collection submitting their single
   datum (SEED-D35). Drafts sent when a field changes, kept in the session
   by field, collection and record, limited to declared fields, cleared on
   a successful submit, and rendered from; focus kept likewise
   (SEED-D34). Tests, including membership
   by nesting, by `:member` and by inclusion, a duplicate name, a field
   outside every collection, drafts for two records of one form, a
   `:provision-text` field whose value is a list (expressed as a sequence)
   and a collection with a `nil` member.
5. **Step 4 — The create view.** The article form
   (SEED-D30) in create mode, its body editor in Markdown
   mode selected through `(:as :markdown)`, with `@codemirror/lang-markdown`
   declared explicitly in the `package.json` of the npm interface the client
   build imports it from; the text protocol's load returning the body's
   draft when there is one (SEED-D34); the `:create` action with
   validation (SEED-D28) and closed actions
   (SEED-D29); `:back` discarding the view's drafts;
   `render-cms-create` and its inline script deleted. Create works in the
   new grammar.
6. **Step 5 — The article list** (Survey A1). Headline, state and date as
   `:observing` atoms, with an edit control per article carrying its index;
   `render-cms-list` deleted.
7. **Step 6 — The edit view** (Survey A2). The article form in save mode,
   loading its body through the text protocol, or its draft for that
   article when there is one (SEED-D34); the `:save` action calling
   `edit-article` with title and text; `render-cms-edit`, its inline script
   and the text protocol's save path deleted.
8. **Step 7 — The metadata panel** (Survey A3). Fields generated from
   Classic's slot metadata (CLASSIC-0007) through the Classic→fx bridge; the
   `:extending` and `:reducing` defaults finished for the category list.
   The panel is a nested `:meta` collection with its own submitting
   control (SEED-D35).
   This step will be detailed in a revision of this plan, once steps 4–6
   have shown the form in use.
9. **Step 8 — Keyboard navigation and sorting.** The navigation projection
   and its attributes (SEED-D38,
   SEED-D40); the key declaration and its Mousetrap
   bindings, the client walker, edit mode on fields and the triggers
   (SEED-D37, SEED-D39); the server's
   focus and last-visited memory (SEED-D34); the focused
   group's direction shown; how the control banks are reached
   (SEED-DRAFT-classiccms-O10). The `:sorting` default and the `:move`
   operation, by drag-and-drop and by keyboard (SEED-D41).
   Tests for the projection, which is computed on the server; the
   checklist covers the walker, edit mode and keyboard access to the page
   with a screen reader.
10. **Later — Survey increments B–E,** in outline: workflow controls filtered
   by permission (B); the rendered preview (C); the wiki views (D); the
   branch-object migration, with operations, effect classes and Classic
   writes as queued effects (E, SEED-0009). Each is planned when it comes.
