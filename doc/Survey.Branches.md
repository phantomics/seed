---
id:            SEED-DRAFT-branches
title:         "The Branch System: Design Space and Future Directions"
genre:         Survey
scope:         project
project:       Seed
language:      en
status:        Draft
provenance:
  assistant:   claude-opus-4-6
relates-to:
  - SEED-DRAFT-tripleontology
  - SEED-DRAFT-dxontologyupdate
  - SEED-DRAFT-interfacemodels
  - SEED-DRAFT-editormodels
  - SEED-DRAFT-smalltalk
open-questions:
  - SEED-DRAFT-branches-O1
  - SEED-DRAFT-branches-O2
  - SEED-DRAFT-branches-O3
  - SEED-DRAFT-branches-O4
  - SEED-DRAFT-branches-O5
---

# The Branch System: Design Space and Future Directions

This document surveys the design space around Seed's branch system — the
mechanism by which a Seed application receives input, processes it through a
composable pipeline of adapter stages, and produces output for a medium. The
branch system is already implemented and in daily use, but its pipeline
architecture points toward capabilities (history, clipboard, cross-instance
communication, transactional execution) that are not yet built. This survey
explores what those capabilities would look like and what prior art informs
them.


## Motivation

Seed's branch system is the counterpart to its rendering pipeline. On the output
side, `fx` forms are expressed into manifestation trees and rendered through
medium-dispatched `generate` methods — documented in SEED-DRAFT-tripleontology
and SEED-DRAFT-dxontologyupdate. On the input side, branches receive requests,
normalise them through adapter stages, and pass them to handler lambdas that
produce responses.

Together these form two halves of a symmetric design: adapters normalise
heterogeneous input into a uniform plist, and `generate` methods specialise
uniform manifestation trees into medium-specific output. The branch sits between
them. Understanding its design space is necessary for determining how clipboard,
history, inter-branch communication, and eventually distributed execution should
work.


## Starting Point

All code references in this section are pinned to revision `31067ad`.

### The `seed` and `branch` macros

`generate/generate.lisp:seed@31067ad` defines a system: a named scope with
branches, session state, and access control. It generates the `grow` function
(for calling branches), the `of-state` accessor (for session-scoped state), and
the `defbranch` registration function.

`generate/generate.lisp:branch@31067ad` registers a branch under a keyword key.
Its body is a sequence of forms — adapter calls and handler lambdas — that
`generate/generate.lisp:channel-fns@31067ad` composes into a single function.

### The pipeline

`channel-fns` generates a lambda that chains the forms sequentially. Each stage
receives `(state data)`, transforms `data`, and optionally returns a second
value. When any stage returns a truthy second value, all subsequent stages pass
the data through unchanged — the short-circuit mechanism. The result is a linear
pipeline:

```
raw input → adapt-from-json → adapt-from-alist → [mutation stages] → handler → output
```

### Adapters as input-medium normalisation

`generate/generate.lisp:adapt-from-json@31067ad` returns a lambda that checks
whether its input is a string. If so, it parses it as JSON and extracts only the
named keys, converting camelCase names to Lisp keywords. If not, it passes the
input through unchanged.

`generate/generate.lisp:adapt-from-alist@31067ad` does the same for alist input.

Having both in a pipeline makes a branch **polymorphic on input format**: the
same handler works whether input arrives as JSON from an htmx POST or as an
alist from an internal call via `grow`. By the time the handler lambda receives
its `input`, it is always a keyword plist:

```lisp
(destructuring-bind (&key action path sort remove &allow-other-keys) input ...)
```

The property names passed to each adapter — e.g.
`(adapt-from-json :point :action :system-name)` — act as a **whitelist**.
Only named properties are extracted; everything else is dropped. This serves as
both documentation (reading the adapter calls tells you what a branch accepts)
and a basic input-filtering boundary.

The two adapters also reveal a semantic split: `adapt-from-json` lists the
**user-facing** inputs (what the browser sends), while `adapt-from-alist` lists
the **framework-internal** inputs (`:system`, `:branch`, `:face` — injected by
the HTTP layer).

### Generic mutation stages

`systems/abcd/seed.lisp:fx-path-access@31067ad` is a pipeline stage that
handles path-based editing of `fx`-annotated data. Given input with `:data` and
`:path` keys, it navigates the `fx` tree to the specified position, reads the
`:type` metadata to determine how to parse the incoming value (`:numeric` →
`read-from-string`, else treat as string), and mutates the value in place. The
stage is generic: it works on any `fx`-annotated tree regardless of what the
data represents.

`systems/abcd/seed.lisp:form-sort@31067ad` is a generic stage for reordering and
removing elements in `fx`-annotated lists. It handles `:sort` (reorder by
index) and `:remove` (delete by index) operations on any list structure, using
destructive list surgery (`rplacd`, `nthcdr`).

Both stages demonstrate **write-time operations as composable middleware**: the
`fx` metadata that drives interface generation on the output side also guides
mutation handling on the input side.

### The `grow` function and `of-state`

`grow` dispatches to a branch by system and key: `(grow system branch session
input)`. Currently it is a local function call, not a remote invocation.

`of-state` provides session-scoped key-value storage. A branch reads and writes
state through `(of-state :system :key)` and `(of-state :system :key value)`.
State persists across requests within a session.

### The output side

A branch typically returns a rendered HTML string by calling
`(render medium (dx ...))` or `(render medium (express ...))`. With modulate2
loaded, the branch can also produce manifestations: `(dx (:as :workspace ...) ...)`
returns a manifestation, and the `:adapting` processor mechanism
(SEED-DRAFT-tripleontology, decision SEED-DRAFT-tripleontology-D4) lets the
branch supply lambdas that adapt the expressed tree before rendering. This
creates a second pipeline on the output side: the branch builds a tree, named
processors modify it, Tier-1 modality defaults add affordances, and `generate`
renders it.


## The Input Side of Medium Independence

The adapter pipeline and the rendering pipeline form a symmetric pair:

Table: Symmetric normalisation on input and specialisation on output.

| Side | Raw form | Normalisation | Handler sees | Specialisation | Final form |
|------|----------|---------------|-------------|---------------|------------|
| Input | JSON string or alist | `adapt-from-json`, `adapt-from-alist` | Keyword plist | — | — |
| Output | — | — | Manifestation tree | `generate` per medium | HTML, terminal, etc. |

This means adding a new **input** medium (a terminal command parser, a gamepad
event stream, a voice-command transcriber) requires only a new adapter:
`(adapt-from-terminal :action :direction :trigger)`. The handler lambda and the
mutation stages stay unchanged. Adding a new **output** medium requires
`generate` methods for a new `uim-*` class. The handler and the adapters stay
unchanged. The branch handler itself is medium-independent on both sides.


## Write-Time Operations as Stages

### Current stages

`fx-path-access` and `form-sort` are the two existing generic stages. Both
operate on `fx`-annotated data using the metadata to guide their behaviour.
They are the input-side counterparts of the roles that guide output-side
rendering: `uir-sortable` produces drag handles in the interface; `form-sort`
processes the resulting reorder request on the input side.

### A validation stage

The editor-models Eval (SEED-DRAFT-editormodels, criterion G2) identified
Seed's most significant gap: metadata is asserted, not checked. A pipeline
stage `with-validation` could close this gap on the input side:

- Read the IS metadata of the target field (`:type :numeric :integer`).
- Check the incoming value against the declared type.
- Reject or coerce invalid input before it reaches the handler.

This would be a generic stage, like `fx-path-access`, working on any
`fx`-annotated data. It would make the adapter whitelist + validation stage
together serve the same role as a schema validator in a conventional API.

### Adapter declarations derived from metadata

Currently the adapter whitelist is manually maintained and must match the
handler's `destructuring-bind`. This is a duplication that invites drift. If
the `fx` metadata on the branch's data already declares what fields exist
and what types they are, the adapter declaration could be *derived* from the
metadata — a single source of truth for what the branch accepts, what types
it expects, and how to destructure the result.


## Branch-to-Branch Patterns

### Clipboard and history as pipeline stages

A `with-history` stage would intercept the pipeline before mutations:

- On normal input: snapshot the current state of the referenced data, push onto
  a history stack in session state, pass input through.
- On `:undo`: pop the stack, restore previous state, short-circuit.
- On `:redo`: move forward in the stack, restore, short-circuit.

A `with-clipboard` stage would:

- On `:copy`: store the current selection by path, short-circuit.
- On `:cut`: store, pass a `:remove` operation through.
- On `:paste`: inject clipboard contents at the specified path.

These stages are **generic** — they snapshot and restore S-expression trees
without interpreting their content. They fit naturally as pipeline middleware
because the adapter declaration already identifies the relevant input keys
(`:undo`, `:redo`, `:copy`, `:paste`).

### Clipboard and history as branches

The alternative is independent branches with their own state and adapter
pipelines. As branches, they:

- Have their own session-scoped state (the history stack, the clipboard buffer).
- Can be invoked by multiple content branches (a clipboard shared across
  editors).
- Can be rendered (showing clipboard contents or a history timeline).

Content branches invoke them via `grow`:

```lisp
(grow *system* :clipboard session (list :action :copy :data selected-entity))
```

The adapter declaration on the clipboard branch serves as a **protocol
specification**: any branch that calls it knows what messages it accepts.

### The two approaches compose

Pipeline stages work best when clipboard or history is **local to one
branch's data**. Branches work best when clipboard or history is **shared
across multiple branches or systems**. A pipeline stage can delegate to a
clipboard branch via `grow`, combining both patterns.


## Beyond One Image

The following sections describe capabilities that are **not yet built** and
are presented as architectural directions rather than design commitments.

### Cross-instance contact

A branch that contacts an external Seed instance would extend the adapter
pipeline:

```
[remote wire format] → adapt-from-remote → adapt-from-json → handler → [output]
```

The handler would be identical to a local branch. The adapter normalises the
remote input. On the output side, a branch could return a routing signal that
the framework dispatches to a remote system rather than rendering locally.

### Network-transparent `grow`

`grow` is currently a local function call. Its interface —
`(grow system branch session input)` — is already the shape of a remote
procedure call. Making it network-transparent (dispatching to local or remote
branches based on a configuration table) would require no changes to branch
handlers, only to the dispatch mechanism.

### A transaction stage

`with-transaction` would snapshot state on entry and either commit (on normal
return) or roll back (on error). Combined with the condition system, this would
give branches atomic mutation semantics. The mainframe comparison is CICS's
syncpoint: either all mutations in a unit of work commit, or none do.

Currently branches mutate state destructively via `of-state` and `rplacd`
operations with no atomicity. For multi-user portals, transactional integrity
would be a prerequisite.

### An event log

Recording the normalised input plist (post-adapter, pre-handler) as an
append-only log would enable replay, audit, and debugging. The log would
capture what the handler saw, not what the wire carried, so it would be
transport-independent. Each entry would include the branch key, session
identifier, timestamp, and the normalised plist.


## Tensions in the Current Design

The following are known rough edges, flagged here to inform future Plans.

1. **Stage macros capture bare symbols.** `fx-path-access` and `form-sort`
   generate lambdas whose parameters must match the names `state` and `input`
   used inside the macro body. This works because `channel-fns` generates the
   enclosing lambda with matching parameter names, but it is fragile. A more
   robust design would pass context through explicit arguments.

2. **The adapter whitelist and the handler's destructuring are duplicated.** If a
   key is added to `adapt-from-json` but not used in the handler (or vice
   versa), there is no warning. A unified input declaration would generate both.

3. **Multiple lambdas with short-circuiting are opaque.** A branch like
   `:chentity` has four processing stages after the adapters, with
   short-circuiting determining which ones execute. The reader must mentally
   simulate the flow. Named stages with declared dependencies would make the
   logic transparent.

4. **Hard-coded state keys.** `fx-path-access` assumes the editable data is
   always accessed via a specific `(of-state :- :key)` expression passed as
   a macro argument. A properly parameterised middleware stage would receive
   its target through an explicit argument rather than a macro-injected
   accessor.

5. **Closure state shared across sessions.** Some branches close over lexical
   variables outside the handler lambda, e.g.
   `(let ((sys-name)) (branch :nav ...))`. This state is per system, not per
   session, which is a concurrency hazard in a multi-user portal.

6. **The `*SYSTEM*` dependency at expansion time.**
   `generate/generate.lisp:branch@31067ad` reads the `*SYSTEM*` special
   variable at macro-expansion time to find the `DEFBRANCH` registration
   function. This couples the branch definition to compile-time package state.

7. **No defined behaviour when a stage signals an error.** The pipeline has no
   error phase. If a mutation stage signals a condition, there is no mechanism
   for a subsequent stage to clean up. A transaction stage or an interceptor
   model with enter/leave/error phases would address this.

8. **Stages have no names and cannot be inspected.** There is no way to list the
   stages of a branch, query what adapters it declares, or trace the data
   through the pipeline. A pipeline inspector — suggested by the moldable
   debugger concept in the Smalltalk Eval (SEED-DRAFT-smalltalk) — would
   require named, introspectable stages.

9. **The adapter whitelist is not a complete security boundary.**
   `adapt-from-json` passes through any input that is not a string, and
   `adapt-from-alist` passes through any input that is not an alist. The
   whitelist filters only when the adapter's type check matches.


## Candidate Design Principles

The following are surfaced by the survey rather than prescribed.

1. **Named stages.** Each pipeline stage should have a name, making the pipeline
   introspectable and its control flow explicit.
2. **A unified input declaration.** One declaration per branch that generates
   the adapter whitelist, the handler's destructuring, and optionally the
   validation constraints — from the same source.
3. **A validation stage driven by IS metadata.** Closing the verification gap
   identified in SEED-DRAFT-editormodels by checking incoming values against
   the IS annotations of the target fields.
4. **Explicit output routing.** A branch's output should declare its destination
   (render to the client, invoke another branch, write to a file, dispatch to
   a remote instance) rather than embedding routing in the handler body.
5. **A transaction boundary.** Branch execution should be wrappable in a
   transaction stage that provides atomic commit/rollback.
6. **Interceptor-style phases.** Following Pedestal's model, stages could have
   enter, leave, and error phases, with the error phase providing cleanup when
   a condition is signalled.
7. **Stages that can be inspected.** A branch should be able to report its
   pipeline: what adapters it uses, what mutation stages are present, what
   handler it runs. This is the input-side counterpart of the self-describing
   metadata on the output side.


## Honest Limits

**The pipeline is proven only for web round-trips.** All existing branches serve
htmx POST requests. The claim that the same pipeline works for terminal input,
gamepad input, or voice commands is architectural, not demonstrated.

**Network-transparent `grow` is speculative.** The interface shape is
compatible, but the serialisation, authentication, error handling, and latency
management required for remote dispatch have not been designed.

**Transaction semantics are absent.** The current system mutates state
destructively with no atomicity. The transaction stage is a candidate, not a
plan.

**The concurrency model is unexamined.** Seed runs as a single-threaded server
(via woo or hunchentoot with serialised handler dispatch). Multi-user portals
will need a concurrency model; the branch pipeline's shape is compatible with
several approaches (per-session locks, per-path optimistic locking, actor-style
mailboxes) but none has been chosen.

**The validation stage does not exist.** The metadata verification gap
identified in SEED-DRAFT-editormodels applies equally to the input side.


## Relationship to Other Work

Within the Seed corpus:

- SEED-DRAFT-tripleontology — the IS/AS/BY ontology and the `:adapting`
  processor pipeline, which is the output-side counterpart of the input-side
  adapter pipeline discussed here.
- SEED-DRAFT-dxontologyupdate — the `(dx)` extension that lets branches
  produce manifestation trees directly.
- SEED-DRAFT-editormodels — the editor-models Eval, whose criterion G2
  (metadata verification) motivates the validation stage proposed here, and
  whose criterion G9 (isolation) motivates the transaction stage.
- SEED-DRAFT-smalltalk — the Smalltalk Eval, whose Seaside rendition describes
  the closest prior art for Seed's server-side component model, and whose
  synthesis recommends a pipeline inspector based on GT's moldable debugger.
- SEED-DRAFT-interfacemodels — the interface-models Survey, whose open question
  SEED-DRAFT-interfacemodels-O1 (inter-domain composition) bears on
  cross-instance branch contact.
- SEED-DRAFT-verticality — the Verticality Survey, whose leverage-pyramid model
  depends on the branch system's ability to serve configurators through derived
  interfaces.


## Open Questions

### SEED-DRAFT-branches-O1 — Should stages be named and introspectable?

Named stages would enable a pipeline inspector, explicit dependency
declarations, and stage-level tracing. The cost is additional structure in the
branch definition. Is the cost justified by the debugging and documentation
value?

### SEED-DRAFT-branches-O2 — Should the adapter/handler contract be unified?

A single input declaration per branch, generating both adapters and
destructuring, would eliminate the duplication between the two. What form should
this declaration take, and should it also generate validation constraints from
IS metadata?

### SEED-DRAFT-branches-O3 — How should branch state ownership work?

Currently `of-state` is a flat key-value store per session. Clipboard and
history branches need their own state, but content branches that call them via
`grow` also need to read that state. Should state be scoped per branch, per
system, or per session? Should branches declare what state they own?

### SEED-DRAFT-branches-O4 — What transaction model fits branches?

CICS uses explicit syncpoints. Erlang/OTP uses process isolation and
supervision. Redux uses immutable state with pure reducers. Which model best
fits branches, given that they currently mutate state destructively and that
Common Lisp's condition system provides restarts?

### SEED-DRAFT-branches-O5 — Should `grow` become network-transparent?

The interface already has the shape of a remote call. What are the minimum
additions (serialisation, authentication, error handling, timeout) needed to
make it work across instances? Is the adapter pipeline sufficient to handle
the normalisation, or does remote dispatch need its own mechanism?
