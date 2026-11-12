---
id:            SEED-DRAFT-interfacemodels
title:         Interface Models and Data–Interface Unification
genre:         Survey
scope:         project
project:       Seed
language:      en
status:        Draft
provenance:
  assistant:   claude-opus-5-5
relates-to:
  - SEED-DRAFT-tripleontology
  - SEED-DRAFT-dxontologyupdate
cites:
  - title:     "CLIM II Specification"
    locator:   "Part VI: Extended Stream Input Facilities, §23 Presentation Types"
    external:  true
  - title:     "Naked Objects"
    locator:   "Pawson, R. PhD thesis, Trinity College Dublin, 2004"
    external:  true
  - title:     "Architectural Styles and the Design of Network-based Software Architectures"
    locator:   "Fielding, R. T. PhD dissertation, University of California, Irvine, 2000"
    external:  true
  - title:     "Boxer: A Reconstructible Computational Medium"
    locator:   "diSessa, A. A. and Abelson, H. Communications of the ACM 29(9), 1986"
    external:  true
  - title:     "The CAMELEON Reference Framework"
    locator:   "Calvary, G. et al. Deliverable D1.1, CAMELEON Project, 2002"
    external:  true
  - title:     "Live Functional Programming with Typed Holes"
    locator:   "Omar, C. et al. Proc. ACM Program. Lang. 3(POPL), 2019"
    external:  true
  - title:     "WAI-ARIA 1.2"
    locator:   "W3C Recommendation, 2023"
    external:  true
  - title:     "Glamorous Toolkit"
    locator:   "Girba, T. feenk.com"
    external:  true
  - title:     "Semiology of Graphics"
    locator:   "Bertin, J. University of Wisconsin Press, 1983 (French original 1967)"
    external:  true
open-questions:
  - SEED-DRAFT-interfacemodels-O1
  - SEED-DRAFT-interfacemodels-O2
  - SEED-DRAFT-interfacemodels-O3
  - SEED-DRAFT-interfacemodels-O4
---

# Interface Models and Data–Interface Unification: Survey

This document surveys the landscape of interface models — the ways that
software systems specify, derive, and present interactive surfaces — and places
Seed's self-describing data approach within that landscape. It asks whether
Seed's claim to a fourth degree of program control (write-time control) is
substantiated by comparison with prior art, and maps the open problems that the
approach inherits. The survey is exploratory and non-normative; it surfaces
questions for later Plans and Evals rather than prescribing answers.

The IS/AS/BY ontology and the manifestation pipeline documented in
SEED-DRAFT-tripleontology and SEED-DRAFT-dxontologyupdate are assumed as
context.


## Motivation

In most software systems, data and its interface are separate artifacts
maintained by separate processes. A database schema describes the data; a
component hierarchy describes the interface; a controller layer brokers between
them. Changes to the data model cascade through all three: the schema migrates,
the interface rewires, the controller adjusts. This coordination burden is the
dominant cost of routine application development, and each translation boundary
is a site of bugs.

Seed's architecture proposes that this separation is not inherent to the problem
but is an artifact of languages that represent data and code differently. In
Common Lisp, where code and data share the same representation, a datum can
carry its own interface specification as metadata (`fx` forms). The interface is
then *derived* from the metadata rather than *maintained* alongside it. The
question this survey asks is: how does this approach relate to prior work, and
what does the comparison reveal about its strengths, limits, and open problems?


## A Family-by-Family Map of Interface Models

The following sections group interface systems by the relationship they
establish between data and interface. Within each group, one or two
representative systems are described and their relevance to Seed is noted.

### Text Plus External Tools

The Unix model: data is stored as untyped byte streams; the interface to that
data is constructed by separate programs (editors, viewers, formatters) that
impose their own structure at read time. The user interacts with tools that
sit outside the data and know nothing about its semantics. This is the baseline
against which all richer models are measured.

**Relevance to Seed:** Seed's premise is the negation of this model. Where Unix
externalises the interface, Seed internalises it as metadata on the data.

### Direct Manipulation and Model–View–Controller

Xerox Star and Smalltalk-80 introduced the idea that on-screen objects are
first-class interactive entities rather than text renderings. The model–
view–controller (MVC) split that Smalltalk pioneered treats the interface as a
view computed from a model, with a controller handling user input. This
separated concerns cleanly but established the convention that model and view
are distinct artifacts — the very convention Seed questions.

**Relevance to Seed:** MVC is the architectural ancestor of the multi-layer
stacks (API, form, validation, component) that `fx` forms collapse. Seed
replaces the view and controller with derived manifestations and medium-
dispatched generate methods.

### Live Image Environments

Smalltalk, the Symbolics Genera system, Self/Morphic, and Tudor Girba's
Glamorous Toolkit (GT) treat the running system as an inspectable, modifiable
image. Objects can be examined and edited from any point; the boundary between
"using" and "programming" is thin. GT adds multiple typed views per object:
the same datum can be inspected as a list, a tree, a columned table, a Mondrian
diagram, or a text editor view, depending on what the inspector deems
appropriate.

**Relevance to Seed:** The multi-view principle directly informed the IS/AS/BY
design (SEED-DRAFT-tripleontology). Seed's medium dispatch is analogous to GT's
per-type inspector views, with the additional property that the view
specification travels with the data rather than being registered separately
on the inspector.

### Presentation-Based Interfaces (CLIM)

The Common Lisp Interface Manager (CLIM 2) assigns every piece of output a
*presentation type*. When an application writes an integer to a window, the
output is tagged as a presentation of type `integer`. When the application
subsequently asks the user for input of that type, the user can point at any
visible presentation of a matching type and click. Output becomes reusable
input; the display becomes a typed surface where every visible element carries
its semantic identity.

CLIM's type lattice (`integer` ⊂ `rational` ⊂ `real` ⊂ `number`; the
meta-types `or`, `and`, `completion`, `member`) is the closest ancestor of
Seed's IS axis. CLIM demonstrates that the intrinsic character of a value can
drive both its presentation and its sensitivity to interaction. It also
demonstrates the `accept`/`present` duality: a presentation type defines both
how a value is displayed and how a value of that type is solicited from the
user.

**Relevance to Seed:** IS is a direct descendant of CLIM's presentation type
lattice. The duality between `accept` and `present` maps onto the relationship
between `express` (building a manifestation tree from data) and `generate`
(rendering that tree through a medium). The key difference is that CLIM
presentation types are registered on the application's side, while Seed's IS
metadata travels with the individual datum.

### Interfaces Generated from a Model

Richard Pawson's Naked Objects thesis (Trinity College Dublin, 2004) proposed
that if business objects are *behaviourally complete* — each object knows not
just its data but its behaviours — then the user interface can be generated
automatically from the object definitions. The Naked Objects framework
demonstrated this: given a set of Java classes with attributes, associations,
and action methods, it produced a full interactive surface with drag-and-drop,
icon views, detail views, and action menus, with no interface code written by
the developer.

The thesis identified five forces that push developers away from behavioural
completeness: business process orientation, task-optimised user interfaces,
use-case-driven methodologies, MVC, and component-based development. It argued
that all five are considered best practice yet all hinder good object-oriented
design.

Django Admin and Rails scaffolding are partial realisations of the same idea:
given a model definition, generate a usable administrative interface. They
demonstrate both the utility and the limit — generated interfaces are
functional but often feel generic, and the escape path into customisation tends
to be all-or-nothing.

**Relevance to Seed:** Naked Objects is the strongest single influence on
Seed's design philosophy. The two-tier processor model
(SEED-DRAFT-tripleontology, decision SEED-DRAFT-tripleontology-D4) is Seed's
answer to the quality ceiling that pure auto-generation hits: Tier-1 defaults
provide the Naked-Objects-style automatic affordances, and Tier-2 `:adapting`
processors inject the domain-specific refinements that move a generic interface
toward a crafted one.

### Model-Based UI Research (CAMELEON)

The CAMELEON Reference Framework (Calvary et al., 2002) structures the
development of multi-target user interfaces as a four-level reification chain:

1. **Tasks and Domain** — what the user needs to accomplish and the concepts
   they manipulate.
2. **Abstract UI** — a canonical expression of renderings and interactions,
   independent of concrete interactors.
3. **Concrete UI** — an interactor-dependent expression for a specific toolkit,
   still a mockup.
4. **Final UI** — source code (Java, HTML, etc.) that runs on the target.

Transformations between levels (reification downward, abstraction upward,
translation sideways to another target) form the backbone of the framework.

**Relevance to Seed:** The CAMELEON chain maps almost directly onto Seed's
pipeline. IS/AS/BY annotations are the Tasks-and-Domain level. The manifestation
tree is the Abstract UI. The `generate` methods for a specific medium produce
the Concrete/Final UI in one step. The key difference is that CAMELEON treats
each level as a separate model with separate tooling, while Seed collapses the
first two levels: the data's own metadata *is* the abstract UI specification,
so there is no separate abstract-UI model to maintain.

### Schema-Driven Forms

XForms (W3C), JSON Schema forms, and various admin-UI generators (Retool,
Appsmith) derive input interfaces from schema definitions. Given a JSON Schema
describing an object's properties, types, constraints, and enumerations, a form
with appropriate input widgets can be generated automatically.

**Relevance to Seed:** Schema-driven forms are halfway to self-describing data.
They demonstrate that type metadata can drive interface derivation, but the
schema lives apart from the data — it is a separate artifact that must be kept
in sync. `fx` forms internalise the schema as metadata on the datum itself,
eliminating the sync problem.

### Declarative and Reactive UI

React (and its descendants: Elm, SwiftUI, Jetpack Compose) treat the interface
as a pure function of state. Given application state, a render function produces
a virtual DOM; the framework diffs and patches the real DOM. This model
separates the state (model) from the rendering (view) but makes the rendering a
deterministic transformation of the state — the view does not drift.

**Relevance to Seed:** The `generate` methods are Seed's analogue of a render
function: given a manifestation tree (the state), they produce a medium-specific
output tree. The difference is in where the rendering logic lives: React embeds
it in component code that the developer writes; Seed derives it from IS/AS/BY
metadata on the data, selecting render methods by generic function dispatch
rather than by explicit component selection.

### Hypermedia (REST and htmx)

Roy Fielding's REST dissertation (UC Irvine, 2000) defined the principle of
*hypermedia as the engine of application state*: a server response carries not
just data but also the links and forms through which the user can take further
action. An HTML form that includes its action URL, method, and input fields is
a self-describing interactive surface — the client needs no out-of-band
knowledge to use it.

htmx extends this: the server returns HTML fragments with embedded interaction
attributes (`hx-post`, `hx-trigger`, `hx-swap`), and the client library handles
partial-page updates without custom JavaScript. This is a form of
self-describing data in which the description is the HTML itself.

**Relevance to Seed:** Seed already uses htmx as its web-medium rendering
target. The connection is deeper than implementation: the principle that a
response should carry its own interaction affordances is the same principle
that `fx` forms apply to data at rest. Seed extends it by making the
affordances *medium-independent* (they derive from IS/AS/BY, not from
HTML-specific attributes) and *composable* (nested `fx` forms compose; nested
HTML forms do not).

### Structure Editors and Projectional Editors

The Cornell Program Synthesizer (1981), Interlisp's SEdit, JetBrains MPS,
Hazel (Omar et al., University of Michigan), and Unison all edit abstract
syntax trees rather than text. The user's actions are structural operations
(insert node, change type, wrap in abstraction); the visual presentation
is a projection of the underlying tree.

Hazel is notable for guaranteeing that every editor state is statically and
dynamically well-defined, using typed holes to enclose incomplete or
type-inconsistent sub-expressions. This eliminates the "meaningless editor
state" problem that plagues text-based environments.

MPS stores programs as a model (an AST database) and projects them through
configurable editors that can be domain-specific. The projection logic lives
in the editor, separate from the program.

**Relevance to Seed:** Seed's `fx` forms achieve a similar effect without a
dedicated structure editor. Because the data is an S-expression, `read`
provides structural parsing for free. Because the metadata specifies the
interaction profile, `express` produces a structural editor for that specific
data. The crucial difference: in MPS, the projection logic is configured in the
editor; in Seed, the projection logic is metadata on the data itself. The
program describes how it should be edited.

### Spreadsheets

The spreadsheet is arguably the most successful end-user programming
environment ever built. Data, formulas, and their visual presentation share a
single surface. Editing a cell is simultaneously modifying data, writing a
program (if the cell contains a formula), and seeing the interface update. The
boundary between "using" and "programming" is invisible.

**Relevance to Seed:** The spreadsheet demonstrates that collapsing the
data–interface boundary is viable and enormously productive. Seed aims for the
same collapse in a more general setting — structured data of any shape, not
just two-dimensional grids of cells. The `:provision-sheet` modality
(SEED-DRAFT-dxontologyupdate) is Seed's way of hosting the spreadsheet pattern
within the manifestation framework.

### Malleable Software and End-User Environments

HyperCard (Apple, 1987), Boxer (diSessa and Abelson, MIT/Berkeley, 1986),
Ink & Switch's malleable software research, Notion, and Airtable represent a
line of work where the end user can modify the structure and behaviour of the
software they use.

Boxer is particularly relevant: it treats computation as a reconstructible
medium, where every element — text, graphics, data, programs — is a box that
can be opened, moved, edited, and reorganised. The principles of the *spatial
metaphor* (computational structures are represented as nested boxes) and
*naive realism* (what you see is what exists computationally) give Boxer a
directness that conventional programming environments lack. Boxer explicitly
aimed to make programming an everyday activity for non-experts — "a
reconstructible medium, much like written language, but with dramatically
extended interactive capabilities."

**Relevance to Seed:** Boxer's naive realism — "the user should be able to
pretend that what they see on the screen is their computational world in its
entirety" — is the aspiration that `fx` forms serve. When `express` derives
an interface from a data structure's own metadata, and edits through that
interface write back to the data, the user's view *is* the computational
reality. The difference is that Boxer built this into its own language and
environment, while Seed builds it as a library within Common Lisp.

### Notebooks

Jupyter, Observable, Wolfram Mathematica notebooks, and Lepiter (part of
Glamorous Toolkit) interleave code, rich output, and narrative. Mathematica
is especially notable: its "everything is an expression" design means that
notebooks are themselves expressions, and `Manipulate` builds interactive
widgets from them. A notebook cell can contain a slider that manipulates a
parameter of a computation, and the slider, the parameter, and the computation
are all part of the same expression tree.

**Relevance to Seed:** Mathematica's `Manipulate` is the strongest external
parallel to what `fx` forms do: a value with metadata that specifies its
interaction surface, embedded in a computational expression. The difference is
that Mathematica's `Manipulate` is a special form within a closed system,
while Seed's `fx` is a general-purpose annotation mechanism built on standard
Common Lisp reader macros, open to extension. And Mathematica notebooks are
tied to the Mathematica front end; Seed's IS/AS/BY annotations are
medium-independent.

### Accessibility Trees (ARIA)

WAI-ARIA defines a vocabulary of roles (`widget`, `structure`, `landmark`,
`input`, `composite`) that describe an element's semantic function in an
interface, separate from its visual rendering. An accessibility tree is a
second interface, derived from the same source, projected through a different
medium (a screen reader rather than a visual display).

**Relevance to Seed:** ARIA's role vocabulary directly informed the AS axis of
the IS/AS/BY ontology (SEED-DRAFT-tripleontology). ARIA also demonstrates that
medium dispatch is already an established pattern: the same semantic structure
is projected visually for sighted users and audially for screen-reader users.
Seed's `uim-web` / `uim-terminal` dispatch is the same idea, extended beyond
accessibility to general-purpose multi-medium rendering.


## Axes of Comparison

The following table compares the families on six axes that illuminate where
Seed's approach differs from prior work.

Table: Comparison of interface models along six axes.

| Family | Spec lives | Author | Binding time | Medium-independent | Edits round-trip | Composition level |
|--------|-----------|--------|-------------|-------------------|-----------------|------------------|
| Text + tools | External tool | Programmer | Run time | No | N/A | N/A |
| MVC / component | Component code | Programmer | Compile/run | Partially (via abstraction layers) | No | Code |
| Live image | Inspector / class | Programmer | Run time | No (environment-specific) | Yes (image persistence) | Object |
| CLIM presentations | Presentation-type methods | Programmer | Run time | No (CLIM streams) | Partially (accept/present) | Type lattice |
| Naked Objects | Domain class | Programmer | Run time | No (Java framework) | N/A (views generated) | Object |
| CAMELEON | Separate models per level | Designer/tool | Design/run | Yes (by design) | Only via abstraction | Model |
| Schema-driven forms | External schema | Programmer | Run time | No (web-specific) | No | Schema |
| Reactive UI | Component render function | Programmer | Compile/run | Partially (cross-platform frameworks) | No | Virtual DOM |
| Hypermedia / htmx | Response document | Server code | Run time | No (HTML-specific) | Server round-trip | Document fragment |
| Structure / projectional editors | AST + editor config | Tool author | Edit time | No (editor-specific) | Yes (AST is source) | AST node |
| Spreadsheets | Grid cell | End user | Run time | No (spreadsheet app) | Yes (cell = source) | Cell |
| Boxer | Box structure | End user | Run time | No (Boxer environment) | Yes (box = source) | Box |
| Notebooks / Mathematica | Notebook expression | Programmer/user | Run time | No (Mathematica front end) | Yes (expression = source) | Expression |
| ARIA / accessibility | Semantic attributes | Programmer/tool | Run time | Yes (medium is the point) | No | Attribute |
| **Seed (fx/dx)** | **Data's own metadata** | **Programmer** | **Write time** | **Yes (medium dispatch)** | **Yes (express/philo)** | **Data** |

Four of Seed's column values are distinctive in combination:

1. **Spec lives in the data's own metadata.** No external schema, no separate
   model, no editor configuration. The specification travels with the datum.
2. **Write time binding.** The programmer specifies the interaction surface at
   the moment of writing the data. This is earlier than run time (when the
   interface is rendered) and later than compile time (when macros expand). The
   write-time specification persists as metadata and is available to every
   subsequent phase.
3. **Medium-independent.** The IS/AS/BY annotation describes the what, why, and
   how of interaction without committing to a rendering target. The medium's
   `generate` methods choose the concrete output.
4. **Edits round-trip.** Changes made through the derived interface write back
   to the S-expression source (via `philo` or `(setf philo)`) because the
   source and the runtime data share the same representation. The interface is
   not a projection from which there is no return.


## The Degrees of Program Control

The claim that Seed introduces a fourth degree of program control can now be
calibrated against the landscape.

**Run time** — every language gives you this. The program describes what
happens when executed.

**Compile time** — macros (in languages that have them) let you transform code
before execution. Common Lisp macros operate with full generality; other
languages offer limited forms (generics, annotations, template metaprogramming).

**Read time** — reader macros let you control how text becomes data structures
before macros even begin. This is nearly unique to Lisp. Seed uses it in
`seed.sublimate`, where the `fx` reader intercepts opening parentheses and
resolves `(fx ...)` forms at read time.

**Write time** — the programmer annotates data at the point of authorship with
metadata that controls how it will be expressed, interacted with, and
processed. The annotation persists with the data and governs every downstream
phase. This is what `fx` forms do.

### Calibrating the claim

Smalltalk, Genera, MPS, and Mathematica each provide some write-time control.
Smalltalk's image persistence means that changes made through the inspector
persist. MPS's projectional editor lets the developer edit structure through
domain-specific views. Mathematica's `Manipulate` lets the user build
interactive widgets inline.

Seed's distinct claim is narrower and more defensible: **the authoring
interface is specified in the program's own data representation, produced by the
same pipeline that renders the program's other interfaces, and writes back to
the same source format.** In MPS, the projection logic lives in the editor
configuration, not in the program. In Mathematica, `Manipulate` lives in the
notebook system, not in general-purpose Lisp data. In Smalltalk, the inspector
is a generic tool, not a data-specific derived interface. Seed is the system
where the data's own metadata specifies its editing surface, and that metadata
is ordinary data in the same representation as the rest of the program.


## Matching Tasks to Software Structure

The landscape of how computing systems match tasks to software structure reveals
a spectrum from atomic tools to complete domain systems.

### Atomic tools joined by untyped glue (Unix)

Small, single-purpose utilities communicate through pipes carrying untyped byte
streams. The philosophy is "do one thing well," but as noted in the Motivation,
the substrate violates the philosophy. The byte stream does nothing in
particular, deferring all structure to applications. The shell absorbs the
incoherence — it provides iteration, conditionals, job control, and text
processing through an accreted syntax with no coherent topology. The coherence
of the utilities is purchased by sacrificing coherence at the substrate.

The genuine strength: the pipe is a *narrow waist*, the same role IP plays in
networking. Any tool can pipe to any tool because the interface is trivially
simple. This universality is real value, however incoherent the substrate.

### Typed pipelines

PowerShell passes .NET objects through the pipeline instead of text. Nushell
passes structured tables. These are direct responses to the untyped-byte-stream
critique: the interchange format carries structure, so downstream tools can
access fields by name rather than parsing text with regular expressions.

**Relevance to Seed:** Typed pipelines demonstrate that the untyped byte stream
is not necessary for composability. But they solve only the inter-process
communication problem; the data–interface separation within each tool persists.

### Structured operating-system layers

IBM System Z's VSAM (Virtual Storage Access Method) provides keyed, indexed,
and sequential access at the operating-system level. Applications inherit
storage management rather than reimplementing it. IBM i (formerly AS/400) goes
further with a single-level store where every object is persistent and typed.

These systems show that the substrate *can* do real work. The cost is coupling
to a specific platform; the benefit is that every application built on that
platform inherits the structure and doesn't have to reimplement it.

**Relevance to Seed:** Seed's S-expression file format and `philo` accessor
are a micro-scale analogue: they provide keyed, positional access to structured
data in files, freeing branches from reimplementing file I/O. The difference
is that Seed's substrate is a library within a general-purpose language, not
an operating-system facility.

### Single-language systems

Genera (Symbolics Lisp Machine), Oberon (Wirth), and Smalltalk images are
environments where a single language serves as the operating system, the
development environment, and the application platform. Everything is accessible
and modifiable from within the language.

**Relevance to Seed:** Seed aspires to this within the interface domain but not
as a general-purpose OS. The IS/AS/BY ontology governs interface specification
comprehensively, but Seed does not try to replace the filesystem, the network
stack, or the window manager.

### Domain-comprehensive systems

Spreadsheets (tabular data and computation), CAD systems (geometric design),
Mathematica (symbolic and numeric computation), APL/April (array-oriented
computation), and Seed (interface specification and rendering) are each
comprehensive for one domain. They allow the full range of functionality
within that domain while not absorbing unrelated concerns.

The discipline that distinguishes a domain-comprehensive system from a
monolithic application is *deliberate boundary placement*. A spreadsheet does
not try to be a word processor; Mathematica does not try to be a web framework;
Seed does not try to be an array-computation system. Each system is
comprehensive *within* its domain and delegates *outside* it.

### The composition question

If each domain gets its own comprehensive system, how do domains compose? Unix
solves this trivially (the byte stream) at the cost of losing structure. Typed
pipelines solve it partially (structured objects) at the cost of requiring a
shared type system. The question for Seed's approach: can S-expressions with
IS/AS/BY metadata serve as a structured interchange format between domain
systems?

The candidate answer is in the branch/adapter model: domains compose through
normalised message-passing between branches, where adapters mediate the
boundaries. Seed and April compose not by sharing an untyped byte stream but by
one domain's output being structured input to another, with the structure
preserved because both speak S-expressions. The interchange format carries
types and metadata rather than uninterpreted bytes.

The trade-off is explicit: universality-through-triviality (Unix) versus
composability-through-shared-structure (S-expressions). The latter is more
robust within a coordinated ecosystem and potentially less interoperable with
arbitrary external tools. This is likely the right trade for a family of
systems under common development, but it is a constraint worth acknowledging.


## The Deeper Claim

What the comparison reveals is that Seed's architecture addresses a specific
structural problem: **the artificial separation of data from its interface.**
Most of the accidental complexity in modern application development — the
proliferation of representations, the coordination burden of model changes, the
platform-specific reimplementation of the same interactive patterns, the
impedance mismatch between storage and presentation — stems from treating data
and interface as fundamentally different concerns that must be bridged by layers
of translation.

CLIM showed that presentation types on output make the display a typed,
interactive surface. Naked Objects showed that behaviourally complete domain
objects can derive their own interface. CAMELEON showed that a chain of
reification from abstract to final UI can target multiple platforms. Boxer showed
that a computational medium can be directly reconstructible by its users.

Seed synthesises these insights under a single design: data carries three-axis
metadata (IS/AS/BY); that metadata drives a generic expression pipeline; the
pipeline targets any medium through method dispatch; and edits through the
derived interface write back to the source. The system is not unprecedented in
any single axis — it is, rather, the unification of axes that prior systems
explored separately.


## Honest Limits

**The quality ceiling.** Automatically derived interfaces tend to feel generic.
Naked Objects and Django Admin both demonstrated that while generated interfaces
are functional, they rarely match the quality of hand-crafted ones. Seed's
`:adapting` processors are the intended answer — named postprocessors that let
branch code inject domain-specific refinements — but this mechanism is new and
unproven at scale. The risk is that the escape hatch becomes the default, and
the programmer ends up writing as much adaptation code as they would have
written interface code.

**Fidelity of round-tripping.** When an edit through a derived interface writes
back to an S-expression file via `philo`, the reprinted forms are downcased,
comments within replaced ranges are not preserved, and whitespace may change.
This is a documented, accepted contract, but it means the round-trip is
*functionally* faithful (the data is correct) without being *textually*
faithful (the source may look different). For collaborative development where
source formatting matters, this is a real friction point.

**Vocabulary richness.** The IS/AS/BY vocabulary must be rich enough to describe
the full range of interactive surfaces that applications need. If the vocabulary
is too narrow, developers fall back to medium-specific code, defeating the
purpose. If it is too broad, it becomes a DSL as complex as the component
code it replaces. Finding the right vocabulary size is an ongoing design
challenge, and the vocabulary's current state is explicitly provisional.

**Security of write-time control.** If the interface derived from `fx` metadata
writes back to S-expression source files, then a user interacting with the
interface is effectively modifying the program. In a multi-user system, this
raises access-control questions that Seed's current `seed.access` module
addresses only at the branch level, not at the individual-field level.

**Language coupling.** The approach depends on homoiconicity (code and data
share representation), reader macros (context-dependent interpretation at read
time), and generic functions (medium dispatch). These are available in Common
Lisp; they are structurally unnatural in most other languages. This is not a
flaw — it is a legitimate trade-off — but it limits the approach's portability.

**Unproven multi-medium rendering.** The `uim-terminal` class exists but has no
`generate` methods. The claim that IS/AS/BY annotations are medium-independent
has been validated only for `uim-web`. The architecture supports it, but the
proof is incomplete.


## Relationship to Other Work

Within the Seed corpus, this survey relates to:

- SEED-DRAFT-tripleontology — the design and implementation of the IS/AS/BY
  ontology, including the five-source research (CLIM, ARIA, Naked Objects, GT,
  Bertin) that this survey expands upon.
- SEED-DRAFT-dxontologyupdate — the extension of IS/AS/BY to `(dx)` forms,
  provisioning, and layout, which realises the "same ontology for data at rest
  and data in motion" principle this survey discusses.
- SEED-0001 — the keyed accessor that enables round-trip editing,
  which this survey cites under the round-tripping limitation.
- SEED-0002 — the tutorial for `philo`, the accessor that
  implements the round-trip.

External work cited is listed in the front-matter `cites:` block.


## Open Questions

### SEED-DRAFT-interfacemodels-O1 — Can IS/AS/BY serve as a narrow waist for inter-domain composition?

The Unix byte stream is universal because it is trivial. S-expressions with
IS/AS/BY metadata are richer but require agreement on the vocabulary. Can the
IS/AS/BY vocabulary be designed to serve as a shared interchange format between
domain-comprehensive systems (Seed, April, and any future systems), or will each
domain inevitably need its own vocabulary extension, recreating the translation
problem at a higher level?

### SEED-DRAFT-interfacemodels-O2 — How do derived interfaces reach hand-crafted quality?

The `:adapting` processor model lets branch code inject domain-specific
refinements into a derived interface. What is the practical ratio of automatic
derivation to manual adaptation in a real application, and does the processor
model keep that ratio favourable — or does it tend toward "mostly manual" as
applications grow more complex?

### SEED-DRAFT-interfacemodels-O3 — Which media should be targeted after the web?

`uim-terminal` is the obvious next medium. Beyond that: native desktop widgets,
mobile, API generation, print/PDF, and accessibility (screen reader). Which
medium would most strongly validate the medium-independence claim, and which
would most usefully serve real users?

### SEED-DRAFT-interfacemodels-O4 — How should vocabulary growth be governed?

The IS/AS/BY vocabulary is explicitly provisional and open-ended. As it grows
from usage, what prevents it from becoming an unwieldy DSL? Should there be a
formal extension mechanism (namespace-scoped vocabulary additions), a review
process, or a maximum vocabulary size beyond which new terms must replace
rather than supplement existing ones?
