---
id:            SEED-0007
title:         "Abstraction Verticality, Leverage Pyramids, and the LLM Inflection"
genre:         Survey
scope:         program
project:       Seed
language:      en
status:        Accepted
authors:
  - Andrew Sengul
approved-by:   Andrew Sengul
reviewed:      2026-11-12

provenance:
  assistant:   claude-opus-5-5
relates-to:
  - SEED-0005
  - SEED-0006
  - SEED-0003
  - SEED-0004
  - SEED-0008
  - SEED-DRAFT-branches
  - SEED-DRAFT-classicinterface
cites:
  - title:     "The Mythical Man-Month"
    locator:   "Brooks, F. P. Addison-Wesley, 1975; Anniversary Edition, 1995. Ch. 3: The Surgical Team"
    external:  true
  - title:     "No Silver Bullet — Essence and Accident in Software Engineering"
    locator:   "Brooks, F. P. Proc. IFIP Congress, 1986"
    external:  true
  - title:     "How Do Committees Invent?"
    locator:   "Conway, M. E. Datamation 14(5), April 1968"
    external:  true
  - title:     "Exploratory Experimental Studies Comparing Online and Offline Programming Performance"
    locator:   "Sackman, H., Erikson, W. J. and Grant, E. E. Communications of the ACM 11(1), January 1968"
    external:  true
  - title:     "A Small Matter of Programming: Perspectives on End User Computing"
    locator:   "Nardi, B. A. MIT Press, 1993"
    external:  true
  - title:     "Programs, Life Cycles, and Laws of Software Evolution"
    locator:   "Lehman, M. M. Proc. IEEE 68(9), September 1980"
    external:  true
  - title:     "The Rise of Worse is Better"
    locator:   "Gabriel, R. P. AI Expert 6(6), June 1991; originally part of 'Lisp: Good News, Bad News, How to Win Big'"
    external:  true
  - title:     "Notation as a Tool of Thought"
    locator:   "Iverson, K. E. Communications of the ACM 23(8), August 1980 (1979 Turing Award Lecture)"
    external:  true
  - title:     "Beating the Averages"
    locator:   "Graham, P. paulgraham.com, April 2001"
    external:  true
  - title:     "The Lisp Curse"
    locator:   "Winestock, R. winestockwebdesign.com/Essays/Lisp_Curse.html, April 2011"
    external:  true
open-questions:
  - SEED-O6
  - SEED-O7
  - SEED-O8
  - SEED-O9
  - SEED-O10
---

# Abstraction Verticality, Leverage Pyramids, and the LLM Inflection: Survey

This document surveys the argument that vertically integrated software
abstraction — where each layer builds on the previous one and multiplies the
productivity of the layer above — produces a fundamentally different
organisational shape than the flat, coordination-heavy pyramid that conventional
software stacks impose. It examines the historical asymmetry between hardware
and software verticality in technology vendors, the incentive structure that
sustains that asymmetry, and how large language models may change the calculus.
The survey is exploratory and non-normative; it asks whether these arguments
hold up, and if so, what they imply for Seed's priorities.


## Motivation

Seed's architecture is designed around a tiered model of users. At the base, a
small number of core developers maintain the IS/AS/BY vocabulary, the component
hierarchy, the `generate` methods, and the medium dispatch. A larger group of
system developers compose these primitives into domain-specific `fx`-annotated
data and branch pipelines. A much larger group of configurators interact with
the derived interfaces — editing parameters, managing data, adjusting views —
without writing code. The largest group are end users, who interact with the
final rendered interfaces.

This structure is intended to produce a power-law relationship: each tier
multiplies the productivity of the next, so that a small number of core
developers can support an exponentially larger population of system developers,
configurators, and users. The question is whether this aspiration is realistic,
what prior art supports or undermines it, and what conditions must hold for it
to work.

A secondary question runs through the discussion: why has this kind of
vertically integrated software abstraction been so rare in practice, given that
the hardware industry demonstrates the value of vertical integration routinely?


## The Verticality Asymmetry

### Hardware verticality is routine

IBM's System Z integrates custom processors, custom I/O channels, custom
interconnects for sysplex coupling, and workload management that dynamically
orchestrates the whole stack. Apple's M-series silicon integrates CPU, GPU,
Neural Engine, memory controller, and media engines in a unified memory
architecture. Both companies invest heavily in vertical integration because
it produces capabilities that horizontal composition of commodity parts cannot
replicate: lower latency, higher throughput, emergent properties from tight
coupling.

In both cases the vendor absorbs the complexity. The customer buys a mainframe
or a laptop and receives the benefits — faster transactions, longer battery
life — without needing to understand the custom I/O channel architecture or the
unified memory design.

### Software verticality is rare

The same vendors drive this integrated hardware with conventional software
stacks. IBM's application programming model is COBOL, PL/I, Java, and now
Python. Apple's is Swift/Objective-C with UIKit/SwiftUI. Neither invests in
software that vertically integrates abstraction the way their hardware
vertically integrates physical components.

The exceptions — IBM's historical investment in APL, Xerox PARC's Smalltalk,
Symbolics Lisp Machines — each offered dramatic capabilities but failed to
achieve broad adoption. APL programs could be far more concise than COBOL for
analytical work — Iverson's Turing Award lecture, "Notation as a Tool of
Thought" (1979), argues that a well-designed notation is itself an instrument
of thought — yet APL ended up a specialist tool, used mainly for analytical
and financial work. Smalltalk's image-based development
was ahead of its time; the commercial Smalltalk market collapsed. Symbolics
produced some of the most productive programming environments ever built; the
company went bankrupt.

### Why the asymmetry: who bears the cost

The structural reason is that hardware verticality and software verticality
impose their costs on different parties.

**Hardware verticality** costs the manufacturer. The engineering investment,
the fabrication, the design complexity — all are borne by the vendor. The
customer experiences only the benefits. The complexity is inside the box.

**Software verticality** costs the user. A system like APL, Lisp, or Seed
requires the programmer to internalise the abstraction's own concepts before
they can benefit. There is no way to hide a software abstraction's complexity
inside a box — the abstraction *is* the interface, and the user must learn it.

This creates a characteristic adoption curve. Hardware verticality has immediate
payoff: plug in the machine, run existing workloads faster. Software verticality
has deferred payoff: invest weeks or months learning the abstraction, then
eventually become dramatically more productive. Businesses discount the future,
staff turns over (making individual cognitive investments risky), and the
benefit of software verticality is hard to measure. The interface-models Survey
(SEED-0005) makes the same point from the other side under "A higher floor":
Processing wins beginners because a few lines draw something at once, while an
interface derived from declarations asks for an ontology to be learned first.

### Design pressure

Hardware's permanence forces careful design. Once the silicon is taped out, it
must be correct. This forces "Manhattan Project" levels of investment in getting
the abstractions right. Software's mutability removes this pressure. You can
always ship a patch, refactor next quarter, add another layer of indirection.
The consequence is that software design is chronically undervalued relative to
software execution.

Apple's iTunes is a canonical example. It started as a simple music player and
accumulated music purchasing, device syncing, podcast management, app
distribution, movie/TV purchasing, audiobook management, radio streaming, and
backup functionality, each added incrementally because software mutability made
it possible to "just add one more thing." There was never a moment where someone
had to commit to a unified design the way IBM committed to the System/360
instruction set. The result was a system where no coherent abstraction underlay
the accumulated features. Apple eventually responded by breaking iTunes into
separate Music, TV, and Podcasts apps in 2019 — evidence that the entropy was
recognised, and that the resolution was decomposition rather than abstraction.

Lehman's laws of software evolution formalise this. His law of increasing
complexity (1980) reads: "As an evolving program is continually changed, its
complexity, reflecting deteriorating structure, increases unless work is done
to maintain or reduce it."
Software verticality is precisely the work that reduces complexity, and it is
precisely the work that software's mutability lets organisations defer.


## Incentive Hypotheses

The rarity of software verticality is not explained by cost alone. There are
structural incentives that actively resist it. The following are framed as
hypotheses — they attribute motives to market participants and should be tested
against counter-evidence rather than taken as established.

### The consultation economy

**Hypothesis:** Vendors whose services revenue depends on customer friction are
not incentivised to reduce that friction through better abstractions.

A mainframe running COBOL programs that must be manually coded, manually tested,
and manually deployed creates steady demand for consulting, training, and
support contracts. If a customer could express workflow changes in a high-level
symbolic language and see them running within hours instead of weeks, the
consulting engagement shrinks from a multi-month project to a single afternoon
with one person.

**Counter-evidence:** IBM is now actively selling LLM-based tooling (watsonx
Code Assistant for Z) that translates COBOL to Java, directly reducing the
labour that the hypothesis says it protects. This suggests the consultation
economy is not a monolithic strategy but a set of incentives that shift when new
revenue sources (AI tooling licenses) appear.

### The fungibility preference

**Hypothesis:** Employers, staffing firms, and platform vendors prefer
interchangeable developers because it reduces key-person risk, simplifies
hiring, and creates downward wage pressure through large supply.

A system like Seed that enables individuals with deep understanding of an
abstraction tower to achieve outsized leverage threatens these interests. It
concentrates productive power in a small number of people rather than
distributing it across a large interchangeable workforce.

The hypothesis has been stated before. Winestock's "The Lisp Curse" (see
below) quotes Stanislav Datskovskiy: "Employers much prefer that workers be
fungible, rather than maximally productive." Winestock accepts the maxim but
argues that it does not fully explain Lisp's low adoption, which he attributes
more to the social effects of Lisp's own expressive power.

**Counter-evidence:** The software industry does pay large premiums for rare
expertise (kernel developers, compiler engineers, machine-learning researchers).
The preference for fungibility coexists with the reality that some roles
are irreducibly specialised. The question is whether "abstraction-tower
maintainer" can become a recognised specialisation the way "compiler engineer"
is, rather than being perceived as an idiosyncratic dependency.

### The management practice assumption

**Hypothesis:** Project management practices assume labour substitutability.
You plan in developer-hours, estimate velocity by team size, manage risk through
redundancy of personnel. Deep abstraction creates dependencies that these tools
cannot mitigate.

**Counter-evidence:** Brooks's surgical team model, proposed in *The Mythical
Man-Month* (1975) and based on Harlan Mills's chief programmer team, explicitly
organises work around a single highly skilled programmer supported by
specialists. The model was proposed precisely because adding people to a late
project makes it later — the communication overhead of a large team can exceed
the work it produces. The surgical team is the management-practice precedent for
the leverage pyramid, and it predates Seed by half a century.


## The Leverage Pyramid

### The four tiers

Seed's tiered model:

1. **Core developers** (smallest tier) maintain the IS/AS/BY vocabulary, the
   role system, the component hierarchy, the medium dispatch, and the pipeline
   stage library. They work at the level of the abstraction tower itself.
2. **System developers** (larger) compose existing vocabulary into
   domain-specific `fx`-annotated data and branch pipelines. They use the
   vocabulary; they do not define it.
3. **Configurators / analysts** (much larger) interact with the derived
   interfaces — editing parameters through fields and selects, managing graph
   structures, modifying spreadsheet data. They are programming (modifying
   source data through write-time interfaces) without knowing they are
   programming.
4. **End users** (largest) interact with the final rendered interfaces.

### Tower versus shelf

In a conventional stack, the layers sit beside each other rather than building
on each other. A component library, a state management library, an API
framework, and a database ORM each reduce some work but do not multiply the
developer's fundamental leverage. A senior engineer using React + Node +
PostgreSQL is not dramatically more leveraged than a mid-level one — they are
doing the same kind of work with more experience.

Brooks's "No Silver Bullet" (1986) sets the bar any tower must clear. Brooks
separates *essential* complexity, inherent in the problem, from *accidental*
complexity, introduced by the tools, and argues that "there is no single
development, in either technology or management technique, which by itself
promises even one order-of-magnitude improvement within a decade in
productivity, in reliability, in simplicity." Shelf-style libraries chip away
at accidental complexity one concern at a time. The tower's claim is
different: that a shared vocabulary removes a whole class of accidental
complexity — the translation between data and interface — at once. Brooks's
argument is the reason that claim needs evidence rather than assertion
(principle 6, below).

Conway's law predicts this. In Conway's 1968 paper: "organizations which
design systems (in the broad sense used here) are constrained to produce
designs which are copies of the communication structures of these
organizations." A flat team of interchangeable developers working with shelf-style
libraries produces a shelf-style architecture. A tiered organisation with
differentiated roles — vocabulary designers, system composers, configurators —
would produce a tower-style architecture. The implication is that the leverage
pyramid requires not just a software architecture but an organisational design
that matches it.

### Prior art: tiered ecosystems

The leverage pyramid already exists in several domains:

- **Spreadsheets.** Nardi's *A Small Matter of Programming* (1993) describes
  "local developers" and "gardeners" who support colleagues in spreadsheet and
  CAD communities — people who are not professional programmers but who
  configure and extend tools for their workgroups. This is the configurator
  tier, observed in the wild decades before Seed.
- **Salesforce.** Administrators configure the platform through a declarative
  interface; developers write Apex code for custom logic; end users interact
  with the configured application. The three tiers are explicit and formalised.
- **SAP customisation.** Consultants configure the ERP system through tables
  and transaction codes; ABAP developers write extensions; end users interact
  with the configured screens.
- **Game engines.** Unreal Engine's visual scripting (Blueprints) lets
  designers compose game logic without writing C++. Level designers place and
  configure assets. Players interact with the result. Each tier is supported
  by tooling native to its work.
- **Emacs.** Package authors write Emacs Lisp extensions; power users configure
  through `init.el` and `defcustom`; casual users interact with the configured
  editor.

In each case, the leverage comes from the lower tier's work being expressed in a
form that the upper tier can consume without understanding its internals.

### The productivity variation

Sackman, Erikson, and Grant (1968) measured large performance variations between
programmers on the same task. The finding has been replicated and debated for
decades; the magnitude is contested, but the existence of substantial variation
is not. What matters for the leverage-pyramid argument is not the raw ratio but
the observation that a well-designed abstraction can make the effective
difference *larger* — a core developer who designs a good vocabulary multiplies
the output of every system developer who uses it, in a way that no amount of
skill at writing boilerplate code can replicate.


## Whole-System Thinkers and the Cognitive Economy

### The thinkable system

A vertically integrated abstraction tower is a system that can be held in one
mind. A person can understand Seed from the reader macro (`sublimate`) through
the metadata vocabulary (`fx` forms) through the manifestation pipeline
(`modulate2`) through the medium dispatch (`generate`/`render`) as a coherent
intellectual structure. Each layer builds on the previous one in a way that
rewards deep understanding.

Paul Graham's "Beating the Averages" (2001) makes the practitioner's case for
this kind of leverage. He credits Lisp with letting a small team build Viaweb
faster than competitors, and describes the "Blub paradox": a programmer fluent
in a less powerful language cannot see what a more powerful one offers,
because they think in the weaker language's terms. The paradox cuts both ways
for Seed. It explains why the tower's leverage is hard to see from outside, and
it warns that the tower's builders may be equally blind to what they lack.

This is not true of a conventional stack. No single person fully understands
React + webpack + TypeScript + Node + Express + PostgreSQL + Docker +
Kubernetes as a coherent whole, because it is not one. The pieces are
independently designed, independently versioned, and independently documented.
Mastery of one piece does not compound into mastery of the others.

### Key-person risk

The obvious objection: if the system depends on a small number of whole-system
thinkers, it is fragile. If a core developer leaves, the tower loses its
maintainer.

This is a real risk, and it is the principal reason organisations resist deep
abstraction. Mitigations include:

- **Documentation.** Compass itself is a response to key-person risk: the
  Logs, Surveys, Evals, and Refs that document a system's decisions, rationale,
  and architecture are insurance against the loss of the people who made those
  decisions.
- **LLM-assisted continuity.** If the abstraction's vocabulary is well-defined
  and the LLM can operate within it, the tower does not collapse when a person
  is unavailable — the LLM can perform routine operations within the
  established abstractions.
- **Progressive revelation.** If each layer is discoverable from the one above,
  new whole-system thinkers can develop from within the existing team. The
  system's own structure guides the learning path.

### The Lisp Curse

There is a counterweight to the superprogrammer argument. Rudolf Winestock's
essay "The Lisp Curse" (2011) argues that "Lisp is so powerful that problems
which are technical issues in other programming languages are social issues in
Lisp": its expressive power encourages lone experts to build personal
solutions rather than collaborating on shared ones, fragmenting the community
into incompatible fiefdoms. The same leverage that
makes a superprogrammer productive makes them self-sufficient enough to not need
collaboration — and the ecosystem suffers.

Gabriel's "Worse is Better" (1991) makes a related point: simpler but less
powerful designs spread faster because they are easier to adopt and to build
upon collaboratively. A "right thing" design may be more powerful but takes
longer to build, attracts fewer contributors, and dies in isolation.

These are genuine risks for Seed. A system that rewards depth over breadth may
produce brilliant individual work and a fragmented community. The mitigations
are the same as for key-person risk: documentation, shared vocabulary, and
tooling (including LLMs) that lower the barrier to participation without
lowering the abstraction ceiling.


## Design Pressure Without Permanence

Hardware's permanence forces careful design. Software's mutability removes that
pressure. Seed introduces a substitute: **self-referential feedback**.

When the metadata vocabulary is used to generate interfaces, and those
interfaces are used to edit the data that contains the metadata, errors in the
vocabulary design are immediately visible as broken or incoherent interfaces.
The system provides feedback on its own design quality through its own
operation. A poorly conceived `fx` annotation produces an awkward or wrong
interface. A component with no `generate` method fails visibly: the catch-all
method hands it to the other grammar's renderer, and if neither can render it,
the bounce guard turns it into a clean error (SEED-0003). A gap in the
component hierarchy leaves data unpresented.

This is different from conventional software, where design flaws can hide behind
layers of workarounds indefinitely. In Seed, the tight coupling between design
quality and operational quality creates a pressure toward coherence that
mutability alone would not provide.

The feedback is real but limited. It catches *structural* flaws (missing methods,
incoherent metadata) but not *semantic* flaws (a well-formed annotation that
describes the wrong thing). The editor-models Eval
(`SEED-0006`) found that Seed's metadata is asserted rather than
checked — a verification layer would close this gap and make the self-referential
feedback stronger.


## LLMs at Each Tier

### Constraint and checkability

At every tier, a well-designed abstraction constrains what an LLM can generate
and makes the output structurally checkable:

- **Core developers + LLMs:** The model assists with implementing new `generate`
  methods, new vocabulary entries, new pipeline stages. These follow established
  patterns (generic-function methods, class definitions, middleware contracts).
  The output is verifiable against the existing architecture.
- **System developers + LLMs:** The model generates `fx`-annotated data and
  branch pipelines from domain descriptions. The output must conform to the
  IS/AS/BY grammar and can be checked structurally.
- **Configurators + LLMs:** The model operates *through* the derived interfaces,
  making structured edits to `fx` data via the same affordances human
  configurators use. The action space is constrained by the metadata to only
  valid operations.
- **End users + LLMs:** The model acts as a conversational interface,
  translating natural-language requests into structured operations at the
  appropriate tier.

### Counter-hypotheses

The optimistic picture deserves stress-testing:

1. **Training-data scarcity.** Common Lisp has far less training data than
   Python or JavaScript. LLMs are weaker at it. Supplying the vocabulary in
   context (as Compass's own skills do) partly offsets this, but does not
   eliminate the gap.
2. **Cheap conventional code.** LLMs may make low-abstraction code so cheap to
   produce that the leverage gap narrows. If a model can generate a React form
   in seconds, the advantage of deriving it from metadata diminishes — unless
   the maintenance and evolution costs still favour the self-describing
   approach.
3. **Verification is the bottleneck.** The editor-models Eval (SEED-0006) found that
   Seed's metadata is asserted, not checked. LLM output is only as trustworthy
   as the verification layer that receives it. Without a metadata validator,
   an LLM generating `fx` forms can produce well-structured but semantically
   wrong annotations that the system accepts without question.

The net assessment: LLMs strengthen the leverage-pyramid argument but do not
guarantee it. The critical enabler is not the LLM itself but the **vocabulary
and verification layer** that constrains and checks its output.


## Design Principles This Implies

The following principles are surfaced by the survey rather than prescribed by
it. They are candidates for adoption in Seed's planning, not commitments.

1. **Every tier gets an interface native to its work.** Core developers work in
   Common Lisp. System developers work with IS/AS/BY annotations. Configurators
   work with derived form interfaces. End users work with rendered output. No
   tier should be forced to use a lower tier's tools.
2. **Each layer is discoverable from the one above.** A configurator who wants
   to understand why a field behaves a certain way should be able to trace it
   to the `fx` annotation that governs it, and from there to the `generate`
   method that renders it. Progressive revelation, not a cliff.
3. **The vocabulary defines what an LLM can do.** The IS/AS/BY grammar is the
   LLM's action space. Enriching the vocabulary enriches the LLM's capability;
   constraining it constrains the LLM's errors.
4. **Verification is what makes a tier trustworthy.** A metadata validator
   that checks IS annotations against Lisp types, BY annotations against
   available `generate` methods, and AS annotations against the containing
   context would make every tier's output — human and LLM alike — more
   reliable.
5. **Write down what the core developers know.** Documentation (Compass
   documents, docstrings, the `describe-*` culture recommended by the
   editor-models Eval, SEED-0006) is insurance against key-person risk and the
   Lisp Curse.
   The tower must survive its builders.
6. **Measure leverage, don't just assert it.** Claims like "orders of magnitude
   more productive" need evidence. Measuring the ratio of vocabulary size to
   expressible interfaces, or the number of configurators supported per system
   developer, would ground the argument.


## Honest Limits

**The leverage numbers are illustrative, not measured.** Magnitudes such as
"exponentially more", "100x" or "thousandfold" have no evidence behind them,
and this survey does not rely on them. They are plausible directions, not
established magnitudes. Until Seed has real
users at multiple tiers, the power-law claim is an aspiration, not a finding.
Eve (SEED-0005) is the cautionary case: its pursuit of programming for
everyone produced more than thirty prototypes and no settled application.
Seed's answer is to prove the pyramid through one concrete application, the
Classic CMS (SEED-DRAFT-classicinterface), before claiming it in general.

**The vendor-incentive hypotheses are speculative.** Attributing motives to IBM
or Apple based on structural analysis is not the same as having evidence of
deliberate strategy. The IBM counter-example (watsonx COBOL-to-Java) shows the
picture is more complex than the hypothesis suggests.

**The iTunes example is illustrative.** The claim that better abstractions
would have prevented iTunes's entropy is plausible but untested. The product
faced constraints (backward compatibility, platform evolution, shipping
deadlines) that abstraction alone might not have resolved.

**The Lisp Curse is a real risk, not just a historical footnote.** Seed's
expressiveness could fragment its community in the same way, and the mitigations
(documentation, shared vocabulary, LLM tooling) are proposed but unproven.

**The LLM case depends on a verification layer that does not yet exist.**
The editor-models Eval (`SEED-0006`) identified metadata
verification as Seed's most significant gap. Until that gap is closed, the
argument that LLMs can work reliably within the vocabulary is incomplete.


## Relationship to Other Work

Within the Seed corpus:

- SEED-0005 — the interface-models Survey, which covers the
  data–interface unification that the leverage pyramid depends on.
- SEED-0006 — the editor-models Eval, whose finding on metadata
  verification (G2) is cited here as the key gap for both human and LLM
  reliability.
- SEED-0003 — the IS/AS/BY ontology that defines the vocabulary
  the tiers work with.
- SEED-0004 — the extension of IS/AS/BY to `(dx)` forms,
  which enables the configurator tier to work with runtime-constructed
  interfaces.
- SEED-0008 — the Smalltalk evaluation, which cites this survey on
  a more powerful but less accessible system losing to an easier one.
- SEED-DRAFT-branches — the branch-system survey, which notes that the
  leverage pyramid depends on the branch system serving configurators through
  derived interfaces.
- SEED-DRAFT-classicinterface — the Classic CMS, the concrete application
  through which the tiers are meant to be proved.

External works cited are listed in the front-matter `cites:` block.


## Open Questions

### SEED-O6 — How should leverage be measured?

The power-law claim needs grounding. What metrics would demonstrate that the
tiered model produces more output per unit of core-developer effort than a
conventional stack? Candidates: vocabulary size to expressible-interface ratio,
configurators supported per system developer, time to add a new data kind at
each tier, defect rate per tier.

### SEED-O7 — What does the configurator tier actually need?

The configurator's interface is the derived `fx` form editor. What derived
interfaces are sufficient for real configurator work, and where do they fall
short? Which patterns migrate from text editing to structural editing first?
This question is answerable through the development of real portals.

### SEED-O8 — How should an LLM be given the vocabulary?

Compass skills supply vocabulary through in-context instructions. Seed could do
the same for IS/AS/BY. The question is whether in-context vocabulary is
sufficient for reliable generation, or whether fine-tuning on a corpus of
well-formed `fx`/`dx` examples is needed — and if so, how large that corpus
must be.

### SEED-O9 — How can key-person risk be reduced without flattening the pyramid?

Documentation, LLM-assisted continuity, and progressive revelation are proposed
mitigations. Are they sufficient? What would a "bus factor" assessment for an
abstraction tower look like, and what threshold is acceptable?

### SEED-O10 — Does the leverage argument apply to April as well?

The tiered model is described here for Seed (interface specification), but the
same logic applies to April (array-oriented computation): a small number of
people maintain the APL compiler and runtime; a larger group writes APL
expressions for domain-specific computation; a much larger group consumes the
results. Do the same design principles, risks, and mitigations apply, or does
the difference in domain (computation versus interface) change the shape?
