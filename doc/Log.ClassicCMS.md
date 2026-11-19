---
id:            SEED-DRAFT-classiccmslog
title:         "Classic CMS Development Log"
genre:         Log
scope:         project
project:       Seed
language:      en
status:        Draft
provenance:
  assistant:   claude-opus-4-6
relates-to:
  - SEED-DRAFT-classiccms
  - SEED-0011
  - SEED-0003
  - SEED-0004
decisions:
  - SEED-DRAFT-classiccmslog-D1
open-questions:
  - SEED-DRAFT-classiccmslog-O1
---

# Classic CMS Development Log

This document chronicles the implementation of the Classic CMS interface in
the IS/AS/BY grammar, following the Plan (SEED-DRAFT-classiccms). It grows
with one Update section per step, as the SpecOps Manifest Log does.

The initial entry records step 0 (diagnosis of the Create failure) and
step 1 (the modulate2 test suite and the `construct` fix). Later steps will
be recorded as they land.


## Problem

The CMS's Create button did nothing. The Plan identified three candidates
but had not diagnosed the failure. The old grammar was scheduled for
replacement (SEED-DRAFT-classiccms-D1), but shared code that the new form
also uses — `fetchContact`, the refresh mechanism, Classic's checks — could
carry the same fault.


## Step 0 — Diagnosis

### The cause

The browser console reported:

```
Alpine Expression Error: Unexpected token 'var'

Expression: "var f=$event.target.closest('.series');if(f){var ti=f.querySelector
('[name=title]');var bo=f.querySelector('[name=body]');fetchContact($event.target,
mode,{action:'create',title:ti?ti.value:'',body:bo?bo.value:''},{next:'refresh'})}"
```

Alpine 3 evaluates an `x-on:` attribute as an expression. It accepts
multi-statement text only when the first token is `let`, `const` or `if`;
otherwise the text is compiled as `result = <text>`, and `var` is not valid
in expression position. The handler began `var f=…`, producing a syntax
error before any code ran. The button silently did nothing.

**Fix:** changing `var` to `let` in the Create script's first declaration
(`systems/demo.access/seed.lisp:render-cms-create@bdf7f99`) caused Alpine
to compile the text as a function body, making the remaining `var`
declarations legal. Create then worked: the article appeared in the list.

The edit view's Save script had the same `var` start. This Log first said
it was fixed in the same commit; it was not. It was fixed at `f55f092`
(`systems/demo.access/seed.lisp:render-cms-edit@f55f092`), and the fix has
not yet been checked in the browser.

### Hypotheses ruled out

Two hypotheses proposed during diagnosis were wrong and are corrected here:

1. **Nested `x-data` scope isolation.** The initial diagnosis proposed that
   the dual-bank-pane's inner `x-data` cut off access to the parent series's
   `mode`. This is incorrect: Alpine 3 nested components can read ancestor
   data. `mode` is in scope inside the frame's swapped content.

2. **`$el` vs `$event.target`.** An earlier change replaced `$el` with
   `$event.target` in the click handler, based on a belief that `$el` in
   Alpine 3 refers to the component root rather than the current element.
   In Alpine 3, `$el` inside an `x-on:` handler is the element the handler
   is on. The change was harmless but unnecessary.

### Server-side findings

Classic's `write-article` was tested with three payload shapes:

- Normal string arguments: succeeds.
- Empty title (`""`): succeeds — Classic creates an article titled `""`.
- Nil title: signals a type error (`NIL is not of type STRING`).

The CMS branch's guard (`(when (and title (plusp (length title))))`) rejects
nil and empty titles, so Classic's type error is not reached in practice.
However, Classic does not enforce "required" on its own: a title of `""`
passes through to the persistence layer. This confirms that "required" must
come from the form's description, bearing on SEED-DRAFT-classiccms-D4 and
SEED-DRAFT-classiccms-O1.

### The `form-input` / `field-in` key collision

Both `form-input` and `field-in` are registered in
`platform/browser/pla.browser.maple/maple.lisp@bdf7f99` under the same key,
`:form-input-def`, in `enter-js-element`. The macro uses `setf getf`, so
the second registration overwrites the first. The built client (`int.js`)
contains `fieldIn` and no `formInput`. SEED-DRAFT-classiccms-D2's claim to
"extend the existing `form-input` function" was corrected in the Plan
revision at `1a8135c`: step 3 writes the form gathering fresh.


## Step 1 — Test suite and construct fix

Landed at `7564294`.

### The test suite

A `seed.modulate2.test` system was created beside the existing
`seed.generate.test`, following the Square standard (FiveAM, wired to
ASDF's `test-op`). It covers six suites:

| Suite | What it tests |
|---|---|
| `m2-is` | `infer-data-character` and `resolve-is`, including the `:-` sentinel |
| `m2-expression` | `express-new`: atoms, sequences, IS sentinel, named forms |
| `m2-construct` | `construct`: atoms, sequences, layout, valence, IS resolution, mixed children |
| `m2-controls` | `make-control` structure, `:reducing` default, `:bare` suppression |
| `m2-rendering` | `generate` for `uim-web`: each modality, provisioning, controls wrapping |
| `m2-bridge` | The three hook variables and round-trip through `dx` |

35 tests, 81 checks, all passing. Tests check manifestation trees and
Spinneret HTML trees, not rendered strings, so they survive markup changes.

The suite uses FiveAM's own assertions only. The Square standard, and the
Plan's description of the suite, also call for cl-hamcrest's matchers;
adopting them is outstanding.

### The construct fix

`modulate2/modulate2.lisp:construct@7564294` was fixed to call `resolve-is`
rather than using the explicit IS directly. Before the fix, the `:-`
sentinel (meaning "inferred type plus asserted specializers") worked in
stored `fx` forms but not in `dx` specs:

```lisp
;; Before: IS used as given — (:- :pathname) stays as (:- :pathname)
:is (or is-spec (list (infer-data-character children)))

;; After: IS resolved — (:- :pathname) becomes (:string :pathname)
:is (resolve-is children is-spec)
```

`resolve-is` was exported from `seed.modulate2` for the tests.


## Design Decisions

### SEED-DRAFT-classiccmslog-D1 — Generated handler attributes are a single function call

**Status:** Proposed
**Context:** The Create failure was caused by Alpine 3 rejecting `var` at
the start of an `x-on:` attribute. The inline scripts in the CMS views
are multi-statement JavaScript strings assembled by `format`, which is
fragile, hard to test, and duplicates logic that should live in one place.
**Decision:** A generated `x-on:` attribute contains exactly one function
call, such as `seedSubmit($el, mode)` or `seedActivate($el, mode)`. All
logic lives in named functions defined once in `maple.lisp`. This prevents
the Alpine expression error from recurring and keeps generated markup free
of JavaScript beyond the call.
**Alternatives:** Wrapping statements in an IIFE — works but does not
address the duplication. Using Alpine's `x-on:click="$dispatch('action',
{...})"` — adds an Alpine dependency to the protocol.

The Plan's revision of 2026-11-18 folds this decision into
SEED-DRAFT-classiccms-D3, which goes further: one delegated listener
handles every control, so generated markup carries no handler code at all,
and any `x-on:` attribute that must still be generated holds a single call.
When that revision is accepted, this record can be marked superseded by it.


## Open Questions

### SEED-DRAFT-classiccmslog-O1 — Navigation model

The old grammar's `:meta-path` conflates data addresses (positions in the
`fx` source, used for write-back) with interface navigation. It is set
only by `express`, so `dx`-built components get no path, and positional
indices go stale after inserts or sorts. These should be separated: a
data address for write-back (opaque, branch-interpreted, possibly a URI
per SEED-DRAFT-classiccms-O6) and a navigation model for keyboard focus
(derived from the manifestation tree's AS roles and BY modalities, rendered
as ARIA roles and a roving tabindex, computed from the DOM at key-press
time so it cannot go stale). The navigation model is discussed but not yet
decided; it will be recorded in a Plan revision when settled.

The Plan's revision of 2026-11-18 proposes answers. Data addresses stay on
the server and navigation keys are rendered separately
(SEED-DRAFT-classiccms-D16). The navigation model is a projection of the
manifestation tree, computed on the server and rendered as markers, with
movement over the tree of forms rather than the page
(SEED-DRAFT-classiccms-D14) and focus owned by the server
(SEED-DRAFT-classiccms-D10). The resolution is recorded when the revision
is accepted.


## Files

Table: Files added or changed in steps 0–1.

| File | Status | Notes |
|---|---|---|
| `test/seed.modulate2.test.asd` | **New** | ASDF system for the modulate2 test suite |
| `test/package-m2.lisp` | **New** | Test package |
| `test/helpers-m2.lisp` | **New** | Suite hierarchy, web-medium factory, runners |
| `test/test-modulate2.lisp` | **New** | 35 tests across 6 suites |
| `modulate2/modulate2.lisp` | Modified | `construct` calls `resolve-is` |
| `modulate2/package.lisp` | Modified | Exports `resolve-is` |
| `systems/demo.access/seed.lisp` | Modified | `var` → `let` in the Create script (`bdf7f99`) and the Save script (`f55f092`) |
| `doc/Plan.ClassicCMS.md` | Modified | Three corrections (see step 0) |


## Update 2026-11-18 — The client protocol amendment

Before step 2, the redesign of the old grammar's `mode`, `methods` and
`patch`, and the navigation model, were settled in discussion and recorded
as a revision of the Plan. The revision's records are Proposed:

- **Context, widget state and refresh** (SEED-DRAFT-classiccms-D7 to
  SEED-DRAFT-classiccms-D9). `mode`'s address becomes `data-` attributes
  on each branch view's root; widget behaviour is written once and
  registered as Alpine components with JSON parameters; the server names
  the regions a response refreshes, replacing `patch`.
- **Reported state** (SEED-DRAFT-classiccms-D10). Focus and the drafts of
  changed fields travel with every request and are kept by the server, so
  that a partial submit loses no unsaved edits and a terminal medium can
  share the model. Keeping the rendered tree in the session was considered
  and deferred to increment E.
- **Forms as collections** (SEED-DRAFT-classiccms-D11,
  SEED-DRAFT-classiccms-D12). `(:by :collecting)` replaces
  `:provision-form`; membership comes from nesting, plus
  `(:as (:member …))`, which adds to it; `(:by :submitting)` controls are
  the only ones that gather fields. AS roles may now name other nodes,
  refining SEED-D19.
- **Revisions of the payload and the dispatcher**
  (SEED-DRAFT-classiccms-D2, SEED-DRAFT-classiccms-D3). An envelope
  replaces the flat payload; no HTML `<form>` element; one delegated
  listener replaces per-control handlers, absorbing
  SEED-DRAFT-classiccmslog-D1.
- **Step 8, navigation and sorting** (SEED-DRAFT-classiccms-D13 to
  SEED-DRAFT-classiccms-D17). Movement through spaces chosen by mode, the
  first space being the tree of forms; triggers mapped to BY modalities;
  data addresses separate from navigation keys; sorting as a `:move`
  operation, by drag-and-drop or by keyboard.

Two new open questions record what was deferred: exclusive or subtractive
membership (SEED-DRAFT-classiccms-O8) and the naming of the `:provision-*`
modalities (SEED-DRAFT-classiccms-O9).

While checking this Log against the code, the edit view's Save script was
found still to begin with `var` (see step 0) and was fixed at `f55f092`.


## Outstanding Work

- Steps 2–8 of SEED-DRAFT-classiccms, beginning with working controls
  (step 2) and collections (step 3), under the revision of 2026-11-18.
- Check the Save fix at `f55f092` in the browser.
- Adopt cl-hamcrest's matchers in the modulate2 test suite, as the Square
  standard requires.
