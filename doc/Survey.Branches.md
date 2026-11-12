---
id:            SEED-DRAFT-branches
title:         "The Branch System: Design Space and Future Directions"
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
  - SEED-DRAFT-interfacemodels
  - SEED-DRAFT-editormodels
  - SEED-DRAFT-smalltalk
  - VOX-DRAFT-vox
cites:
  - title:     "Vox: Declarative Work and Data Exchange Between Lisp Images"
    locator:   "VOX-DRAFT-vox, ~/src/lisp/vox/doc/Survey.Vox.md"
    external:  true
  - title:     "The Psyche Architecture — A Hardware Design Record for a Tagged Lisp Computing System"
    locator:   "~/src/chat/PsycheArchitecture.md, §1.2, §1.3, §5"
    external:  true
  - title:     "Impulse: Interactive Manifold Process-Uniting Lexicon as Symbolic Expressions"
    locator:   "ORIGIN-0006, ORIGIN-0008"
    external:  true
open-questions:
  - SEED-DRAFT-branches-O1
  - SEED-DRAFT-branches-O2
  - SEED-DRAFT-branches-O3
  - SEED-DRAFT-branches-O4
  - SEED-DRAFT-branches-O5
  - SEED-DRAFT-branches-O6
  - SEED-DRAFT-branches-O7
  - SEED-DRAFT-branches-O8
  - SEED-DRAFT-branches-O9
---

# The Branch System: Design Space and Future Directions

This document surveys the design space around Seed's branch system — the
mechanism by which a Seed application receives input, processes it through a
composable pipeline of stages, and produces output for a medium. The branch
system is already implemented and in daily use, but its pipeline architecture
points toward capabilities (a formal stage model, operations with effect
classes, transactional execution, and interlinks between images via Vox) that
are not yet built. This survey explores what those capabilities would look like,
what prior art informs them, and how Vox and Impulse shape the design.


## Motivation

Seed's branch system is the counterpart to its rendering pipeline. On the output
side, `fx` forms are expressed into manifestation trees and rendered through
medium-dispatched `generate` methods — documented in SEED-0003
and SEED-0004. On the input side, branches receive requests,
normalise them through adapter stages, and pass them to handler lambdas that
produce responses.

Together these form two halves of a symmetric design: adapters normalise
heterogeneous input into a uniform plist, and `generate` methods specialise
uniform manifestation trees into medium-specific output. The branch sits between
them. Understanding its design space is necessary for determining how
operations, effects, transactions, and inter-image communication should work.

The Vox Survey (VOX-DRAFT-vox) names Seed as Vox's first consumer and the
branch system as the point of integration. This document records the Seed side
of that integration.


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

### Adapters as input-format normalisation

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

Note: adapters are keyed by format, not by medium. The same JSON format could
arrive from a browser, a remote server, or a CLI tool. This is deliberate and
differs from the output side, where `generate` dispatches on medium.

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
(SEED-0003, decision SEED-D16) lets the
branch supply lambdas that adapt the expressed tree before rendering. This
creates a second pipeline on the output side: the branch builds a tree, named
processors modify it, Tier-1 modality defaults add affordances, and `generate`
renders it.


## The Stage Model: Decode / Act / Encode

The current pipeline mixes decoding, mutation, and output generation in a flat
chain of lambdas. The proposed model draws two hard lines:

Table: The three phases and what each converts.

| Phase | Converts | Example |
|---|---|---|
| **Decode** | External representation → Lisp data | JSON → plist; Vox Datum → plist; alist → plist |
| **Act** | Lisp → Lisp only; effects are queued, not performed | Validate, edit state, build a manifestation tree |
| **Encode** | Lisp → a chosen representation | Render HTML; encode JSON; encode Vox Datum; return plain Lisp |

Three consequences follow:

1. **The modulate2 pipeline splits along the same line.** A manifestation tree is
   ordinary Lisp data, so `construct`, `express-new` and the `:adapting`
   processors belong to Act. `generate`/`render` belongs to Encode. Tier-1
   modality defaults straddle the line (they are tree-to-tree transforms but need
   the medium) and sit at the front of Encode, which is where they already run.
2. **The caller, not the handler, chooses the encoding.** A browser request gets
   rendered HTML. A `grow` from another branch gets the plain Lisp value. A call
   through a Vox interlink gets the Vox Datum encoding. Act never knows who is
   asking. This finishes what the adapters began on the input side.
3. **Decoders are keyed by format, encoders by medium or format.** On input, the
   payload's format (JSON, alist, Vox Datum) is independent of the medium, so
   decode stages are keyed by format. On output, interface rendering depends on
   the medium (`generate`), while data encoding depends on format. One exception:
   interactive gestures (keyboard, gamepad, touch) are tied to the medium and
   may need their own normaliser, which the navigational-model document (planned
   separately) would specify.

Old lambdas that mix decode, act, and encode are wrapped in a `function-stage`
during migration. The second-value short-circuit is supported only during
migration and is retired once existing branches are converted.


## Operations Within a Branch

The current short-circuit mechanism hides three different jobs: choosing an
operation, answering a different question (e.g. `uimod` header/footer
controls), and answering early. These are dispatch decisions hidden in a linear
chain.

The proposed model replaces short-circuiting with **named operations**. After
decoding, a dispatch step selects an operation by inspecting the decoded input.
Each operation has:

- a **name** (a keyword);
- a **declared input spec** (generating both the decode whitelist and the
  handler's destructuring from one source);
- an **effect class**, borrowed from Impulse's effect ladder:

Table: Effect classes and their consequences.

| Effect class | Meaning | Effect queue | Retryable | History records it |
|---|---|---|---|---|
| **safe** | Changes nothing | Not needed | Yes | No |
| **idempotent** | Changes state, but repeating gives the same result | Needed | Yes, after failure | Optional |
| **effecting** | Each call accumulates or is irreversible | Needed | No | Yes |

Operations end with one of three explicit signals:
- **`answer`** — stop and respond with the act phase's result;
- **`transfer`** — hand the context to another branch or operation (the CICS
  `XCTL` analogue, and the explicit form of the user's idea that short-circuits
  should redirect to their own branch);
- **`fail`** — signal a condition.

The `uimod` case — asking a branch for its header or footer controls — would
likely become metadata on the branch or an `:adapting` processor, rather than
a distinct operation.

### A mandatory `describe`

Every branch answers a `describe` operation: its name, its operations, their
input specs and their effect classes. This is borrowed from Impulse's mandatory,
free `describe` (ORIGIN-0006), and it closes the introspection gap the
branch-models Eval identified (criterion B9). The `describe` output is itself a
Datum-encodable plist, so it can be served to any caller.


## Effects and Transactions

### Effects as queued words

In the current system, branches perform effects (writing files through Philo,
calling other branches, mutating `of-state`) directly during act. This makes
rollback impossible: a condition signalled after a file write cannot undo the
write.

The proposed model separates the decision from the execution. During act,
effects are **queued as descriptors** — Lisp data shaped like Vox words: each
names an operation, a target, and parameters. They are carried out only after
the act phase completes without error. On failure, the queue is discarded.

This is the CICS syncpoint model expressed as declarative I/O: effects are
channel command words that the executor submits at commit. It is also a direct
application of the Psyche architecture's principle that Vox words describe
work semantically, not mechanically (cited, §5). Inside one image, the executor
is a function that runs the queued effects in order. Once Vox exists, the
executor submits them as Vox words to the appropriate carrier.

### Transactions

A `with-transaction` stage snapshots `of-state` on entry. If the act phase
succeeds, the effect queue is executed. If the act phase fails (a condition is
signalled), the snapshot is restored and the queue is discarded. Common Lisp's
condition system with restarts provides the mechanism: the transaction stage
establishes a restart that rolls back state.

The effect-queue model makes transactions considerably simpler than they
appeared in the earlier ranking, because the only mutable state that needs
rollback is `of-state` (which is a plist, cheap to snapshot). File writes and
remote calls, being queued effects, never happen if the act phase fails.


## The Input Side of Medium Independence

The adapter pipeline and the rendering pipeline form a symmetric pair:

Table: Symmetric normalisation on input and specialisation on output.

| Side | Raw form | Normalisation | Handler sees | Specialisation | Final form |
|------|----------|---------------|-------------|---------------|------------|
| Input | JSON, alist, or Vox Datum | Decode stages | Keyword plist | — | — |
| Output | — | — | Manifestation tree | Encode / `generate` per medium | HTML, Vox, etc. |

Adding a new **input** format (a terminal command parser, a gamepad event
stream, a voice-command transcriber) requires only a new decode stage. Adding a
new **output** medium requires `generate` methods for a new `uim-*` class. The
branch handler is medium-independent on both sides.


## Write-Time Operations as Stages

### Current stages

`fx-path-access` and `form-sort` are the two existing generic stages. Both
operate on `fx`-annotated data using the metadata to guide their behaviour.
They are the input-side counterparts of the roles that guide output-side
rendering.

### A validation stage

The editor-models Eval (SEED-DRAFT-editormodels, criterion G2) identified
Seed's most significant gap: metadata is asserted, not checked. A validation
stage in the decode phase could close this gap on the input side:

- Read the IS metadata of the target field.
- Check the incoming value against the declared type.
- Reject or coerce invalid input before it reaches act.

This would be a generic stage working on any `fx`-annotated data, and it would
serve the same purpose as Magritte's checked descriptions (SEED-DRAFT-smalltalk).


## Branch-to-Branch Patterns

### Clipboard and history as stages

A `with-history` stage intercepts the pipeline before mutations:
- On normal input: snapshot the current state, push onto a history stack in
  session state, pass input through.
- On `:undo`: pop the stack, restore previous state, answer.
- On `:redo`: move forward in the stack, restore, answer.

A `with-clipboard` stage:
- On `:copy`: store the current selection by path, answer.
- On `:cut`: store, transfer to a `:remove` operation.
- On `:paste`: inject clipboard contents at the specified path.

Both stages are generic — they snapshot and restore S-expression trees without
interpreting their content.

### Clipboard and history as branches

The alternative is independent branches with their own state and decode
pipelines. As branches, they:
- Have their own session-scoped state.
- Can be invoked by multiple content branches via `grow`.
- Can be rendered (showing clipboard contents or a history timeline).

Content branches invoke them via `grow`:

```lisp
(grow *system* :clipboard session (list :action :copy :data selected-entity))
```

### The two approaches compose

Stages work best when clipboard or history is **local to one branch's data**.
Branches work best when clipboard or history is **shared across multiple
branches or systems**. A stage can delegate to a clipboard branch via `grow`.


## Interlinks via Vox

The following sections describe capabilities that are **not yet built** and are
architectural directions informed by the Vox Survey (VOX-DRAFT-vox).

### `grow` over Vox

`grow` dispatches to a local branch or, through a configuration table, submits a
Vox word to the image serving the branch. The Vox word carries:
- the target system and branch as its operation and target fields;
- the decoded plist as a Datum payload;
- a completion target for the result.

Handlers do not change. The decode stage on the receiving side validates the
payload, which is already Lisp data (a Datum payload's content is the plist a
local adapter would have produced), and passes it to act.

### Payload profiles and what crosses the wire

Vox defines nested payload profiles (VOX-DRAFT-vox, "Payload profiles"):

- **Datum** — numbers, characters, strings, keywords, registered symbols, `T`,
  `NIL`, proper lists, general vectors. Trees only: no cycles, no shared
  structure. This carries Seed's normalised plists and is the default.
- **Arrays** — adds specialised arrays as raw blocks with a typed header.
- **Instances** — class name, version and slot values, reconstructed only by a
  decoder the receiving image has registered.
- **Never** — closures, streams, and anything local to one image.

The usual case is sending the `fx`/`dx` data as Datum and rebuilding the
manifestation on the receiving side. If manifestation instances must travel, a
registered decoder can rebuild them through `construct` — the safe use of the
Instances profile.

**The bitmap example.** A branch that produces a bitmap image:
- Inside one image: returns the data describing the image as Lisp data; the
  caller renders it.
- On one host: writes the pixels into an exchange buffer (a flat region
  named by reference in the Vox word, never serialised).
- Between hosts: the pixel array travels under the Arrays profile.

### Completions and conditions

A Vox word's outcome is a completion: a status, a result payload, and on
failure the detail of what failed. Failure is delivered as a Common Lisp
condition with restarts — `retry-submission`, `use-partial-result`, `abort` —
so failures reach the condition system with no further code (VOX-DRAFT-vox,
"Completions").

### The event log

Normalised input recorded as canonical Datum encoding is deterministic, compact,
and replayable. Each log entry includes the branch key, session identifier,
timestamp, and the decoded plist. The Vox encoding's canonical bytes make the
log hashable and diffable.

### Copy semantics within one image

A Vox payload between images is a copy. Within one image, data shares structure
with the sender. Since branches mutate data destructively (with `rplacd`), a
receiving branch could silently corrupt the caller's data in-image where a
remote call never would. The in-image carrier should therefore copy payloads, or
the protocol should declare them immutable. Copying is cheap at branch-payload
sizes and keeps the semantics identical regardless of carrier.

### Build stages

Following the Vox Survey's staged path:

1. **Within one image** — an abstract CLOS protocol and in-process queues, built
   as the first stage of the Vox library itself (in the vox repository). Seed
   depends on Vox; a Seed-only imitation would have to be thrown away later.
   Payloads are validated against the Datum profile even though nothing is
   encoded, to catch closures, cycles, or unbounded depth early.
2. **Shared memory between images on one host** — queue pairs and exchange
   buffers in a shared region.
3. **Sockets between hosts** — TCP, with the same framing as Impulse.
4. **A Vox controller simulator** — the bridge to Psyche hardware.


## Relation to Impulse

Impulse is Origin's control vocabulary: verbs, selectors, and their semantics
(ORIGIN-0006, ORIGIN-0008). Vox is an envelope and a transport. The two stay
separate, following the coupling rule from the Psyche OS: Vox must not absorb
Impulse's verbs, and Impulse must not depend on Vox's carriers. Seed does not
adopt Impulse's verbs either.

What Seed **borrows from Impulse's structure** (not its vocabulary):

Table: Structural borrowings from Impulse.

| From Impulse | In Seed |
|---|---|
| Envelope fields: `:op`, `:target`, `:args`, `:id`, `:delivery` | The payload of a branch call: the operation name, the branch, the decoded plist, a correlation id, and sync/async delivery |
| The effect ladder: safe / idempotent / effecting | Each branch operation declares its effect class |
| A mandatory, free `describe` | Every branch answers `describe` |
| Two tiers: universal verbs + typed sub-vocabulary | A small universal set (`describe`) + each branch's own operations |
| A version/capability handshake | Agreement on the IS/AS/BY vocabulary between Seed instances |

The structured response envelope (success, error, partial) is already a **Vox
completion** and does not need to be borrowed separately.

Separately, a running Seed instance could be an Origin orbital managed with
Impulse verbs (`start`, `status`, `apply`). That is Origin's concern, not the
branches'.


## Tensions in the Current Design

The following are known rough edges, flagged to inform future Plans.

1. **Stage macros capture bare symbols.** `fx-path-access` and `form-sort`
   generate lambdas whose parameters must match the names `state` and `input`.
   A more robust design passes context through explicit arguments.

2. **The adapter whitelist and the handler's destructuring are duplicated.** A
   unified input declaration would generate both, and the operation's declared
   input spec would be that declaration.

3. **Multiple lambdas with short-circuiting are opaque.** Named operations with
   explicit `answer`/`transfer`/`fail` endings replace the short-circuit
   mechanism.

4. **Hard-coded state keys.** `fx-path-access` takes a macro-injected accessor
   rather than an explicit argument.

5. **Closure state shared across sessions.** Some branches close over lexical
   variables outside the handler lambda. This state is per system, not per
   session, which is a concurrency hazard.

6. **The `*SYSTEM*` dependency at expansion time.** The `branch` macro reads a
   special variable at macro-expansion time.

7. **No defined behaviour when a stage signals an error.** An interceptor model
   with enter/leave/error phases would address this.

8. **Stages have no names and cannot be inspected.** A mandatory `describe`
   operation reporting a branch's stages, operations, and effect classes would
   close this gap.

9. **The adapter whitelist is not a complete security boundary.**
   `adapt-from-json` passes through any input that is not a string.

10. **In-image `grow` shares structure, but remote `grow` would copy.** This
    semantic difference could cause bugs that appear only at deployment. The
    in-image carrier should copy payloads.


## Candidate Design Principles

1. **Named stages.** Each pipeline stage has a name, making the pipeline
   introspectable and its control flow explicit.
2. **A unified input declaration per operation.** One declaration generates the
   decode whitelist, the handler's destructuring, and the validation constraints.
3. **A validation stage driven by IS metadata.** Closing the verification gap
   (SEED-DRAFT-editormodels, G2) on the input side.
4. **The caller chooses the encoding.** Act returns Lisp data; encode turns it
   into the representation the caller needs.
5. **Effects as queued words.** Act queues effects as descriptors; they execute
   after commit and are discarded on rollback.
6. **A transaction boundary.** `with-transaction` snapshots state and either
   commits (submitting the effect queue) or rolls back.
7. **Each operation declares its effect class.** Safe, idempotent, or effecting.
   The effect class governs the effect queue, retry policy, and history.
8. **A mandatory `describe`.** Every branch reports its operations, input specs,
   and effect classes.
9. **Interlinks use Vox.** `grow` submits a Vox word; payloads are Datum; results
   are completions with conditions and restarts.
10. **Copy semantics for payloads.** In-image and remote calls have the same
    semantics.


## Honest Limits

**The pipeline is proven only for web round-trips.** All existing branches serve
htmx POST requests. The claim that the same pipeline works for terminal input,
gamepad input, or voice commands is architectural, not demonstrated.

**Vox does not exist yet as running code.** The in-image stage is the first
piece to build, in the vox repository. Until it exists, the stage model and
interlink design are validated only by the Vox Survey's analysis.

**Transaction semantics are absent.** The current system mutates state
destructively with no atomicity.

**The concurrency model is unexamined.** Multi-user portals will need a
concurrency model; none has been chosen.

**The validation stage does not exist.** The metadata verification gap applies
equally to the input side.

**Effect classes are not yet assigned to existing operations.** The
classification is a design intention, not a constraint enforced by the system.

**Copy semantics for in-image payloads are not yet enforced.** The hazard of
shared-structure mutation exists in the running code.


## Relationship to Other Work

Within the Seed corpus:

- SEED-0003 — the IS/AS/BY ontology and the `:adapting`
  processor pipeline, which is the output-side counterpart of the input-side
  adapter pipeline.
- SEED-0004 — the `(dx)` extension that lets branches
  produce manifestation trees directly.
- SEED-DRAFT-editormodels — the editor-models Eval, whose criterion G2
  (metadata verification) motivates the validation stage, and whose criterion G9
  (isolation) motivates the transaction stage.
- SEED-DRAFT-smalltalk — the Smalltalk Eval, whose Seaside rendition describes
  the closest prior art for Seed's server-side component model, and whose
  synthesis recommends a pipeline inspector based on GT's moldable debugger.
- SEED-DRAFT-interfacemodels — the interface-models Survey, whose open question
  SEED-DRAFT-interfacemodels-O1 (inter-domain composition) bears on
  cross-instance branch contact and on whether IS/AS/BY can serve as a shared
  vocabulary between Seed instances.
- SEED-DRAFT-verticality — the Verticality Survey, whose leverage-pyramid model
  depends on the branch system's ability to serve configurators through derived
  interfaces.

External:

- VOX-DRAFT-vox — the Vox Survey, which names Seed as Vox's first consumer and
  specifies the payload profiles, encoding, carriers, completions, and security
  model that interlinks would use.
- ORIGIN-0006 and ORIGIN-0008 — the Impulse logs, from which the effect ladder,
  the envelope structure, and the mandatory `describe` are borrowed.
- The Psyche architecture record (cited) — the source of the Vox model, the
  centrifugal derivation methodology, and the principle that serialization is
  the redundant mechanism to derive into shared infrastructure.


## Open Questions

### SEED-DRAFT-branches-O1 — Should stages be named and introspectable?

Named stages enable a pipeline inspector, explicit dependency declarations, and
stage-level tracing. Direction: yes, and `describe` reports them.

### SEED-DRAFT-branches-O2 — Should the adapter/handler contract be unified?

A single input declaration per operation, generating decode whitelist,
destructuring, and validation constraints. Direction: yes, as part of the
operation's declared input spec.

### SEED-DRAFT-branches-O3 — How should branch state ownership work?

Currently `of-state` is a flat key-value store per session. Clipboard and
history branches need their own state. Should state be scoped per branch, per
system, or per session? Should branches declare what state they own?

### SEED-DRAFT-branches-O4 — What transaction model fits branches?

Direction: the effect-queue model with `with-transaction` snapshotting state.
The effect queue is a list of word-shaped descriptors submitted at commit. The
remaining question is what happens when an effect fails during execution, after
act has already committed.

### SEED-DRAFT-branches-O5 — How should `grow` dispatch across images?

Direction: `grow` submits a Vox word to the Vox carrier that reaches the target
image. The in-image carrier is the first stage, built in the vox repository.
The remaining questions are session identity across images, authentication,
timeouts, and vocabulary versioning.

### SEED-DRAFT-branches-O6 — What are the rules for effect classes?

Each operation declares safe, idempotent, or effecting. Safe operations need no
effect queue and can be retried freely. Effecting operations need the queue and
must never be retried automatically. What governs the classification, and can
the system enforce it?

### SEED-DRAFT-branches-O7 — Should manifestations ever cross as Instances?

The usual case is sending `fx`/`dx` data as Datum and rebuilding. The Instances
profile with a registered decoder through `construct` is the alternative. When
is the alternative justified, and what versioning rules apply?

### SEED-DRAFT-branches-O8 — How does `describe` relate to IS/AS/BY?

A branch's `describe` output reports operations, input specs, and effect
classes. The input spec could use IS annotations for types. How far should
`describe`'s schema lean on the IS/AS/BY vocabulary?

### SEED-DRAFT-branches-O9 — How should the in-image effect executor work before Vox exists?

During the transition, effects are Lisp data shaped like Vox words, run by an
in-image executor. Should the executor be a thin function that dispatches on the
effect's operation, or should it already implement the Vox carrier protocol so
that the switch to real Vox changes only the carrier?
