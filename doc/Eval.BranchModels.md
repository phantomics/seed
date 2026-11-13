---
id:            SEED-DRAFT-branchmodels
title:         "Branch Pipeline Models: Transaction Monitors, Middleware, Actors, and Reducers as Prior Art"
genre:         Eval
subtype:       prior-art
scope:         project
project:       Seed
language:      en
status:        Draft
provenance:
  assistant:   claude-opus-5-5
relates-to:
  - SEED-0009
  - SEED-0003
  - SEED-0006
  - SEED-0008
cites:
  - title:     "CICS Transaction Server for z/OS Documentation"
    locator:   "IBM, https://www.ibm.com/docs/en/cics-ts/6.x"
    external:  true
  - title:     "What Is an Interceptor?"
    locator:   "Pedestal documentation, https://pedestal.io/pedestal/0.7/guides/what-is-an-interceptor.html"
    external:  true
  - title:     "Ring specification"
    locator:   "Ring project, https://github.com/ring-clojure/ring"
    external:  true
  - title:     "Making Reliable Distributed Systems in the Presence of Software Errors"
    locator:   "Armstrong, J. PhD thesis, Royal Institute of Technology, Stockholm, 2003"
    external:  true
  - title:     "Phoenix LiveView documentation"
    locator:   "https://hexdocs.pm/phoenix_live_view/"
    external:  true
  - title:     "The Elm Architecture"
    locator:   "https://guide.elm-lang.org/architecture/"
    external:  true
---

# Branch Pipeline Models: Transaction Monitors, Middleware, Actors, and Reducers as Prior Art

This evaluation examines five families of request-processing architectures as
prior art for Seed's branch system. The purpose is to learn what each family has
proven about composable pipelines, state management, failure handling, and
distributed dispatch — and what Seed should adopt, adapt, or reject.

A Seed branch combines five things: a named handler, composable middleware
stages, session-scoped state, calls to other branches, and server-rendered
responses. No single prior-art system provides all five, but each family
excels at one or two. The evaluation scores them against a rubric designed for
branch-like processing units, then scores Seed against the same rubric.

The branch system's design space and tensions are documented in the companion
Survey (SEED-0009); this Eval assumes that document as context.


## Method

Evidence is drawn from published documentation and specifications, cited in the
front-matter. No hands-on benchmarks or user studies were conducted. Seed is
assessed at revision `31067ad`.

The stance is **learning from prior art**. Each rendition ends with what to
steal and what to reject.


## The Shared Scenario

Each system is walked through six tasks.

**S1 — Edit a chart entity in one request round trip.** Receive a request with
a field value and a path, parse the input, validate the type, mutate the target
field, and render the updated interface.

**S2 — Undo and redo.** Reverse the mutation from S1, then re-apply it.

**S3 — A shared clipboard between two editors.** Copy a chart entity from one
editor, paste it into another.

**S4 — Call a handler on a remote instance.** Invoke a branch on a different
Seed server (or a different CICS region, Erlang node, etc.) and receive the
result.

**S5 — A failure partway through the pipeline, and rollback.** A mutation stage
signals an error after partial state modification. Roll back to the state before
the request.

**S6 — Add a new input source.** Accept input from a terminal or a gamepad
rather than from an htmx POST, without changing the handler.


## The Rubric

Table: Evaluation criteria B1–B10.

| Code | Criterion | What "strong" means |
|------|-----------|-------------------|
| B1 | Unit of dispatch | Named, addressable, independently deployable |
| B2 | Input contract | Declared, validated, transport-independent |
| B3 | Stage composition | Composable, named, with early termination and error phases |
| B4 | State model | Scoped, isolated, safe under concurrency |
| B5 | Inter-unit calls | Location-transparent, with failure semantics |
| B6 | Transactional integrity | Atomic commit/rollback for a unit of work |
| B7 | Failure handling | Supervision, restarts, or compensation |
| B8 | Response generation | The unit produces an interface, not just data |
| B9 | Introspection | The pipeline can be listed, traced, and debugged |
| B10 | Deployment and scale | Proven at production scale, multi-instance |


## Rendition: IBM CICS

CICS (Customer Information Control System) has run transaction processing on
IBM mainframes since 1969. A CICS region hosts named transactions, each
dispatched to a program that processes input, accesses shared resources, and
produces a response — typically a terminal screen defined by a BMS map.

**B1 — Unit of dispatch: the transaction.**
A CICS transaction is identified by a four-character transaction ID. When a
user types the ID (or an application issues `EXEC CICS START`), CICS loads and
dispatches the associated program. Transactions are named, addressable, and can
be distributed across CICS regions via inter-region communication (MRO) or
inter-system communication (ISC).

IMS Transaction Manager (IMS TM), the other major IBM TP monitor, dispatches
message-driven transactions against a hierarchical database. Oracle Tuxedo
dispatches named services with typed buffers (FML — Field Manipulation
Language), where each buffer field is named and typed, closely resembling
Seed's adapter whitelists.

**B2 — Input contract: COMMAREA and channels.**
Data is passed between programs via a COMMAREA (a flat byte buffer with a known
layout, defined by a COBOL copybook) or via channels and containers (named data
blocks that can carry structured data). The COMMAREA layout is a compile-time
contract; channels are more flexible. Tuxedo's FML buffers are the closest
analogue to Seed's keyword plists: named, typed fields that the service
declares.

**B3 — Stage composition: LINK and XCTL.**
`EXEC CICS LINK` calls a subprogram and returns. `EXEC CICS XCTL` transfers
control to another program at the same level (no return). These are the CICS
equivalents of `grow` (LINK) and a hypothetical tail-call dispatch (XCTL).
Programs chain, but there is no middleware pipeline — each program is a
monolithic handler. Composition is by calling subprograms, not by wrapping
stages.

**B4 — State model: transaction-scoped, with shared resources.**
Each transaction runs in its own task, with its own working storage. Shared
resources (files, queues, temporary storage) are accessed through CICS APIs
with record-level locking. The state model is well-defined and
concurrency-safe.

**B5 — Inter-unit calls: location-transparent.**
MRO (Multi-Region Operation) and ISC (Inter-System Communication, via APPC/LU
6.2) let a transaction LINK to a program in another CICS region, on the same
machine or across a network. The calling program does not know (or need to
know) where the target runs. This is the gold standard for location-transparent
dispatch, proven over decades.

**B6 — Transactional integrity: syncpoint.**
CICS provides `EXEC CICS SYNCPOINT` for explicit commit and
`EXEC CICS SYNCPOINT ROLLBACK` for rollback. A unit of work (UOW) encompasses
all resource modifications between syncpoints. If a transaction abends, CICS
rolls back all modifications in the current UOW. This is the strongest
transactional model in this evaluation.

**B7 — Failure handling: abend handling and restart.**
`EXEC CICS HANDLE ABEND` lets a program intercept failures and take corrective
action. CICS regions are monitored and restarted by the operating system. The
model is industrial-grade but coarse: an abend rolls back the entire UOW, not
a single stage.

**B8 — Response generation: BMS maps.**
BMS (Basic Mapping Support) maps define terminal screen layouts declaratively,
separate from program logic. The system derives the terminal display from the
map definition. This is the mainframe analogue of `fx` metadata: a declarative
interface specification that the system renders. However, BMS maps are static
(defined at system generation time), not derived from the data at runtime.

**B9 — Introspection: CEMT and CICS Explorer.**
CICS provides the CEMT transaction for querying and modifying the running
system, and CICS Explorer (an Eclipse-based GUI) for monitoring transactions,
programs, files, and resources. The introspection is operations-focused rather
than development-focused — you can see what's running, but you can't inspect a
pipeline stage by stage.

**B10 — Deployment and scale: proven at the highest scale.**
CICS runs a significant fraction of the world's transaction processing. CICS
regions cluster into CICSPlexes managed by CICSPlex SM. This is the most
production-proven system in the evaluation.

**Steal:** Syncpoint and rollback — Seed's branches need atomic mutation
semantics. Location-transparent LINK — the model for a network-transparent
`grow`. BMS maps as precedent for declarative interface specifications.
Channels and containers as a more flexible alternative to the flat COMMAREA.

**Reject:** The COBOL-era programming model (copybook-defined data layouts,
procedural programs). The monolithic handler — CICS programs are not composed
of middleware stages. The static nature of BMS maps — Seed's `fx` metadata
is derived at runtime.


## Rendition: Ring and Pedestal (Clojure Middleware)

Ring (Clojure) defines a web handler as a function from a request map to a
response map. Middleware wraps a handler, transforming request or response.
Pedestal extends this with an interceptor model.

**B1 — Unit of dispatch: the handler function.**
A Ring handler is `(fn [request] response)`. Routing maps URLs to handlers.
The unit is a function, not a named persistent entity.

**B2 — Input contract: the request map.**
Ring's request map is a Clojure map with well-defined keys (`:uri`,
`:request-method`, `:headers`, `:body`, `:params`). Middleware like
`wrap-json-body` parses JSON into the `:body` key. This is close to Seed's
adapter normalisation, but without a whitelist — the full parsed input is
available to the handler.

**B3 — Stage composition: wrapping (Ring) / interceptors (Pedestal).**
Ring middleware wraps a handler: `(wrap-json-body (wrap-params handler))`.
Each wrapper transforms the request before passing it inward, then transforms
the response on the way out. This is concentric — the outermost middleware
runs first on the request and last on the response.

Pedestal replaces wrapping with an **interceptor chain**. An interceptor is a
map with `:name`, `:enter`, `:leave`, and `:error` keys. The `:enter` functions
run in order; the `:leave` functions run in reverse order; and if any stage
throws, the `:error` functions run in reverse from the point of failure. A
stage can **terminate** the chain by removing the remaining interceptors from
the context.

Pedestal's interceptor model is the closest match to Seed's pipeline:
- `:enter` corresponds to an adapter or handler stage.
- The terminate operation corresponds to the short-circuit second value.
- `:error` provides the cleanup phase that Seed's pipeline lacks.
- `:leave` provides a response-transformation phase with no Seed counterpart.

Elixir's Plug has a `halt` function that stops the pipeline, directly
analogous to Seed's `(values result t)`.

Common Lisp's Lack (the foundation of Clack and ningle, which Seed's HTTP layer
uses) follows the Ring model: middleware wraps a handler function.

**B4 — State model: the context map (Pedestal) / the request map (Ring).**
State flows through the pipeline as the request/context map. There is no
separate session store in the core; session middleware adds one. The model is
functional and stateless by default — each request is independent.

**B5 — Inter-unit calls: not built-in.**
Ring and Pedestal do not provide inter-handler calls or location transparency.
Handlers are functions, not addressable services.

**B6 — Transactional integrity: not built-in.**
Neither Ring nor Pedestal provides transactions. The application manages its
own database transactions.

**B7 — Failure handling: Pedestal's `:error` phase.**
Pedestal interceptors can have `:error` functions that run when a preceding
interceptor throws. This is the most developed failure-handling model among the
middleware systems. Ring has no built-in error handling beyond Clojure's
try/catch.

**B8 — Response generation: application-specific.**
Neither Ring nor Pedestal generates interfaces from metadata. The handler
constructs the response body (HTML, JSON, etc.) explicitly.

**B9 — Introspection: Pedestal names its interceptors.**
Pedestal requires each interceptor to have a `:name`. The interceptor chain
can be listed, and interceptors can be reordered or removed by name before
execution. This is the model for Seed's proposed named stages.

**B10 — Deployment and scale: production-grade.**
Ring and Pedestal are used in production Clojure applications. They are
single-process; horizontal scaling uses conventional load balancing.

**Steal:** Pedestal's interceptor model with enter/leave/error phases. Named
interceptors. The terminate operation. The context map as explicit pipeline
state. Plug's `halt` as validation of the short-circuit pattern.

**Reject:** The concentric wrapping model of Ring — Seed's linear pipeline is
more transparent. The absence of inter-handler calls and location transparency.


## Rendition: Erlang/OTP

Erlang/OTP's `gen_server` is a named process with its own state that handles
synchronous calls and asynchronous casts. Processes are supervised, restarted
on failure, and transparently addressable across nodes.

**B1 — Unit of dispatch: the process.**
A `gen_server` is identified by a registered name or a process identifier (pid).
It is independently running, independently failing, and independently
restartable.

**B2 — Input contract: the message.**
Messages are arbitrary Erlang terms, typically tuples. The `handle_call/3` and
`handle_cast/2` callbacks pattern-match on the message to dispatch. There is no
formal input contract beyond the callback's pattern clauses.

**B3 — Stage composition: not built-in at the process level.**
Each `gen_server` is a monolithic handler. Composition happens by sending
messages between processes, not by wrapping stages within a process. Pipeline
composition is built at the application level, not provided by OTP.

**B4 — State model: process-isolated.**
Each process owns its state. No other process can access it directly. State is
passed through the callback chain as the `State` argument to `handle_call/3`
and returned as the new state. This is the strongest isolation model in the
evaluation.

**B5 — Inter-unit calls: location-transparent.**
`gen_server:call(Name, Request)` works identically whether `Name` is a local
process or a process on a remote node. The BEAM VM's distribution protocol
handles serialisation, routing, and failure detection transparently. This is
the most natural model for a network-transparent `grow`.

**B6 — Transactional integrity: not built-in.**
Erlang processes do not provide database-style transactions. Atomicity is
achieved through process isolation (a crash rolls back the process's state to
its last known-good value) and through let-it-crash supervision (a crashed
process is restarted from a clean state).

**B7 — Failure handling: supervision trees.**
Supervisors monitor worker processes and restart them according to a declared
strategy (one-for-one, one-for-all, rest-for-one). This is the most
sophisticated failure-handling model in the evaluation. A crashed `gen_server`
is restarted with fresh state; the supervisor decides whether to escalate.

**B8 — Response generation: application-specific.**
OTP does not generate interfaces. The process constructs its response
explicitly.

**B9 — Introspection: observer and tracing.**
Erlang's Observer application shows running processes, their state, message
queues, and supervision trees. The tracing facility (`dbg`, `recon_trace`) can
trace any function call on any process. This is strong runtime introspection.

**B10 — Deployment and scale: proven at massive scale.**
Erlang/OTP runs telecoms, messaging systems (WhatsApp), and databases
(CouchDB, Riak). Clusters of Erlang nodes communicate transparently.

**Steal:** Location-transparent dispatch — the model for network-transparent
`grow`. Supervision trees — the model for branch failure handling. Process
isolation — the model for per-branch state ownership. Let-it-crash as a design
philosophy. Observer and tracing as a model for pipeline introspection.

**Reject:** The absence of middleware-style stage composition within a process.
Message-based input without a formal contract — Seed's adapter whitelists are
more explicit.


## Rendition: Phoenix LiveView

Phoenix LiveView (Elixir) renders server-side HTML, pushes diffs to the client
over a WebSocket, and handles events with server-side callbacks. It is the
closest architectural match to Seed's branch + htmx model.

**B1 — Unit of dispatch: the LiveView module.**
A LiveView is an Elixir module that implements `mount/3`, `render/1`, and
`handle_event/3`. It is identified by its route. Each connected client gets
its own LiveView process (an Erlang process), with its own state (`assigns`
on the `socket`).

**B2 — Input contract: the event and params.**
`handle_event(event, params, socket)` receives a string event name and a map
of parameters from the client. The params come from form data or phx-value
attributes on the HTML element. This is close to Seed's `(lambda (state input)
...)` with destructured keyword input.

**B3 — Stage composition: lifecycle callbacks, not middleware.**
LiveView has lifecycle callbacks (`mount`, `handle_event`, `handle_info`,
`handle_params`) but no middleware pipeline. Plugs (Elixir's middleware) run
in the HTTP pipeline before the WebSocket upgrade, not within the LiveView
event loop.

**B4 — State model: per-connection process state.**
Each client connection gets its own Erlang process. State is stored in the
socket's `assigns` — a key-value map analogous to `of-state`. The state is
process-isolated and connection-scoped.

**B5 — Inter-unit calls: via PubSub.**
LiveViews communicate by broadcasting messages through Phoenix PubSub. A
LiveView subscribes to a topic and receives messages via `handle_info/2`. This
is not location-transparent in the OTP sense, but it supports multi-node
clusters through a distributed PubSub backend.

**B6 — Transactional integrity: via Ecto.**
LiveView itself has no transaction semantics. Database transactions are managed
by Ecto (the Elixir database library) within the event handler.

**B7 — Failure handling: process crash + reconnect.**
If a LiveView process crashes, the client reconnects and `mount/3` runs again,
restoring state from the database or from URL parameters. The recovery is
automatic but loses in-memory state.

**B8 — Response generation: server-rendered HTML diffs.**
LiveView renders HTML on the server using HEEx templates, diffs the new
rendering against the previous one, and sends only the changes to the client.
This is the closest prior art to Seed's server-rendered htmx model: both keep
rendering on the server, both send partial updates to the client, and both
avoid client-side framework code.

**B9 — Introspection: LiveDashboard.**
Phoenix LiveDashboard provides real-time monitoring of processes, Ecto queries,
and LiveView connections. It is the LiveView equivalent of CICS's CEMT.

**B10 — Deployment and scale: production-grade.**
Phoenix/LiveView is used in production by companies including Fly.io (the
company behind much of its development). Multi-node deployment uses distributed
PubSub.

**Steal:** Server-rendered diffs — the validation that Seed's server-rendered
model scales. Per-connection process isolation. PubSub for inter-view
communication. LiveDashboard for operations monitoring. The crash-and-reconnect
recovery model.

**Reject:** The absence of a middleware pipeline within the LiveView event loop
— Seed's adapter stages are more composable. Template-based rendering — Seed
derives interfaces from metadata rather than writing templates.


## Rendition: Redux and the Elm Architecture

Redux (JavaScript) and the Elm Architecture (Elm) model application state as a
value transformed by a pure reducer function: `(state, action) → state`. This
is the branch's `(state input) → output` signature reduced to its essence.

**B1 — Unit of dispatch: the action.**
Actions are plain objects with a `type` field (Redux) or tagged union values
(Elm). The reducer pattern-matches on the type. The unit of dispatch is the
action, not the handler — any reducer can handle any action.

**B2 — Input contract: the action type.**
Elm's message types are algebraic data types — the compiler checks that every
possible message is handled. This is the strongest input contract in the
evaluation: a missing case is a compile-time error. Redux actions are
untyped objects; TypeScript adds optional type safety.

**B3 — Stage composition: middleware (Redux) / commands and subscriptions (Elm).**
Redux middleware intercepts actions before they reach the reducer. `redux-thunk`
handles asynchronous actions; `redux-undo` wraps a reducer to add undo/redo.
This is the closest match to Seed's pipeline stages for history:

```javascript
undoable(reducer) // wraps the reducer with undo/redo handling
```

Elm separates effects from state updates: the `update` function returns both a
new model and a command (an effect to execute). This keeps the state transition
pure.

**B4 — State model: a single immutable value (Redux) / the model (Elm).**
The entire application state is one value. State transitions are pure
functions. There is no mutation — each action produces a new state. This is the
cleanest state model in the evaluation, but it requires structural sharing
(persistent data structures) to be practical for large state.

**B5 — Inter-unit calls: not applicable.**
Redux and Elm are single-process, client-side architectures. There is no
inter-unit dispatch.

**B6 — Transactional integrity: inherent.**
Because reducers are pure functions that return new state, every transition is
atomic by construction. There is nothing to roll back — the previous state
still exists unchanged. This is the simplest transactional model: immutability
makes transactions unnecessary.

**B7 — Failure handling: limited.**
Redux has no built-in failure handling. Elm's `Result` type and the type system
catch many errors at compile time, but runtime failures in commands are handled
ad hoc.

**B8 — Response generation: the view function.**
Both Redux (via React) and Elm derive the UI from the current state through a
pure render function. The view is a function of state — never out of sync,
never manually updated. This is the same principle as Seed's `generate`:
given the manifestation tree (the state), produce the interface.

**B9 — Introspection: time-travel debugging.**
Redux DevTools and Elm's debugger let you replay every action, inspect the
state at each step, and time-travel through the application's history. This is
the strongest development-time introspection in the evaluation, and it is
enabled by the immutable-state model: every past state is preserved.

**B10 — Deployment and scale: client-side only.**
Redux and Elm run in the browser. They do not address server deployment,
multi-instance coordination, or database transactions.

**Steal:** Elm's compile-time-checked message types as the model for a
validated input contract. `redux-undo` as proof that history can be a wrapper
around a handler. Time-travel debugging. The principle that the view is a
pure function of state.

**Reject:** Client-side only — Seed is server-side. Immutable state — Common
Lisp's mutable data structures are the foundation of `fx`-path-access and
`form-sort`, and switching to persistent data structures would be a fundamental
redesign. The absence of inter-unit dispatch.


## Rendition: Seed

Seed's branch system is assessed at revision `31067ad`, as documented in the
companion Survey (SEED-0009).

**B1 — Unit of dispatch: the branch.** ●
Branches are named by keyword, registered per system, and invoked via `grow`.
They are addressable and composable. Network transparency is architectural
but not built.

**B2 — Input contract: adapter whitelists.** ◐
Adapters declare accepted keys and normalise input. But the whitelist is
manually maintained, duplicated with the handler's destructuring, and not
validated against the data's IS metadata. There is no compile-time or
runtime contract checking.

**B3 — Stage composition: channel-fns with short-circuit.** ◐
Stages compose linearly. Short-circuiting terminates the chain. But stages
have no names, no leave phase, and no error phase. The flow through multiple
lambdas with short-circuiting is opaque.

**B4 — State model: session-scoped via of-state.** ◐
`of-state` provides per-session key-value storage. But some branches close
over lexical state shared across sessions (a concurrency hazard), and there
is no state isolation between branches within a session.

**B5 — Inter-unit calls: grow (local only).** ◐
`grow` dispatches to any branch within the system. The interface shape is
compatible with remote dispatch, but network transparency is not implemented.

**B6 — Transactional integrity: none.** ○
Branches mutate state destructively via `of-state`, `rplacd`, and
`fx-path-access`. There is no commit/rollback, no syncpoint, and no atomicity.

**B7 — Failure handling: Common Lisp conditions.** ◐
The CL condition system provides restarts, which are more powerful than
try/catch. But the branch pipeline has no error phase — a condition in a
mutation stage leaves no cleanup path for subsequent stages.

**B8 — Response generation: metadata-derived.** ●
Branches produce manifestation trees from `fx` and `dx` forms, rendered
through medium-dispatched `generate` methods. This is the strongest response
generation in the evaluation: the interface is derived from the data's own
metadata.

**B9 — Introspection: minimal.** ○
Stages are anonymous lambdas. There is no way to list a branch's pipeline, no
named stages, no tracing. Debug output uses `print` statements. CL's
`trace` and `inspect` work on individual functions but not on the pipeline as a
composed unit.

**B10 — Deployment and scale: single-image, unproven.** ○
Seed runs as a single CL image serving HTTP. There is no multi-instance
deployment, no clustering, and no production track record.


## Comparison

Table: Summary scores per criterion. ● strong; ◐ partial; ○ weak.

| Criterion | CICS | Ring/Pedestal | OTP | LiveView | Redux/Elm | Seed |
|-----------|------|--------------|-----|----------|-----------|------|
| B1 Dispatch | ● | ◐ | ● | ● | ◐ | ● |
| B2 Input contract | ◐ | ◐ | ○ | ◐ | ● (Elm) | ◐ |
| B3 Stage composition | ○ | ● (Pedestal) | ○ | ○ | ◐ | ◐ |
| B4 State model | ● | ◐ | ● | ● | ● | ◐ |
| B5 Inter-unit calls | ● | ○ | ● | ◐ | ○ | ◐ |
| B6 Transactions | ● | ○ | ○ | ○ | ● (inherent) | ○ |
| B7 Failure handling | ◐ | ◐ (Pedestal) | ● | ◐ | ○ | ◐ |
| B8 Response generation | ◐ (BMS) | ○ | ○ | ◐ (diffs) | ◐ (view fn) | ● |
| B9 Introspection | ◐ | ◐ | ● | ◐ | ● | ○ |
| B10 Scale | ● | ◐ | ● | ◐ | ○ | ○ |

Seed is strongest at B8 (metadata-derived responses) and B1 (named, composable
dispatch). Its most critical gaps are B6 (no transactions), B9 (no pipeline
introspection), and B10 (no production deployment).


## Synthesis

### What Seed should adopt

**From CICS: transactional semantics.**
A `with-transaction` pipeline stage that snapshots state on entry and rolls
back on error. CICS's syncpoint model is the proven design; Common Lisp's
condition system with restarts provides the mechanism. The combination — a
stage that establishes a restart which rolls back `of-state` mutations — would
give branches atomic execution without requiring immutable data structures.

**From Pedestal: the interceptor model.**
Named stages with `:enter`, `:leave`, and `:error` phases. The `:error` phase
is the missing piece that makes the CL condition system usable within the
pipeline: when a mutation stage signals a condition, the error phase of earlier
stages (including the transaction stage) can clean up. Named stages also enable
the pipeline inspector that SEED-0009 proposes and that the Smalltalk
Eval's moldable-debugger recommendation motivates.

**From OTP: location-transparent dispatch and supervision.**
`grow` should work identically for local and remote branches. The OTP
distribution model — serialise the message, send it to the named process on
the target node, deserialise, dispatch — maps directly onto `grow`'s existing
interface. Supervision (restarting a crashed branch handler) is the failure
model for a multi-user portal.

**From LiveView: server-rendered diffs and per-connection isolation.**
LiveView validates that Seed's server-rendered model works at scale. The
per-connection process model (each client gets its own Erlang process with its
own state) is the concurrency model Seed should consider: each session's
branches run in their own thread or process, with `of-state` scoped to that
process.

**From Elm: compile-time input contracts.**
Elm's algebraic message types prove that input contracts can be checked before
execution. Seed's adapter whitelists are the declaration; what's missing is the
checking. A unified input declaration that generates both the adapters and a
validation step — checking incoming values against IS metadata — would bring
Seed closer to Elm's guarantee.

**From Redux: history as a wrapper.**
`redux-undo` demonstrates that history (undo/redo) can be implemented as a
middleware wrapper around an existing handler, without changing the handler's
code. This validates the `with-history` pipeline stage proposed in
SEED-0009.

### What Seed should keep as its own

- **Metadata-derived response generation.** No system in this evaluation
  derives its interface from the data's own self-description. CICS's BMS maps
  are static. LiveView uses templates. Redux/Elm use explicit render functions.
  Seed's `fx`/`dx` → manifestation → `generate` pipeline is unique and is its
  most important architectural contribution.
- **The adapter pipeline as input-medium normalisation.** Ring and Pedestal
  normalise HTTP input; Seed's adapters normalise *any* input format (JSON,
  alist, and potentially terminal, gamepad, or voice). The pipeline's
  transport-independence is stronger than any single system in this evaluation.
- **Write-time operations as middleware.** `fx-path-access` and `form-sort` are
  generic, metadata-aware mutation stages that work on any `fx`-annotated data.
  No system in this evaluation has an equivalent — mutation logic is always
  application-specific in the other systems.
- **The two-pipeline symmetry.** Adapters on the input side, `:adapting`
  processors and `generate` on the output side, with the branch handler in
  between. This symmetric design, where the branch is medium-independent on
  both ends, has no direct counterpart in the prior art.
