---
id:            SEED-0008
title:         "The Smalltalk Family as Prior Art for Seed"
genre:         Eval
subtype:       prior-art
scope:         project
project:       Seed
language:      en
status:        Accepted
authors:
  - Andrew Sengul
approved-by:   Andrew Sengul
reviewed:      2026-11-13
provenance:
  assistant:   claude-opus-5-5
relates-to:
  - SEED-0005
  - SEED-0006
  - SEED-0007
  - SEED-DRAFT-classicinterface
  - SEED-DRAFT-branches
cites:
  - title:     "Design Principles Behind Smalltalk"
    locator:   "Ingalls, D. H. H. BYTE 6(8), August 1981"
    external:  true
  - title:     "Smalltalk-80: The Language and Its Implementation"
    locator:   "Goldberg, A. and Robson, D. Addison-Wesley, 1983"
    external:  true
  - title:     "Personal Dynamic Media"
    locator:   "Kay, A. and Goldberg, A. Computer 10(3), March 1977"
    external:  true
  - title:     "Seaside: A Flexible Environment for Building Dynamic Web Applications"
    locator:   "Ducasse, S., Lienhard, A. and Renggli, L. IEEE Software 24(5), 2007, pp. 56-63"
    external:  true
  - title:     "Magritte — A Meta-Driven Approach to Empower Developers and End Users"
    locator:   "Renggli, L., Ducasse, S. and Kuhn, A. MODELS 2007, LNCS 4735, pp. 106-120"
    external:  true
  - title:     "Directness and Liveness in the Morphic User Interface Construction Environment"
    locator:   "Maloney, J. H. and Smith, R. B. Proc. UIST 1995, pp. 21-28"
    external:  true
  - title:     "The Moldable Inspector"
    locator:   "Chiş, A., Nierstrasz, O., Syrel, A. and Gîrba, T. Onward! 2015, pp. 44-60"
    external:  true
  - title:     "Magritte — Meta-Described Web Application Development"
    locator:   "Renggli, L. Master's thesis, University of Bern, June 2006"
    external:  true
  - title:     "The Lively Kernel — A Self-supporting System on a Web Page"
    locator:   "Ingalls, D., Palacz, K., Uhler, S., Taivalsaari, A. and Mikkonen, T. Self-Sustaining Systems (S3) 2008, LNCS 5146, pp. 31-50"
    external:  true
---

# The Smalltalk Family as Prior Art for Seed

This evaluation examines the Smalltalk family of systems as prior art for
Seed's approach to self-describing data, derived interfaces, and live
development. The Smalltalk lineage is the closest prior art to what Seed
attempts — both systems are committed to self-description, to collapsing the
boundary between use and construction, and to making the system transparent to
those who work within it. The divergences are in where each locates the
fundamental unit of meaning and how that choice shapes everything else.

Three branches of the Smalltalk family are evaluated separately, because each
corresponds to a different facet of Seed's design: Pharo/Squeak with Morphic
(the live desktop environment), Seaside with Magritte (server-side web
applications with metadata-described objects), and Glamorous Toolkit (moldable
development). Seed is given its own rendition and scored against the same
rubric.


## Method

Evidence is drawn from published documentation and specifications, cited in
the front-matter. No hands-on benchmarks or user studies were conducted. Seed
is assessed at revision `35020c4`.

The stance is **learning from prior art**: what the Smalltalk family has proven,
what problems it solved and left unsolved, and what Seed should adopt, adapt,
or deliberately reject. Each claim about Seed is marked as *realised* (built
and working) or *architectural* (designed for, with no implementation barrier,
but not yet built).

### Shared heritage

Smalltalk and Lisp are not strangers. Interlisp-D and Smalltalk-80 were
developed side by side at Xerox PARC in the late 1970s and early 1980s, sharing
hardware (the Dorado, the Dandelion), display technology, and many of the same
researchers' ideas about interactive, self-describing systems. Common Lisp
itself is image-capable: SBCL's `save-lisp-and-die` snapshots a running image,
and the SLIME/SLY inspector and debugger provide live introspection comparable
to Smalltalk's tools (the editor-models Eval, SEED-0006, treats these Common
Lisp environments in its own rendition). Seed inherits from both lineages, and
the comparison is between close relatives, not distant strangers.


## The Shared Scenario

Each system is walked through six tasks.

**S1 — Build an editor for the chart-entity set.** The structured parameter data
in `systems/abcd/analyses/eurcad-proto/chart.lisp`: numeric fields, a select
among line types, a sortable list with per-item remove controls.

**S2 — Change its behaviour while it is running, without a restart.** Modify a
field's constraints or add a new column to the editor while it is serving
requests.

**S3 — Debug an edit that fails partway through.** A user submits a form that
triggers a condition in the branch handler. Inspect the state, fix the problem,
and continue.

**S4 — Version the change and collaborate on it through git.** Put the
modification under version control, share it with another developer, and merge
their concurrent change.

**S5 — Deliver the editor to a non-programmer over the web.** Hand the
chart-entity editor to an analyst who opens a browser and uses it without
installing anything.

**S6 — Have an LLM generate a new editor of the same kind.** Describe a new
data type to an LLM and get a working editor back.


## The Rubric

Table: Evaluation criteria E1–E12. Where a criterion corresponds to one in the
editor-models Eval (`SEED-0006`), the mapping is noted.

| Code | Criterion | Editor Eval mapping |
|------|-----------|-------------------|
| E1 | Primary unit and how things are addressed | G1 (source of truth) |
| E2 | Self-description: where it lives, what form it takes, whether it's checked | G2 (semantic knowledge) |
| E3 | Liveness: how fine-grained the feedback loop is | — |
| E4 | Debugging and runtime inspection | — |
| E5 | Persistence and version control | G5 (edit round-trip) |
| E6 | How interfaces are constructed | G3 (extension model) |
| E7 | Medium independence | G10 |
| E8 | Dispatch model | — |
| E9 | Audience: who it can serve, from programmer to end user | G4 |
| E10 | Multi-user and server deployment | — |
| E11 | LLM tractability: can generated artifacts be checked? | — |
| E12 | Ecosystem and adoption history | G8 |


## Rendition: Pharo/Squeak with Morphic

Pharo (a fork of Squeak, itself descended from Smalltalk-80) is the most active
open-source Smalltalk. Morphic — designed by John Maloney and Randy Smith for
the Self environment at Sun Microsystems Laboratories, and brought to Squeak by
Maloney when he left the Self project — is its UI framework, based on the principle that every
visible element is a live object that can be directly grabbed, inspected, and
changed.

**E1 — Primary unit: the object.**
Everything in Smalltalk is an object with identity, state, and behaviour.
Objects are addressed by reference — a variable holds a pointer to an object,
and identity (`==`) is distinct from equality (`=`). Two objects can have
identical state and be different objects. The system is a society of objects
communicating by message-passing.

**E2 — Self-description: methods on objects, checked at message-send time.**
Every object can respond to inspection messages. The class hierarchy describes
what an object is; the method dictionary describes what it can do. Knowledge is
checked at message-send time: if an object does not understand a message, it
raises `doesNotUnderstand:`, which can be intercepted and handled. This is
runtime checking — late, but universal.

**E3 — Liveness: object-level.**
Modify a method and every existing instance immediately uses the new behaviour.
Evaluate an expression in a Workspace and see the result. The granularity of
feedback is the individual message send. This is the finest-grained liveness of
any system in this evaluation.

**E4 — Debugging: exemplary.**
The Smalltalk debugger allows you to halt at any point, inspect the full stack,
examine and modify any object's state, edit the source of any method, recompile
it, and continue execution from the modified point. This edit-and-continue
capability is the gold standard for interactive debugging. The Method Finder
locates a method from examples of input and output.

**E5 — Persistence: the image, with git support via Tonel.**
The Smalltalk image is a snapshot of all live objects, serialised to disk. It
preserves the full system state across sessions. Historically, images did not
work well with text-based version control, but Pharo now stores code in git
through Iceberg and the Tonel file format, which exports class definitions and
methods as individual text files. Squeak has Monticello. The image remains the
source of truth at runtime; git tracks the code.

**E6 — Interface construction: direct manipulation of live objects.**
In Morphic, you build interfaces by composing Morphs — live objects that render
themselves. You can grab a Morph, inspect its properties, drop it into another
Morph, and see the result immediately. The interface is a tree of live objects,
not a description that gets compiled into objects.

**E7 — Medium independence: weak.**
Morphic renders to the Smalltalk display surface (a bitmap canvas). It does not
target the browser, a terminal, or a mobile device as first-class media. The
Lively Kernel (Ingalls et al., S3 2008) carried Morphic into the browser as a
JavaScript implementation, demonstrating that the model can be projected to
other surfaces, but it is a separate system, not Pharo.

**E8 — Dispatch: single dispatch.**
Smalltalk dispatches on one argument: the receiver of a message. The message
name selects the method; the receiver's class determines which implementation
runs. To dispatch on two arguments (as Seed's `generate` dispatches on both
medium and component), Smalltalk requires double dispatch or the visitor pattern
— a workaround rather than a native capability.

**E9 — Audience: programmers, with tools for children.**
Smalltalk was conceived as Kay's "personal dynamic medium" for everyone,
including children (the Dynabook vision). Squeak's Etoys and Scratch (originally
built in Squeak) realised this for education. But the full Smalltalk environment
— the System Browser, the Inspector, the Debugger — is usable only by
programmers. The non-programmer audience receives purpose-built applications,
not the raw environment.

**E10 — Multi-user and server deployment: via GemStone/S.**
The standard Pharo image is a single-user, single-process environment. GemStone/S
extends Smalltalk with persistent, transactional, multi-user object storage —
a shared object space that multiple clients connect to. This is precedent for
the multi-user server deployment that Seed's portals aim for, though GemStone
is a separate commercial product rather than a standard part of the language.

**E11 — LLM tractability: limited.**
Smalltalk methods are arbitrary code. An LLM can generate Smalltalk, but
the output cannot be structurally verified beyond syntax — it must be tested
by running it. There is no constrained vocabulary that bounds what the LLM
can produce.

**E12 — Ecosystem: substantial but reduced.**
Smalltalk had a thriving commercial ecosystem in the 1990s (ParcPlace,
VisualWorks, IBM VisualAge). Java's rise in the late 1990s reduced it severely.
Pharo maintains an active open-source community with a curated package
catalogue, but the ecosystem is small compared to mainstream languages. The
adoption history demonstrates the Worse-is-Better dynamic discussed in
`SEED-0007`: a more powerful but less accessible system lost to a
simpler but more widely adopted one.

**Scenario walk-through.**

- **S1 — build the editor.** The chart entities become objects, and the
  editor is composed by hand from Morphs — fields, a list, buttons — either
  interactively or in code. Nothing derives the editor from a description of
  the data.
- **S2 — change it while running.** The strongest case of any rendition: edit a
  method and every live instance uses it at once; add a column by dropping a
  new Morph into the running editor.
- **S3 — debug a failing edit.** The debugger halts at the error; inspect the
  state, fix the method, and proceed from the point of failure.
- **S4 — version and merge.** Code goes to git through Iceberg and Tonel, and
  merges as text. Object state held only in the image is not versioned.
- **S5 — deliver over the web.** Not native: Morphic is a desktop canvas.
  Delivery through a browser needs another system — Seaside, or the Lively
  Kernel's re-implementation of Morphic in JavaScript.
- **S6 — LLM generation.** An LLM can write the classes and Morph code, but
  only running them checks them.

**Steal:** The debugger culture — edit-and-continue, inspect-anything,
Method Finder. The `doesNotUnderstand:` protocol for graceful handling of
missing capabilities. Morphic's proof that live, direct manipulation of
interface objects works.

**Reject:** Single dispatch as the sole mechanism — Seed needs multiple
dispatch for medium independence. The image as sole source of truth — Seed
keeps files and git as the source of truth, with the image as a derived state.


## Rendition: Seaside with Magritte

Seaside (Ducasse, Lienhard, Renggli; IEEE Software 2007) is a Smalltalk web
application framework. Magritte (Renggli, Ducasse, Kuhn; MODELS 2007) is a
meta-description framework built on top of it, first presented in Renggli's
master's thesis (Bern, 2006). Together they represent the closest existing
architectural parallel to Seed's branch pipeline and `fx`-derived interfaces.
The interface-models Survey (SEED-0005) places Magritte among interfaces
generated from a model.

Renggli's thesis also presents Pier, "a meta-described content management and
Wiki system" built on Magritte: a CMS and a wiki whose editing is driven by
Magritte descriptions. Pier is the direct precedent for Seed's Classic
interface mode (SEED-DRAFT-classicinterface), which aims at the same pair of
applications — a blog-style CMS and a wiki — derived from Classic's slot
metadata and lenses instead of Smalltalk descriptions.

**E1 — Primary unit: the component (Seaside) and the description (Magritte).**
In Seaside, a web application is a tree of components, each a stateful object
that renders itself to HTML and handles callbacks. Components have identity and
session-scoped state. In Magritte, domain objects carry meta-descriptions:
`MAStringDescription`, `MANumberDescription`, `MAToOneRelationDescription`, etc.
These descriptions generate forms, validation, tables, and reports.

**E2 — Self-description: descriptions on classes, checked at runtime.**
Magritte descriptions are objects attached to *classes*, describing the
properties of every instance of that class. A `Person` class declares that
`name` is a string, `age` is a number between 0 and 150, `address` is a
relation to an `Address`. The descriptions are *checked*: Magritte validates
input against the description before accepting it. This is the closest prior
art to Seed's IS axis, and it is stronger on verification — Magritte checks
what Seed currently only asserts.

The key difference: Magritte describes *classes*. Every `Person` instance
shares the same description. Seed's `fx` describes *individual values*: two
integers in the same data structure can carry different metadata (one is
`:entering`, the other `:observing`). Per-value granularity alone is not new —
Fresnel's instance lenses already target a single resource (SEED-0005) — but
those lenses are separate documents that point at the data. What distinguishes
Seed is that the annotation lives on the value itself and travels with it.
Magritte's class-level description is more conventional but inherently
checkable, because the class definition constrains what the description can
say.

**E3 — Liveness: request-level, with live debugging.**
Seaside processes one HTTP request at a time per session. Feedback is at the
request granularity — you modify a component's rendering method and the next
page load reflects the change. If an error occurs during rendering, Seaside
shows an error page in the browser, and the developer can move from it into
the Smalltalk debugger, fix the method, and retry the request (E4). This is
finer-grained than Seed's current debugging story.

**E4 — Debugging: from the browser into the debugger.**
When an exception occurs during rendering, Seaside catches it and shows an
error page in the browser with the stack trace. From that page the developer
can open the Smalltalk debugger, inspect the failure, edit and recompile the
method, and retry the request. Accounts differ on how much of this happens in
the browser itself; at least one Seaside user describes the page's *Debug*
link as launching the debugger in the Smalltalk image. Either way, the
workflow — an error in a served page leads straight to a live debugger at the
point of failure, and the request can be retried after the fix — is the
standard Seed should aspire to for branch-pipeline debugging.

**E5 — Persistence: the image (with git via Tonel), plus GemStone for deployment.**
Same as Pharo. In production, Seaside applications often run on GemStone/S for
persistent, multi-user object storage. Seaside on GemStone (called GLASS —
GemStone, Linux, Apache, Seaside, Smalltalk) is a proven production stack.

**E6 — Interface construction: programmatic rendering + Magritte auto-generation.**
Seaside components render themselves by sending messages to an HTML canvas
object — `html div`, `html textInput`, `html anchor`. This is programmatic
HTML generation from Smalltalk code, similar to Seed's use of Spinneret.
Magritte layers automatic form generation on top: given a described domain
object, it produces a complete form with labels, input widgets, validation, and
error display, *without any rendering code written by the developer*. This is
the Naked Objects principle implemented more flexibly than the original.

**E7 — Medium independence: weak (web only).**
Seaside targets the web browser exclusively. Magritte descriptions could in
principle drive other renderers, but no such renderers exist in practice.

**E8 — Dispatch: single dispatch, extended by Magritte's interpreter pattern.**
Seaside dispatches rendering on the component (single dispatch). Magritte
dispatches form generation on the description type (also single dispatch, but
with a pluggable "interpreter" that can produce different output formats from
the same descriptions). This is a manual approximation of what CLOS multiple
dispatch gives Seed natively.

**E9 — Audience: programmers build for end users.**
Seaside applications serve end users through the browser. The development
environment (the Smalltalk image) is programmer-only. This is the same split
Seed has, with the same audience model: programmers build; users interact with
the result.

**E10 — Multi-user deployment: proven (GemStone/GLASS).**
Seaside on GemStone is a production-grade multi-user deployment. Multiple
Seaside instances share a transactional object store. This is stronger than
Seed's current single-image server.

**E11 — LLM tractability: better than bare Smalltalk.**
Magritte descriptions are declarative and structurally regular. An LLM could
generate Magritte descriptions more reliably than arbitrary Smalltalk rendering
code, because the description vocabulary constrains what can be expressed. This
is the same argument Seed makes for `fx` forms; Magritte shows that such a
vocabulary is workable in practice, and that it can be checked.

**E12 — Ecosystem: niche but proven.**
Seaside has been developed since 2002 and has been used for commercial web
applications. Magritte is well-documented but less widely adopted. The
ecosystem is small.

**Scenario walk-through.**

- **S1 — build the editor.** Describe the chart-entity class with Magritte
  descriptions — numbers, a single-option description for the line type, a
  to-many relation for the entity list — and Magritte generates the form, its
  validation and a report. The sortable list with per-item remove controls is
  composed from Seaside components.
- **S2 — change it while running.** Edit a description or a rendering method
  in the image; the next request reflects the change, with no restart.
- **S3 — debug a failing edit.** The browser shows the error page with the
  stack trace; the developer moves into the Smalltalk debugger, fixes the
  method, and retries the request (E4).
- **S4 — version and merge.** Code goes to git through Iceberg and Tonel, as in
  Pharo. Data held in the image or in GemStone is versioned separately, if at
  all.
- **S5 — deliver over the web.** Strong: Seaside is web-native, and the analyst
  needs only a browser.
- **S6 — LLM generation.** An LLM can generate Magritte descriptions, which are
  regular and declarative; Magritte then validates input against them. The
  surrounding Seaside components remain arbitrary code.

**Steal:** Magritte's verification of descriptions against domain objects.
Seaside's path from a failing page to a live debugger and a retried request.
Pier, as proof that a CMS and wiki can be built from descriptions. The `call:`/`answer:` control-flow model for component
sequencing. GemStone's proof that Smalltalk can serve multi-user production
workloads.

**Reject:** Class-level descriptions only — Seed needs metadata that lives on
the value itself.
Seaside's tight coupling to continuations (which complicate deployment and
scaling). Single dispatch.


## Rendition: Glamorous Toolkit

Glamorous Toolkit (GT), led by Tudor Gîrba, is a Pharo-based development
environment built around *moldable development*: the idea that the tools you
use to understand a system should be shaped by the system itself. Where GT
inherits Pharo's position, the criterion is noted briefly.

**E1 — Primary unit: the object.** As in Pharo.

**E2 — Self-description: view pragmas on methods.**
GT's key mechanism is the `<gtView>` pragma. A method annotated with
`<gtView>` is a view definition: it describes how instances of that class
should be inspected. A `Color` shows a colour swatch. A `Collection` shows a
filterable list. A `FileReference` shows its contents. The pragma is metadata
on a *method*, telling the inspector what views are available.

This sits between Magritte's class-level descriptions and Seed's per-value
metadata. The pragma is declared per class (like Magritte), but the method body
is arbitrary Smalltalk (unlike Magritte's structured descriptions and unlike
Seed's constrained vocabulary). This gives GT maximum expressiveness — any view
can do anything — at the cost of LLM tractability and structural verifiability.

**E3 — Liveness: object-level, with moldable tools.**
GT provides a moldable inspector (views adapt to the object), a moldable
debugger (debugger views adapt to the bug), and Lepiter notebooks that
interleave code, views, and narrative. The feedback is immediate and
object-specific.

**E4 — Debugging: moldable.**
Pharo's edit-and-continue debugger, extended so that its views and actions can
be shaped by the domain of the failure: the developer of a parser, say, can
give its errors a debugger view that shows the input and the parse state. This
goes beyond Pharo's single generic debugger.

**E5 — Persistence: as Pharo.** The image, with code in git through Iceberg
and Tonel.

**E6 — Interface construction: view methods.**
Adding a new view to a class means adding a method with `<gtView>`. The
inspector discovers all such methods and presents them as tabs. This is the
most flexible inspection system in this evaluation — but the flexibility is
for the *developer* inspecting objects, not for end users interacting with
derived interfaces.

**E7 — Medium independence: weak.** GT renders through its own graphics stack
to a desktop window, as Pharo's Morphic renders to its canvas.

**E8 — Dispatch: single dispatch, as Pharo.**

**E9 — Audience: developers only.**
GT is explicitly a developer tool. Its moldable views serve the person who
is building and debugging, not the person who uses the finished product. This
is the key difference from Seed, which derives interfaces for end users.

**E10 — Multi-user and server deployment: none.** GT is a single-user desktop
environment.

**E11 — LLM tractability: limited.** View methods are arbitrary Smalltalk, so
generated views can be checked only by running them — the same position as
Pharo.

**E12 — Ecosystem: growing.** GT is open source and actively developed by
feenk, with a small but active community around moldable development.

**Scenario walk-through.**

- **S1 — build the editor.** GT can give the chart entities rich developer
  views — a table of entities, a plot of the chart — through `<gtView>`
  methods, but editing forms for end users are not its purpose.
- **S2 — change it while running.** As Pharo: live, with views that update as
  their methods change.
- **S3 — debug a failing edit.** The strongest debugging case: Pharo's
  edit-and-continue, plus debugger views specific to the kind of failure.
- **S4 — version and merge.** As Pharo, through Iceberg and Tonel.
- **S5 — deliver over the web.** Not served: GT is a desktop developer tool.
- **S6 — LLM generation.** An LLM can write `<gtView>` methods, but they are
  arbitrary code, checked only by running them.

The interface-models Survey (`SEED-0005`) discusses GT's
multi-view principle and its influence on IS/AS/BY in more detail.

**Steal:** The `<gtView>` pragma as proof that metadata on methods can drive
tool adaptation. The moldable debugger — the idea that the debugger's own
interface should be shaped by the type of bug. Lepiter notebooks as a model
for interleaving computation, views, and narrative.

**Reject:** Arbitrary Smalltalk in view methods — Seed deliberately constrains
its vocabulary for tractability. Developer-only audience — Seed must serve end
users through derived interfaces.


## Rendition: Seed

Seed is a Common Lisp system in which data carries its own interface
specification as `fx` metadata, interpreted through the IS/AS/BY ontology
(SEED-0003, SEED-0004) and rendered by `generate` methods dispatched on the
medium. It is assessed at revision `35020c4`. Each claim is marked *realised*
or *architectural*, as the Method describes.

**E1 — Primary unit: the annotated form.**
The unit is an S-expression carrying `fx` metadata: data at rest in a file, or
a `(dx)` form constructed by branch code. Expression turns it into a tree of
manifestation objects (`mfn-atom`, `mfn-sequence`, `mfn-container`) that hold
the value and its IS/AS/BY classification together (*realised*). Data in files
is addressed by key and position through Philo (SEED-0001) (*realised*).

**E2 — Self-description: metadata on the value, asserted.**
The description lives on the datum itself and travels with it — the property
that separates Seed from Magritte's class-level descriptions and Fresnel's
separate lens documents (SEED-0005). But it is asserted, not checked: nothing
stops `(:is :integer)` from being written on a string, and a wrong annotation
produces a confidently wrong interface (SEED-0006, G2). Stratum-1 IS is
inferred from the Lisp type (*realised*); a validator for the rest is
*architectural* at best — designed for, not built.

**E3 — Liveness: request-level, with a live image.**
Seed runs in a live Common Lisp image. Redefining a function, method or class
takes effect at once, and the next request renders with it, with no restart
(*realised*, as a property of Common Lisp). Feedback in the interface is per
request: the page re-renders after an action. There is nothing like Morphic's
direct manipulation of the rendered interface.

**E4 — Debugging: the Common Lisp debugger, with no pipeline view.**
A condition in a branch handler or a `generate` method reaches the Common Lisp
debugger, where — with SLIME or SLY attached — the developer can inspect the
stack, redefine the failing function, and choose a restart (*realised*, as a
property of Common Lisp). The request path itself installs no handlers at this
revision, and nothing presents the failure in the browser or shows the
manifestation tree and pipeline state at the point of failure. A
Seaside-style path from the failing page to a live debugger, and a moldable
pipeline inspector, are *architectural* (see Synthesis).

**E5 — Persistence: files and git.**
Code and data are text files under git. Branches read and write S-expression
data files by key, so the edited data is itself versioned (*realised*; Philo,
SEED-0001, is the standard accessor going forward). The running image is a
derived state, not the source of truth.

**E6 — Interface construction: derived from metadata.**
Interfaces are expressed from `fx` and `(dx)` forms through the IS/AS/BY
pipeline, with Tier-1 defaults attached by BY modality and Tier-2 `:adapting`
processors supplied by branch code (SEED-0003, SEED-D16). This is *realised*
for the catalog demonstration and for text provisioning through CodeMirror.
It is partly built for manipulation: `:reducing` controls are rendered but not
yet wired to the client, and `:sorting` and `:extending` are stubs.

**E7 — Medium independence: architectural.**
IS/AS/BY says nothing about the rendering target, and `generate` dispatches
on the medium. Only `uim-web` has methods; `uim-terminal` exists as a class
with none. Medium independence is a goal Seed has not yet realised
(*architectural*).

**E8 — Dispatch: multiple, through CLOS.**
`generate` dispatches on both the medium and the manifestation class in one
generic function (*realised*). Smalltalk reaches the same result through
double dispatch or visitors.

**E9 — Audience: end users, by design.**
The derived interface is meant for people who never see Lisp: an analyst
edits chart parameters through fields and lists in a browser. The old-grammar
portals already serve such users (*realised*); serving them through the
IS/AS/BY pipeline end to end is the aim of the Classic interface mode
(SEED-DRAFT-classicinterface) (*architectural*).

**E10 — Multi-user and server deployment: one image, many sessions.**
A Seed portal is a web server (Woo through Clack and Ningle) in a single
image, keeping per-session state for each browser (*realised*). There is no
shared transactional object store like GemStone, and no isolation between
branches or sessions.

**E11 — LLM tractability: constrained but unchecked.**
`fx` forms follow a small, regular grammar that an LLM can be given in context
and that Seed's own parsers read (*realised*). But because the metadata is
not validated (E2), generated forms that parse can still be semantically wrong.
A validator would make the constraint checkable (*architectural*).

**E12 — Ecosystem: none.**
No packages, no community, no documented extension points for outside
developers.

**Scenario walk-through.**

- **S1 — build the editor.** Annotate the chart entities with `fx` metadata;
  the editor — fields, a select among line types, a sortable list with remove
  controls — is derived rather than composed by hand (*architectural* as a
  whole: the manipulation defaults are incomplete, E6).
- **S2 — change it while running.** Edit the annotations or redefine a
  `generate` method in the live image; the next request reflects it, with no
  restart (*realised*).
- **S3 — debug a failing edit.** The condition reaches the Common Lisp
  debugger in the developer's SLIME or SLY session, where the function can be
  fixed and a restart chosen; nothing yet shows the failure, the pipeline
  state or the manifestation tree in the browser (E4).
- **S4 — version and merge.** The strongest case of any rendition: code and
  data are both text files in git, and merge as text (*realised*).
- **S5 — deliver over the web.** The analyst opens a browser and uses the
  editor with nothing to install (*realised* for the old-grammar portals).
- **S6 — LLM generation.** An LLM given the IS/AS/BY vocabulary can produce
  `fx` forms that Seed parses and renders; whether they are right is not yet
  checked (E11).

**Steal from Seed's own architecture:** metadata that lives on the value and
travels with it; multiple dispatch for medium independence; files and git as
the source of truth, for data as well as code.

**Fix:** checked metadata (E2), a web-facing debugger and pipeline inspector
(E4), the manipulation defaults (E6), and a second medium (E7).


## Comparison

Table: Summary scores per criterion. ● strong; ◐ partial; ○ weak.

| Criterion | Pharo/Morphic | Seaside/Magritte | GT | Seed |
|-----------|--------------|-----------------|-----|------|
| E1 Primary unit | ● object | ● component + description | ● object | ● annotated form |
| E2 Self-description | ◐ methods, runtime-checked | ● descriptions, validated | ◐ pragmas, unchecked | ○ metadata, asserted |
| E3 Liveness | ● object-level | ◐ request-level + debugger | ● object-level | ◐ request-level |
| E4 Debugging | ● edit-and-continue | ● error page → live debugger | ● moldable debugger | ◐ CL debugger, no pipeline inspector |
| E5 Persistence/VCS | ◐ image + Tonel/git | ◐ image + GemStone | ◐ image + Tonel/git | ● files + git native |
| E6 Interface construction | ◐ direct manipulation | ● programmatic + auto-generated | ◐ view methods | ● metadata-derived |
| E7 Medium independence | ○ bitmap canvas | ○ web only | ○ bitmap canvas | ◐ architectural |
| E8 Dispatch | ○ single | ○ single + interpreter | ○ single | ● multiple (CLOS) |
| E9 Audience | ◐ programmers + Etoys | ◐ programmers build for users | ○ developers only | ● end users by design |
| E10 Multi-user deployment | ◐ via GemStone | ● GemStone/GLASS proven | ○ single-user | ◐ portal server |
| E11 LLM tractability | ○ arbitrary code | ◐ descriptions are regular | ○ arbitrary code | ◐ vocabulary-constrained |
| E12 Ecosystem | ◐ reduced | ◐ niche, proven | ◐ growing | ○ none |

Seed and the Smalltalk family are strongest in complementary areas. Smalltalk
excels at liveness, debugging, and proven deployment (E3, E4, E10). Seed leads
on dispatch and on audience by design (E8, E9), and on version control of data
as well as code (E5). Its lead on medium independence and on the structural
properties of a constrained vocabulary (E7, E11) is architectural: these are
goals Seed has not yet realised. Magritte is the strongest on verification (E2)
— the gap that Seed most needs to close.


## Synthesis

### What Seed should adopt

**From Magritte: verified descriptions.**
Magritte's most important lesson is that metadata descriptions can be *checked*
against the objects they describe. A `MANumberDescription` for a property that
is actually a string is caught. A range constraint that specifies `min > max`
is caught. Seed's IS/AS/BY metadata is currently asserted without verification
— the gap identified in `SEED-0006` (criterion G2). Magritte
demonstrates that this gap is closable: the same descriptions that drive form
generation can also drive validation. Seed should build a metadata validator
that checks IS annotations against Lisp types, BY annotations against available
`generate` methods, and AS annotations against the surrounding structure.

**From Seaside: a web debugger.**
When a Seaside application errors during rendering, the developer can go from
the failing page to a live debugger, inspect the full state, fix the method,
and retry the request — without restarting (E4). Seed should go further and
implement a debugger presented through the web itself. Its branch pipeline
should offer the same workflow: when a `generate` method signals a condition,
the Common Lisp condition system already supports restarts; what is missing is
a web-facing presentation of the debugger state, integrated with the portal's
interface, that lets the developer inspect the manifestation tree, the pipeline
state, and the condition, and choose a restart. Common Lisp's condition system
is at least as powerful as Smalltalk's exception handling — the gap is in
surfacing it through the web medium.

**From Seaside: session and component state management.**
Seaside's `call:`/`answer:` protocol and its per-session component state are
proven patterns for managing stateful web interactions. Seed's `of-state` and
branch-scoped state serve a similar purpose but are less formalised. Studying
Seaside's session management would inform the design of Seed's portal state.

**From Morphic: the principle that interfaces are made of live objects.**
Seed's `(dx)` forms produce live CLOS instances — manifestation objects with
mutable slots. They are not throwaway render output: they can be held in
variables, reconfigured between renderings, and
routed to any destination (file, live image, another branch, a network
endpoint). This means Seed's manifestations are already structurally similar
to Morphic's Morphs — live objects that describe their own presentation. The
difference is that Seed's manifestations are metadata-derived rather than
manually composed, and they carry their IS/AS/BY classification with them.
Making this live-object capability explicit and documenting it would strengthen
Seed's position on liveness (E3). The implementation barrier is minimal:
assigning a `(dx)` result to a package-level variable is sufficient to persist
it beyond a single request (*architectural*).

**From GT: the moldable debugger concept.**
The idea that a debugger's own views should adapt to the type of error — a
network error shows connection state, a rendering error shows the component
tree, a data error shows the `fx` annotations — is directly applicable to
Seed's pipeline. A Seed pipeline inspector could present different views
depending on which stage failed: an adapter stage shows the raw input and the
normalised output; a handler shows the branch state; a `generate` method shows
the manifestation tree and the medium.

**From the shared heritage: the image as a routing option.**
Common Lisp can save and restore images. The image-versus-file distinction is
a routing choice, not an architectural commitment: a branch can write its output
to a `.lisp` file via Philo, to a live CLOS object in memory, to another branch
via message-passing, or to a remote system via network. Making this routing
explicit — and potentially offering an "image mode" where all modifications
target live objects and are snapshotted periodically — would give Seed the
option of Smalltalk-like liveness when it is wanted, without sacrificing the
file-and-git reproducibility that is its default.

### What Seed should keep as its own

- **Metadata on the value, not on classes or in separate documents.** Magritte
  describes classes; every instance shares one description. Fresnel's
  instance lenses can target one resource, but from a separate document
  (SEED-0005). Seed's annotation lives on the value itself and travels with
  it; two integers in the same structure can have different interaction
  modes. That is essential for write-time control and cannot be reduced to
  class-level or external description without losing it.
- **Multiple dispatch for medium independence.** CLOS dispatches `generate` on
  both the medium and the manifestation class in one step. Smalltalk's single
  dispatch requires workarounds (double dispatch, visitors, Magritte's
  interpreter pattern). The native two-dimensional dispatch is what makes
  medium independence a first-class property.
- **Files plus git as the source of truth.** The Smalltalk image is powerful
  but historically fragile under version control. Seed's S-expression files
  are git-native. The persistence model should stay file-first, with the image
  as an optional runtime mode.
- **A constrained vocabulary.** GT's `<gtView>` methods can do anything, which
  makes them maximally expressive but structurally opaque. Seed's IS/AS/BY
  vocabulary is deliberately constrained so that metadata can be parsed,
  validated, rendered to multiple media, and generated by an LLM. The
  constraint is the source of tractability and should not be relaxed.

### Where Seed is not competing

Seed is not a general-purpose Smalltalk environment. It does not provide an
image browser, a method finder, or a live Morphic canvas. The overlap is in
**derived interfaces for structured data** and **live, self-describing systems
for web deployment**. Seaside with Magritte is the closest existing system to
what Seed builds, and the comparison is the most productive for Seed's
development priorities.
