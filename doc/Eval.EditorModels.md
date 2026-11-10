---
id:            SEED-DRAFT-editormodels
title:         "Editor Models: Emacs, VS Code, and Seed as Prior Art"
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
  - SEED-DRAFT-tripleontology
  - SEED-DRAFT-dxontologyupdate
cites:
  - title:     "EMACS: The Extensible, Customizable, Self-Documenting Display Editor"
    locator:   "Stallman, R. M. AI Memo 519a, MIT AI Lab, March 1981"
    external:  true
  - title:     "GNU Emacs Manual"
    locator:   "Section 49: Customization; Section 50: Easy Customization Interface"
    external:  true
  - title:     "Emacs Widget Library"
    locator:   "GNU Emacs manual, Appendix: Emacs Lisp Widget Library"
    external:  true
  - title:     "Language Server Protocol Specification"
    locator:   "Microsoft, https://microsoft.github.io/language-server-protocol/"
    external:  true
  - title:     "VS Code Extension API"
    locator:   "Microsoft, https://code.visualstudio.com/api"
    external:  true
  - title:     "VS Code Custom Editor API"
    locator:   "Microsoft, https://code.visualstudio.com/api/extension-guides/custom-editors"
    external:  true
---

# Editor Models: Emacs, VS Code, and Seed as Prior Art

This evaluation examines GNU Emacs and Visual Studio Code as prior art for
Seed's approach to editing and interface derivation. The purpose is to learn
from two dominant, well-documented editor architectures — not to rank products.
Seed is scored against the same rubric so that its strengths and weaknesses are
on the record alongside the established systems.


## Method

Evidence is drawn from published documentation and specifications, cited in the
front-matter. No hands-on benchmarks or user studies were conducted. Seed is
assessed at its current revision (`be41753`).

The stance is **learning from prior art**: what design decisions in Emacs and
VS Code have proven durable, what problems they solve and leave unsolved, and
what Seed should adopt, adapt, or deliberately reject.

Emacs is examined through Stallman's 1981 AI Memo 519a, the GNU Emacs Manual,
the Customize interface and widget library, Org-mode, and the LSP client
(Eglot, built-in since Emacs 29). VS Code is examined through its extension API
documentation, the Language Server Protocol specification, the Custom Editor and
Notebook APIs, and the Marketplace ecosystem (over 100,000 extensions as of May
2025 per Microsoft's milestone announcement).


## The Shared Scenario

Each system is walked through five tasks that span the range of editing
activities Seed aims to support.

**S1 — Edit structured parameters.** The chart-entity set in
`systems/abcd/analyses/eurcad-proto/chart.lisp`: numeric fields, a select among
line types, a sortable list of entities with per-item remove controls. This
represents the kind of structured data where form-based editing is strictly
better than text editing.

**S2 — Edit a free-form Lisp function.** An algorithmic function with control
flow, local bindings, and library calls. This represents work where text editing
is the natural medium and structural editing would be more hindrance than help.

**S3 — Add a new kind of data and its editor.** Define a new data type (say, an
audio-sample annotation) and produce an editing interface for it. This tests how
each system supports extension by its developers.

**S4 — Deliver that editor to a non-programmer.** Hand the audio-annotation
editor to a sound engineer who does not program. This tests whether the editing
surface can serve someone outside the developer community.

**S5 — Present the same data in a second medium.** Show the chart-entity data
in a terminal rather than a browser. This tests medium independence.


## The Rubric

Table: Evaluation criteria G1–G11.

| Code | Criterion | What "strong" means |
|------|-----------|-------------------|
| G1 | Source of truth | The system works with structure, not just text |
| G2 | Semantic knowledge | Knowledge is checked, not just asserted |
| G3 | Extension model | Adding capabilities is principled and composable |
| G4 | Audience reach | The system serves end users, not only programmers |
| G5 | Edit round-trip | Edits made through the interface write back to the source faithfully |
| G6 | Free-form text | The system handles prose and algorithmic code well |
| G7 | Introspection | The system can explain itself at runtime |
| G8 | Ecosystem | Extension points are stable; a large body of third-party work exists |
| G9 | Isolation and robustness | A bad extension cannot crash the host |
| G10 | Medium independence | The same content renders on more than one surface |
| G11 | Gradual entry | Complexity is revealed progressively, not demanded upfront |


## Rendition: GNU Emacs

Emacs is a self-describing, extensible editor implemented in its own Lisp
dialect (Emacs Lisp). Stallman's 1981 memo describes it as "the extensible,
customizable, self-documenting display editor" — three of those four adjectives
apply equally to what Seed aspires to be.

**G1 — Source of truth: text, with structural overlays.**
Emacs's fundamental unit is the buffer: a mutable sequence of characters. Text
properties and overlays attach metadata to character ranges, and tree-sitter
(since Emacs 29) recovers a concrete syntax tree from the text. But the text
remains authoritative — properties break when the text they annotate changes,
and tree-sitter must re-parse after every edit. The buffer model makes Emacs
superb for anything that is naturally a character stream and awkward for anything
that is not.

**G2 — Semantic knowledge: external and checked.**
Via Eglot (the built-in LSP client), Emacs receives diagnostics, completions,
and type information from language servers that analyse the actual source.
This knowledge is *derived and checked* against the code — a type error is
caught by the analyser, not asserted by the author. The weakness: when the
language server is slow, crashed, or absent, the intelligence disappears. The
text is still editable but unassisted.

**G3 — Extension model: modes, hooks, and advice.**
Emacs extends through major and minor modes (each a collection of keybindings,
syntax rules, and behaviour), hooks (points where user code intercepts system
behaviour), and advice (wrapping existing functions). This is event-driven and
imperative. The model is extraordinarily flexible — you can advise or redefine
any function at runtime — but unstructured: nothing constrains what an extension
does, and conflicting extensions are a routine source of breakage.

**G4 — Audience reach: programmers only.**
Emacs is, in practice, usable only by people willing to learn Emacs Lisp.
*However*, the Customize system is a notable counterexample: `defcustom`
declarations carry `:type` specifications (`:boolean`, `:integer`, `:string`,
`:choice`, `:repeat`, nested compound types), and the Customize interface builds
a form-based editor from those types through the widget library. This is
type metadata driving an editing surface — a relative of Seed's `fx`. The
difference: Customize derives interfaces for Emacs's own settings, not for the
user's arbitrary data, and the result never leaves Emacs.

**G5 — Edit round-trip: yes, within the buffer.**
Emacs edits the buffer directly; saving writes the buffer to the file. The
round-trip is faithful by definition for text. For structured views built from
text — `wdired` (edit a directory listing as text, apply changes to the
filesystem), `wgrep`, `occur-edit-mode` — edits made through the text
projection write back to the underlying artifact. These are the closest Emacs
gets to Seed's derived editors, and they work well.

**G6 — Free-form text: the best in class.**
Emacs has forty-five years of refinement as a text editor. Syntax highlighting,
structured editing (`paredit`, `smartparens`), multi-cursor editing, regexp
search-and-replace, keyboard macros, Org-mode's outline/table/executable-block
model — the text-editing surface is unmatched in depth.

**G7 — Introspection: exemplary.**
`describe-function`, `describe-variable`, `describe-key`, `describe-mode` — the
entire system is inspectable at runtime. Every function has a docstring, every
key binding is discoverable, and `find-function` jumps to the source of any
definition. This self-documentation culture is one of Emacs's most durable
contributions.

**G8 — Ecosystem: large and mature, if fragile.**
ELPA, MELPA, and NonGNU ELPA host thousands of packages. Extension points
(`define-derived-mode`, `defcustom`, hooks) have been stable for decades. The
weakness: packages depend on undocumented internals, and Emacs upgrades
sometimes break them. There is no formal stability contract for most interfaces.

**G9 — Isolation and robustness: weak.**
Emacs is single-threaded with a shared global environment. A misbehaving
package can block the UI, corrupt global state, or crash the session. There is
no process isolation, no sandboxing, and no workspace trust model.

**G10 — Medium independence: weak.**
Emacs renders to a terminal or a graphical frame, both character-grid based. It
cannot render to a browser, a mobile device, or a screen reader as a first-class
medium. The display model is tied to the character grid.

**G11 — Gradual entry: steep then rewarding.**
The learning curve is notoriously steep. Emacs rewards investment heavily but
demands it upfront. Starter kits (Doom, Spacemacs) lower the initial barrier
but do not change the fundamental model.

**Steal:** The `describe-*` culture of runtime introspection. The `defcustom`
pattern of type-annotated settings that derive a form editor. The discipline of
docstrings on every public symbol. The proof, via `wdired` and friends, that
editing through a text projection and writing back works.

**Reject:** The single-threaded, shared-global-state model. The character-grid
display assumption. The implicit contract where extensions depend on
undocumented internals.


## Rendition: Visual Studio Code

VS Code is a text editor built on Electron (Chromium + Node.js), designed around
protocol-based extensibility.

**G1 — Source of truth: text, with protocol-derived structure.**
The fundamental unit is the text document — a sequence of characters identified
by a URI. The Monaco editor manages the character stream; structure is recovered
by language servers (via LSP) and tree-sitter grammars. Like Emacs, the text is
authoritative. Unlike Emacs, structure recovery is delegated to separate
processes that communicate via JSON-RPC. This keeps the editor core thin and
language-agnostic.

**G2 — Semantic knowledge: external, checked, and robust.**
Language servers provide diagnostics, completions, hover information, and
navigation. The knowledge is derived and checked — the same strength as Emacs
via Eglot. The additional strength: because language servers are separate
processes, a server crash does not crash the editor, and the editor can restart
the server transparently. The intelligence degrades gracefully rather than
catastrophically.

**G3 — Extension model: declarative manifests and protocols.**
Extensions declare their contributions (commands, menus, settings, languages,
themes, custom editors) in a `package.json` manifest. The editor reads the
manifest and activates the extension lazily. Extension code runs in a separate
extension host process. This is more structured than Emacs's "advise anything"
model: contributions are declared, not injected, and the editor mediates all
interactions.

**G4 — Audience reach: programmers, with some settings UI.**
VS Code is a programmer's tool. However, settings declared with JSON Schema
types generate a Settings UI automatically — the same pattern as `defcustom`
and `fx`. The Custom Editors API lets an extension provide a webview-based
editor for non-text file types, with round-trip serialization to a backing
document. The Notebook API provides structured cell-based editing. These move
VS Code toward derived editing surfaces for specific content types, though
the audience remains developers.

**G5 — Edit round-trip: yes, for text; complex for custom editors.**
Text edits round-trip trivially (the buffer is the file). Custom editors must
implement their own serialization between the webview and the backing document —
the round-trip is possible but requires per-format work. The Notebook API is
closer to Seed's model: a notebook is a structured document serialized through a
pluggable content provider, so the structure takes priority over raw text.

**G6 — Free-form text: excellent.**
Monaco is a capable text editor with syntax highlighting, bracket matching,
multi-cursor, find-and-replace, folding, minimap, and inline diagnostics. It
is not as deep as Emacs for keyboard-driven editing (no equivalent of paredit's
structural manipulation, no keyboard macros of comparable power), but it is
polished, fast, and immediately accessible.

**G7 — Introspection: limited.**
The command palette lists available commands, and "Developer: Inspect Editor
Tokens and Scopes" shows syntax information. But there is no equivalent of
Emacs's `describe-function` that shows the source of any command, and extension
internals are opaque. The system is *usable* without introspection but not
*transparent* in the way Emacs is.

**G8 — Ecosystem: massive.**
The Marketplace hosts over 100,000 extensions (Microsoft milestone, May 2025),
with 36,000 language extensions, 9,400 debuggers, and 13,000 linters. The
extension API is versioned and has a formal stability contract. Third-party
extensions are more reliable than Emacs packages on average because the
contribution-point model constrains what they can do.

**G9 — Isolation and robustness: strong.**
Extensions run in a separate process (the extension host). A crashed extension
does not crash the editor. Workspace Trust restricts what extensions can do in
untrusted folders. The rendering process (Chromium) is separate from the
extension host. This is the most robust isolation model of the three systems
compared here.

**G10 — Medium independence: partial.**
VS Code renders to a desktop Electron shell and to a browser (vscode.dev /
github.dev). The Remote Development extensions split the UI (local) from the
workspace (remote server), which parallels Seed's server-rendered, thin-client
design. But the rendering target is always a Chromium-based surface — there is
no terminal mode, no native-widget mode, and no accessibility-first medium.

**G11 — Gradual entry: excellent.**
VS Code is immediately usable as a text editor out of the box. Complexity is
revealed progressively: install an extension to add a language, open the
settings UI to customize, use the command palette to discover features. The
entry cost is the lowest of the three systems compared here.

**Steal:** The declarative extension manifest — extensions declare what they
contribute rather than injecting code imperatively. The Custom Editors API as
proof that a text-editor platform can host derived editing surfaces. Process
isolation. The formal stability contract for extension APIs. The gradual
complexity-revelation model.

**Reject:** The opacity of extension internals (no source-level introspection).
The tight coupling to Chromium as the rendering substrate. The assumption that
all intelligence must be reconstructed from text by an external process.


## Rendition: Seed

Seed is a Common Lisp system where data carries its own interface specification
as metadata (`fx` forms), and the interface is derived by expressing that
metadata through the IS/AS/BY ontology and rendering it via medium-dispatched
`generate` methods. It is assessed here at revision `be41753`.

**G1 — Source of truth: structure.**
The S-expression is the authoritative representation. Text in a `.lisp` file is
a serialization — `read` recovers the structure, and the structure is what
`express-new` and `construct` operate on. There is no parsing step, no
synchronisation between text and a semantic model. Editing a field in the
derived interface mutates the structure directly. This is the strongest position
among the three systems on this criterion.

**G2 — Semantic knowledge: intrinsic but asserted, not checked.**
An `fx` form annotated with `(:by :entering)` or `(:is :- :properties)` does
not need an external analyser to determine its interaction mode or structural
identity. The metadata *is* the knowledge. But — and this is a correction of an
overclaim in earlier discussion — this metadata is **asserted by the author**,
not derived or verified. A wrong annotation produces a confidently wrong
interface. There is no equivalent of a type checker that catches `(:is :integer)`
on a string value. This is the weakest position among the three on verification.

**G3 — Extension model: vocabulary enrichment and method dispatch.**
Adding a new data kind means annotating it with IS/AS/BY metadata. Adding a new
interaction affordance means defining a new BY modality and its `generate`
methods. Adding a new medium means implementing `generate` for a new `uim-*`
class. Extension is principled (it follows the three-axis ontology) and
composable (generic-function dispatch combines methods from different sources).
The model is less flexible than Emacs's "advise anything" but more structured.

**G4 — Audience reach: end users, by design.**
This is Seed's strongest differentiator. The interface derived from `fx`
metadata is consumed by people who do not know they are interacting with Lisp.
An analyst editing chart parameters sees fields, selects, and sortable lists —
not S-expressions. The programmer shapes the experience at write time; the end
user encounters only the derived surface.

**G5 — Edit round-trip: functional, not textual.**
Edits through the derived interface write back to S-expression files via
`philo`. The round-trip is *functionally* faithful (the data is correct) but not
*textually* faithful: reprinted forms are downcased, comments within replaced
ranges are lost, and whitespace may change. This is a documented, accepted
contract (`SEED-DRAFT-philo-log`), but it means that collaborative development
where source formatting matters faces friction.

**G6 — Free-form text: delegated to CodeMirror.**
Seed does not implement its own text editor. Free-form code editing is handled
by CodeMirror instances provisioned through the `:provision-text` BY modality.
This is adequate but means Seed depends on an external JavaScript library for
a core capability. The strategy is explicitly incremental: text editing handles
what has not yet migrated to structural editing, and the boundary moves as
patterns in text-editing workflows become apparent.

**G7 — Introspection: nascent.**
Common Lisp's REPL, `describe`, `inspect`, and `documentation` provide runtime
introspection of Lisp objects. The IS/AS/BY metadata on `fx` forms is itself
inspectable data. But there is no Seed-specific self-documentation system
analogous to Emacs's `describe-function` or `describe-key` — no command that
tells the user "this field is here because of `(:by :entering)` on node 3 of
the form at `:chart-entities`." The metadata exists but is not yet surfaced
to the user through the derived interface.

**G8 — Ecosystem: none.**
There is no extension marketplace, no third-party packages, no community of
contributors. The IS/AS/BY vocabulary is provisional. The `generate` methods
are implemented for one medium (`uim-web`). The extension points are not yet
documented for external use. This is the weakest position among the three on
this criterion.

**G9 — Isolation and robustness: weak.**
The Seed server is a single Common Lisp image. A bug in a branch handler, an
`fx` annotation, or a `generate` method can crash the server. There is no
process isolation between branches, no sandboxing of user-supplied `:adapting`
processors, and no workspace trust model. The `seed.access` module gates
branch-level access but not field-level access.

**G10 — Medium independence: architecturally strong, practically unproven.**
The IS/AS/BY ontology is medium-independent by design. The `uim-terminal` class
exists but has no `generate` methods. The claim that the same data renders on
multiple surfaces has been validated only for `uim-web`. The architecture
supports it; the proof is incomplete.

**G11 — Gradual entry: moderate.**
The incremental migration strategy — start with CodeMirror text editing,
extract patterns into `fx`-annotated structures as they become apparent — allows
progressive adoption. But the initial setup requires loading a Common Lisp
system, understanding ASDF, and navigating a codebase with no tutorial beyond
the Philo Guide. The entry cost is lower than Emacs for someone already in
Common Lisp, but higher than VS Code for anyone else.

**Steal from Seed's own architecture:** the principle that the data's own
metadata specifies its editing surface. The medium-dispatch model. The
two-tier processor pipeline for balancing automatic derivation with manual
refinement.

**Fix:** metadata verification (G2), introspection surfaced to the user (G7),
process isolation (G9), and a second medium to prove G10.


## Comparison

Table: Summary scores per criterion. ● strong; ◐ partial; ○ weak.

| Criterion | Emacs | VS Code | Seed |
|-----------|-------|---------|------|
| G1 Source of truth | ◐ text + overlays | ◐ text + LSP | ● structure |
| G2 Semantic knowledge | ● checked (LSP) | ● checked (LSP) | ○ asserted |
| G3 Extension model | ◐ flexible, unstructured | ● declarative, isolated | ◐ principled, small |
| G4 Audience reach | ○ programmers | ○ programmers | ● end users |
| G5 Edit round-trip | ● faithful (text) | ◐ (custom editors need work) | ◐ functional, not textual |
| G6 Free-form text | ● best in class | ● excellent | ○ delegated |
| G7 Introspection | ● exemplary | ○ limited | ◐ nascent |
| G8 Ecosystem | ● mature | ● massive | ○ none |
| G9 Isolation | ○ single-threaded | ● process isolation | ○ single image |
| G10 Medium independence | ○ character grid | ◐ Chromium + remote | ◐ architecture only |
| G11 Gradual entry | ○ steep | ● excellent | ◐ moderate |

Seed is strongest where the established editors are weakest (G1, G4) and weakest
where they are strongest (G2, G6, G8, G9). This is not accidental — Seed is
solving a different problem (data–interface unification) and inherits the gaps
that come with not yet being a mature editing platform.


## Synthesis

### What Seed should adopt

**From Emacs:**
1. **The `describe-*` culture.** Every public symbol should have a docstring,
   and there should be a Seed-native command that explains any element of the
   derived interface by tracing it back to its IS/AS/BY metadata and its source
   location. This is the highest-leverage improvement for G7.
2. **The `defcustom` / Customize pattern.** Emacs proved that type-annotated
   declarations can drive a form-based editor within a programmer's
   environment. Seed's `fx` is the generalisation of this idea to arbitrary
   data; studying how Customize handles compound types, default values, and
   validation would inform the IS vocabulary's growth.
3. **The `wdired` proof.** Editing through a text projection and writing the
   changes back to the underlying artifact is the same pattern Seed uses
   through `philo`. Emacs has proven this works reliably for directories,
   grep results, and occur buffers. Seed should expect the same reliability
   from its own round-trip path.

**From VS Code:**
1. **Declarative extension manifests.** Extensions should declare what they
   contribute (new BY modalities, new `generate` methods, new medium classes)
   in a structured, inspectable format, not only by loading code that
   modifies the running image.
2. **Process isolation.** Branch handlers and `:adapting` processors run
   user-supplied code. In a multi-user portal, a misbehaving processor should
   not crash the server. VS Code's extension-host model — separate processes
   communicating through messages — is the proven solution.
3. **The Custom Editors API as precedent.** VS Code proved that a text-editor
   platform can host derived editing surfaces for non-text content, with
   round-trip serialisation to a backing document. This validates the approach
   Seed takes for `fx`-annotated data.
4. **The gradual revelation model.** VS Code is immediately useful and
   reveals complexity only when the user seeks it. Seed's incremental
   migration strategy aspires to this but doesn't yet deliver it in practice.

### What Seed should reject

- **Text as authoritative representation.** Both Emacs and VS Code treat the
  character stream as ground truth and reconstruct structure from it. Seed's
  commitment to structure-as-source is its defining architectural choice and
  should not be compromised, even though it means delegating free-form text
  editing to an external component (CodeMirror).
- **Protocol-mediated intelligence.** VS Code's LSP model reconstructs
  semantic knowledge from text via an external process. Seed's model embeds
  knowledge in the data itself. These are not interchangeable — they serve
  different premises. However, Seed could *consume* LSP information to validate
  its own metadata (see below).

### Where Seed is not competing

Seed is not an editor. It does not aim to replace Emacs or VS Code for
general-purpose code editing. The overlap is specifically in **derived editing
surfaces** — interfaces generated from metadata for structured data. For
free-form algorithmic code, a text editor is the right tool, and Seed
acknowledges this by provisioning CodeMirror. The interesting boundary is where
text-editing workflows reveal enough regularity to migrate to `fx`-annotated
structural editing — and that boundary moves over time as patterns crystallise.

### The open gap: metadata verification (G2)

The most significant weakness this comparison reveals is that Seed's semantic
knowledge is asserted, not checked. A language server *derives* its knowledge
from the code and can catch errors. Seed's `fx` metadata is written by the
programmer and trusted without verification. A validator that checks IS
annotations against actual Lisp types, BY annotations against the available
`generate` methods, and AS annotations against the containing context would
close this gap. Such a validator could even consume LSP-style information to
cross-check `fx` metadata against the static analysis of the surrounding code —
using the protocol-mediated intelligence that Seed otherwise rejects as a
source of truth, but accepts as a verification layer.
