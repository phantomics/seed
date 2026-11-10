---
id:            SEED-DRAFT-smalltalk
title:         "The Smalltalk Family as Prior Art for Seed"
genre:         Eval
subtype:       prior-art
scope:         project
project:       Seed
language:      en
status:        Draft
provenance:
  assistant:   claude-opus-5-5
relates-to:
  - SEED-DRAFT-interfacemodels
  - SEED-DRAFT-editormodels
  - SEED-DRAFT-verticality
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
    locator:   "Chiş, A., Gîrba, T. and Nierstrasz, O. Proc. OOPSLA 2015 Companion, pp. 44-60"
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
development). Seed is scored against the same rubric.


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
to Smalltalk's tools. Seed inherits from both lineages, and the comparison is
between close relatives, not distant strangers.


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
editor-models Eval (`SEED-DRAFT-editormodels`), the mapping is noted.

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
open-source Smalltalk. Morphic (originally from Self, ported to Squeak by
Maloney and Smith) is its UI framework, based on the principle that every
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
Lively Kernel (Ingalls et al., 2008) carried Morphic into the browser as a
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
`SEED-DRAFT-verticality`: a more powerful but less accessible system lost to a
simpler but more widely adopted one.

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
meta-description framework built on top of it. Together they represent the
closest existing architectural parallel to Seed's branch pipeline and
`fx`-derived interfaces.

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
`:entering`, the other `:observing`). This per-value granularity is Seed's
distinctive contribution; Magritte's class-level description is more
conventional but inherently checkable because the class definition constrains
what the description can say.

**E3 — Liveness: request-level, with live debugging.**
Seaside processes one HTTP request at a time per session. Feedback is at the
request granularity — you modify a component's rendering method and the next
page load reflects the change. If an error occurs during rendering, Seaside
opens the Smalltalk debugger *in the web browser* (via a debug page), lets you
fix the method, and regenerates the response. This is finer-grained than Seed's
current debugging story.

**E4 — Debugging: the web debugger.**
Seaside's most distinctive feature: when an exception occurs during rendering,
the framework catches it and presents a debug page with the stack trace, the
component tree, and the ability to edit and recompile the method that failed —
then retry the rendering. This is the Smalltalk debugger projected through the
web, and it is the standard Seed should aspire to for branch-pipeline debugging.

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
is the same argument Seed makes for `fx` forms, and Magritte demonstrates it
in practice.

**E12 — Ecosystem: niche but proven.**
Seaside has been in production since 2002. It is used by several commercial
products (notably in financial services and content management). Magritte is
well-documented but less widely adopted. The ecosystem is small.

**Steal:** Magritte's verification of descriptions against domain objects.
Seaside's web debugger. The `call:`/`answer:` control-flow model for component
sequencing. GemStone's proof that Smalltalk can serve multi-user production
workloads.

**Reject:** Class-level descriptions only — Seed needs per-value metadata.
Seaside's tight coupling to continuations (which complicate deployment and
scaling). Single dispatch.


## Rendition: Glamorous Toolkit

Glamorous Toolkit (GT), led by Tudor Gîrba, is a Pharo-based development
environment built around *moldable development*: the idea that the tools you
use to understand a system should be shaped by the system itself.

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

**E6 — Interface construction: view methods.**
Adding a new view to a class means adding a method with `<gtView>`. The
inspector discovers all such methods and presents them as tabs. This is the
most flexible inspection system in this evaluation — but the flexibility is
for the *developer* inspecting objects, not for end users interacting with
derived interfaces.

**E9 — Audience: developers only.**
GT is explicitly a developer tool. Its moldable views serve the person who
is building and debugging, not the person who uses the finished product. This
is the key difference from Seed, which derives interfaces for end users.

The interface-models Survey (`SEED-DRAFT-interfacemodels`) discusses GT's
multi-view principle and its influence on IS/AS/BY in more detail.

**Steal:** The `<gtView>` pragma as proof that metadata on methods can drive
tool adaptation. The moldable debugger — the idea that the debugger's own
interface should be shaped by the type of bug. Lepiter notebooks as a model
for interleaving computation, views, and narrative.

**Reject:** Arbitrary Smalltalk in view methods — Seed deliberately constrains
its vocabulary for tractability. Developer-only audience — Seed must serve end
users through derived interfaces.


## Comparison

Table: Summary scores per criterion. ● strong; ◐ partial; ○ weak.

| Criterion | Pharo/Morphic | Seaside/Magritte | GT | Seed |
|-----------|--------------|-----------------|-----|------|
| E1 Primary unit | ● object | ● component + description | ● object | ● annotated form |
| E2 Self-description | ◐ methods, runtime-checked | ● descriptions, validated | ◐ pragmas, unchecked | ○ metadata, asserted |
| E3 Liveness | ● object-level | ◐ request-level + debugger | ● object-level | ◐ request-level |
| E4 Debugging | ● edit-and-continue | ● web debugger | ● moldable debugger | ◐ CL debugger, no pipeline inspector |
| E5 Persistence/VCS | ◐ image + Tonel/git | ◐ image + GemStone | ◐ image + Tonel/git | ● files + git native |
| E6 Interface construction | ◐ direct manipulation | ● programmatic + auto-generated | ◐ view methods | ● metadata-derived |
| E7 Medium independence | ○ bitmap canvas | ○ web only | ○ bitmap canvas | ◐ architectural |
| E8 Dispatch | ○ single | ○ single + interpreter | ○ single | ● multiple (CLOS) |
| E9 Audience | ◐ programmers + Etoys | ◐ programmers build for users | ○ developers only | ● end users by design |
| E10 Multi-user deployment | ◐ via GemStone | ● GemStone/GLASS proven | ○ single-user | ◐ portal server |
| E11 LLM tractability | ○ arbitrary code | ◐ descriptions are regular | ○ arbitrary code | ◐ vocabulary-constrained |
| E12 Ecosystem | ◐ reduced | ◐ niche, proven | ◐ growing | ○ none |

Seed and the Smalltalk family are strongest in complementary areas. Smalltalk
excels at liveness, debugging, and proven deployment (E3, E4, E10). Seed excels
at medium independence, audience reach, and the structural properties that
follow from a constrained vocabulary (E7, E8, E9, E11). Magritte is the
strongest on verification (E2) — the gap that Seed most needs to close.


## Synthesis

### What Seed should adopt

**From Magritte: verified descriptions.**
Magritte's most important lesson is that metadata descriptions can be *checked*
against the objects they describe. A `MANumberDescription` for a property that
is actually a string is caught. A range constraint that specifies `min > max`
is caught. Seed's IS/AS/BY metadata is currently asserted without verification
— the gap identified in `SEED-DRAFT-editormodels` (criterion G2). Magritte
demonstrates that this gap is closable: the same descriptions that drive form
generation can also drive validation. Seed should build a metadata validator
that checks IS annotations against Lisp types, BY annotations against available
`generate` methods, and AS annotations against the surrounding structure.

**From Seaside: the web debugger.**
When a Seaside application errors during rendering, the developer can inspect
the full state, fix the method, and retry — without restarting. Seed's branch
pipeline should offer the same: when a `generate` method signals a condition,
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
mutable slots. The correction noted in the original discussion is important:
these objects can be held in variables, reconfigured between renderings, and
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

- **Metadata on data, not on classes.** Magritte describes classes; every
  instance shares one description. Seed describes individual values; two
  integers in the same structure can have different interaction modes. This
  per-value granularity is essential for write-time control and cannot be
  reduced to class-level description without losing expressiveness.
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
