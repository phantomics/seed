---
id:            SEED-DRAFT-chartediting
title:         "Chart Editing: A Declarative Figure Vocabulary for Seed's Charts"
genre:         Survey
scope:         project
project:       Seed
language:      en
status:        Draft
provenance:
  assistant:   claude-opus-5-5
relates-to:
  - SEED-0001
  - SEED-0003
  - SEED-0004
  - SEED-0005
  - SEED-0006
  - SEED-0009
  - SEED-0010
  - SEED-DRAFT-classicinterface
cites:
  - title:     "Exact: Essential eXpression Articulating Coherent Topology"
    locator:   "~/src/chat/Exact.md"
    external:  true
  - title:     "dygraphs"
    locator:   "Version 2.2.1, https://dygraphs.com/"
    external:  true
  - title:     "KLineChart: Overlay"
    locator:   "KLineChart documentation, https://klinecharts.com/en-US/guide/overlay (v10.1.0, Apache-2.0)"
    external:  true
  - title:     "Lightweight Charts: Series Primitives"
    locator:   "TradingView, https://tradingview.github.io/lightweight-charts/docs/plugins/series-primitives"
    external:  true
  - title:     "Plotly.js: layout.shapes"
    locator:   "Plotly, https://plotly.com/javascript/reference/layout/shapes/"
    external:  true
  - title:     "CLIM II Specification"
    locator:   "Part VI: Extended Stream Input Facilities, §23 Presentation Types"
    external:  true
open-questions:
  - SEED-DRAFT-chartediting-O1
  - SEED-DRAFT-chartediting-O2
  - SEED-DRAFT-chartediting-O3
  - SEED-DRAFT-chartediting-O4
  - SEED-DRAFT-chartediting-O5
  - SEED-DRAFT-chartediting-O6
  - SEED-DRAFT-chartediting-O7
  - SEED-DRAFT-chartediting-O8
---

# Chart Editing: A Declarative Figure Vocabulary for Seed's Charts

This document surveys the design space for chart editing in Seed: displaying
time series, and drawing, moving and resizing analytic figures on them —
trend lines, retracements, channels, circles, text notes and measurements. Its
starting point is the chart editor in `systems/abcd`, built on dygraphs and a
large body of Parenscript. Its aim is a design in which a figure such as a
Fibonacci retracement is stated declaratively in Lisp, once, and every use of
it — drawing, interaction, persistence, editing of its properties, and
computation on the server — derives from that statement.

The survey takes its method from Exact, the design methodology of the
Symmetrics program (cited): find the domain's natural joints, build the core
from universals with familiar forms as presets, write the domain in its own
notation, and let one description serve every use. It is exploratory and
non-normative; it proposes directions for a later Plan.


## Motivation

Charting is the second proving ground for Seed's thesis, alongside the Classic
CMS (SEED-DRAFT-classicinterface). The CMS tests derived interfaces for
documents and workflow; charting tests them for geometry and direct
manipulation, where an interface must respond at the rate of a dragging hand
and the data being edited is a set of points in time and price.

The current implementation works, and it has taught what the domain contains —
the ad hoc version that, in Exact's terms, comes first. It also shows each of
the failures Exact names: one figure described in several places, a general
charting library absorbed into domain code through its private internals, and
every new kind of figure demanding new hand-written interaction code. Expediency
of programming in Common Lisp is the practical goal: a new figure should be a
few lines of Lisp, not a new block of event handling.

The figures in scope are:

- **trend lines**;
- **retracements** along the time axis and along the price axis;
- **sets of parallel lines** — a channel is two, with more parallels as an
  option within the same structure;
- **circles**, with multiple concentric circles as an option;
- **text notes**;
- **a ruler** for measurement.

The data in scope is bars (open, high, low, close), not ticks or order books.
Non-financial time series must also be served.


## Starting Point

All code references in this section are pinned to revision `bf51998`.

### Four representations of one figure

A single trend line in `abcd` exists in four forms, with converters between
them:

1. **The analysis file.** `systems/abcd/analyses/eurcad-proto/chart.lisp`
   holds, under the `:chart-entities` key, a `chart-view` form whose entities
   are old-grammar `fx` forms: a `span` of positional fields — a select for the
   figure type, a toggle for line extension, and four numbers for the two
   points, each annotated `(:fx :uicc-field)`.
2. **CLOS instances.** The same file is `load`ed under the priority macro
   reader (`systems/abcd/seed.lisp:init-chart-entities@bf51998`), so
   `chart-view` and `span` (`application/app.chart/chart.lisp:chart-view@bf51998`,
   `application/app.chart/chart.lisp:span@bf51998`) build `app.chart` objects:
   `chart`, `entity-set`, `enspan-line`, and `enspan-retrace`, which already
   carries an axis and a list of ratios
   (`application/app.chart/chart.lisp:enspan-retrace@bf51998`).
3. **Session plists.** The `:chart` branch keeps `entity-data` in session
   state, built from the file by `systems/abcd/seed.lisp:point-from-template@bf51998`
   and from posted JSON by destructuring, and writes new figures back through a
   string templater.
4. **Client objects.** In the browser, each figure is a JS object with
   `points` in data coordinates, `layerPoints` in pixel coordinates, and
   `inFlux` and `pointsInFlux` flags, some of them carried as the strings
   `"false"` and `"true"`.

The retracement ratios are themselves stated twice: in the client's
`platform/browser/pla.browser.maple/maple.lisp:candlestick-chart-entity-templates@bf51998`,
and in the `fx` `:options` of the analysis file.

### Interaction written by hand

The client side, in `platform/browser/pla.browser.maple/maple.lisp@bf51998`
from the `:draw-methods` element onward, implements:

- a registry of figure types, each with `draw` and `intersect` functions
  (`platform/browser/pla.browser.maple/maple.lisp:draw-methods@bf51998`);
- a select/draw mode machine across `mousedown`, `mousemove` and `mouseup`
  handlers (`platform/browser/pla.browser.maple/maple.lisp:interactor-mousedown@bf51998`);
- hit-testing with an eight-pixel margin, tracking of which endpoint is being
  dragged, and snapping of a dragged point to a candle's high or low;
- conversion between pixel and data coordinates at each step;
- a candlestick plotter, since dygraphs has no candlestick series
  (`platform/browser/pla.browser.maple/maple.lisp:get-candle-plotter@bf51998`),
  inside whose callback the figures are also drawn;
- a commit of edited figures to the server when a drag ends
  (`platform/browser/pla.browser.maple/maple.lisp:commit-entities@bf51998`).

This code reaches into dygraphs' private members (`raw-data_`, `draw-graph_`,
`canvas_ctx_`). Each new figure type adds to the mode machine and the draw
registry.

### Data handling in the branch

dygraphs' x-axis does not suit bar data with gaps, so the `:chart` branch's
`:chart-data` mode rewrites the CSV's dates into row indices with regular
expressions and keeps a map from dates to indices to translate figures back
(`systems/abcd/seed.lisp@bf51998`). The branch is a long `cond` over its
inputs — the hand-written operations pattern SEED-0009 describes.

### What is already right

- **Figures persist as Lisp data in a file on the server,** under version
  control.
- **Interaction is local to the client,** and only the result of a drag is
  sent to the server. Interaction at the speed of a dragging hand cannot make
  a round trip per frame, and this split should be kept.
- **Figure types are a registry,** each with its own drawing and hit-testing.
  That is the right shape, waiting for the right description.
- **Points snap to the bars,** which traders expect.
- **`enspan-retrace` already pairs an axis with a list of ratios** — the seed
  of the universal proposed below.


## Finding the Joints

Exact's first boundary principle is to cut where concerns separate cleanly.
The current code joins four concerns that separate well:

Table: The concerns in chart editing and where each belongs.

| Concern | What it covers | Where it belongs |
|---|---|---|
| **Series rendering** | Axes, scales, pan and zoom, candles or lines, coordinate conversion | A chart library, behind a provider interface |
| **Figure description** | What a figure is: its anchors, the geometry derived from them, its labels, its handles | A Lisp vocabulary, independent of any library |
| **Figure interaction** | Dragging anchors, moving a figure, snapping | Supplied by the provider, configured from the description |
| **Figure persistence and editing** | Storing figures, editing their properties, committing changes | Seed: `fx` data, IS/AS/BY editors, branch operations |

The joint between the first two is the most important. A figure is geometry in
**data space** — times and prices — and need not know which library draws it.
A library knows pixels, scales and gestures, and need not know what a
retracement is. They meet at one narrow interface: the provider turns data
coordinates into pixels and back, and runs a figure's geometry when it draws.

This joint also answers the requirement to serve non-financial series: the
figure vocabulary stays the same, and a second provider draws general series.
The current code has absorbed the figure vocabulary into dygraphs callbacks —
downward absorption, in Exact's terms — which is why replacing dygraphs today
would mean rewriting the figures too.


## The Universals: Anchors, Derivations and Families

### Anchors

Every figure in scope is determined by a small number of **anchors**: points in
data space, each a time and a value. A trend line has two; a channel three (two
for the base line, one for the offset); a circle two (centre and a point on the
rim); a text note one; a ruler two. Anchors are what the user drags, what the
server stores, and what snaps to the bars. Everything else is derived.

### Derived geometry

From the anchors, a figure derives what it draws: segments, rays, lines,
horizontal and vertical levels, circles, and text. Derivation is pure:
given the anchors (and the figure's parameters), the geometry is determined.
A ruler derives a segment and a label whose text states the differences
between its anchors — in value, in percent, in bars, and in time.

### Families: one form behind three figures

Retracements, parallel channels and concentric circles look like different
tools, but they share one form, in the sense of Exact's *collection*: a **base
figure**, a **transform** that produces variants of it, and a **list of
ratios**, one variant per ratio.

Table: Three familiar figures as instances of one form.

| Familiar figure | Base | Transform applied at each ratio | Typical ratios |
|---|---|---|---|
| Price retracement | The span between two anchors, in value | A horizontal level at the interpolated value | 0, 0.236, 0.382, 0.5, 0.618, 0.786, 1 |
| Time retracement | The span between two anchors, in time | A vertical level at the interpolated time | 0, 0.382, 0.618, 1 |
| Channel | A segment through two anchors, offset by a third | A parallel copy, translated by the ratio times the offset | 0, 1 — or 0, 0.5, 1, 1.618 for more parallels |
| Concentric circles | A circle with centre and rim anchors | A circle with the radius scaled by the ratio | 1 — or 0.5, 1, 1.5, 2 |

The two retracements are already one class in `app.chart`
(`enspan-retrace`, with an axis and ratios), and the client's draw functions
for them differ only in the axis they use and the colour they draw in. The table extends the same
observation to parallels and concentrics. In Exact's terms this is the
**Universals** principle: the core provides anchors, derivations and families;
"Fibonacci retracement", "channel" and "concentric circles" are **presets** — a
family with a base, a transform and a default ratio list. Figures no tool has
named yet, such as parallel lines at Fibonacci offsets, come at no extra cost.

### Native notation

Traders already have a notation for these figures, and the vocabulary should
adopt it. A retracement is named by its levels — "23.6, 38.2, 50, 61.8" — so
the ratio list should be writable as those numbers. Anchors are stated as time
and price, as a chart's crosshair shows them, never as pixels or as row
indices.


## A Sketch of the Vocabulary

The following sketches what declaring figures could look like. It is
illustrative, not a specification.

```lisp
;; A preset: a family over the value axis.
(define-chart-figure price-retracement
  (:anchors a b)
  (:family (level :axis :value :from a :to b)
           :ratios (0 23.6 38.2 50 61.8 78.6 100) :ratio-unit :percent)
  (:label (:value :ratio) :at :start)
  (:magnet :weak))

;; The same family over the time axis.
(define-chart-figure time-retracement
  (:anchors a b)
  (:family (level :axis :time :from a :to b)
           :ratios (0 38.2 61.8 100) :ratio-unit :percent))

;; A channel: two parallels by default, more by extending the ratios.
(define-chart-figure channel
  (:anchors a b c)                        ; c fixes the offset
  (:family (parallel (segment a b) :through c)
           :ratios (0 1)))

;; Concentric circles.
(define-chart-figure circles
  (:anchors centre rim)
  (:family (circle centre :through rim)
           :ratios (1)))

(define-chart-figure trend-line
  (:anchors a b)
  (:figures (segment a b :extend (:option :none :left :right :both))))

(define-chart-figure note
  (:anchors at)
  (:figures (text at (:parameter text))))

;; A ruler: measures, and may not be kept.
(define-chart-figure ruler
  (:anchors a b)
  (:figures (segment a b)
            (label b (:delta :value) (:delta :percent) (:delta :bars) (:delta :time))))
```

Interaction is stated, not programmed. By default every anchor is a handle that
resizes the figure, dragging the figure's body moves all its anchors together,
and anchors snap to the bars under the figure's magnet setting. A figure
declares only departures from the default — for example a constraint that
keeps a channel's third anchor on the perpendicular of its base line.

### One description, many uses

In Exact's terms this is the **Duplex** principle at work. One
`define-chart-figure` would generate:

- **drawing:** the figure's geometry, compiled to the provider's figure format
  — with Parenscript as a compiler backend, not as the language figures are
  written in;
- **interaction:** the provider's handle, movement and snapping options;
- **persistence:** the form a figure instance takes in the analysis file —
  the figure's name and its anchors, nothing more;
- **checking:** the number and order of anchors, and the types of parameters,
  checked when an instance is read, and errors reported in the figure's terms
  (Exact's **Implied Checks**);
- **properties editing:** the figure's parameters — ratios, extension,
  colours, note text — as ordinary `fx` data with IS/AS/BY annotations, so that
  a side panel of property editors is derived like any other Seed interface;
- **computation in Lisp:** the same geometry evaluated on the server, so that
  Lisp code can ask, for instance, which retracement levels the last bar's
  close is near — a use the Parenscript code can never serve.

The last use is why the geometry language should be a small expression
language with two back ends — evaluation in Lisp and compilation to JavaScript
— rather than Parenscript fragments embedded in the definitions.

### Figures in IS/AS/BY

A figure instance fits the ontology directly:

- **IS:** its anchors are its data — pairs of time and value.
- **AS:** its role in the chart — `:retracement`, `:channel`, `:note` — taken
  from its definition.
- **BY:** the canvas engages with it through `:provision-chart`; its parameters
  are engaged through ordinary modalities — the ratio list by `:extending` and
  `:reducing`, the extension by `:choosing`, the note text by `:entering`.

The current `chentity` branch in `abcd`, which presents each figure's fields as
a form beside the chart, is the ad hoc version of the properties editor. With
figures as `fx` data, that view would be derived rather than hand-built, and the
same data would be edited two ways: geometrically on the canvas and
numerically in the form.

Whether anchors need a BY modality of their own — a `:positioning` modality for
values that are moved by dragging in a spatial view — is open
(SEED-DRAFT-chartediting-O5).


## Providers

### Requirements

A provider must render series with axes, pan and zoom; convert between data
and pixel coordinates; draw a figure's geometry; and supply handles, movement
and snapping for anchors, reporting a figure's new anchors when an edit ends.
For financial series it must draw candles, and handle bar data with gaps
directly, so that the date-to-index conversion in the branch can go.

### Candidates

Table: Candidate chart libraries, as documented at the time of writing.

| Library | Series | Figure interaction | How a new figure is described | Licence |
|---|---|---|---|---|
| **dygraphs** (current) | General time series; candles only through a custom plotter | None; written by hand against private internals | Hand-written drawing and event code | MIT |
| **KLineChart** | Candles, with timestamps and data indices | Built in: "overlays" with handles on their points, dragging of points and of the whole overlay, and magnet modes that snap to bar prices | A template: number of steps (points), magnet mode, whether to show default point handles, and a small function that returns figures (lines, text, circles…) from the points' pixel coordinates. Built-in overlays include segments, rays, price channels and a Fibonacci line. | Apache-2.0 |
| **Lightweight Charts** (TradingView) | Candles and general series | None built in; drawing tools are written as "series primitives" with hand-written dragging | Classes with views and renderers drawing on a canvas | Apache-2.0 |
| **Plotly.js** | General series, including a candlestick trace | Built in for simple shapes: editable lines, rectangles, circles and paths, dragged and resized, with an event reporting new coordinates | Declarative JSON, but each shape stands alone: no linked families, no constraints, no snapping | MIT |

KLineChart's overlay templates are the closest existing match to the
vocabulary sketched above. A template declares its number of points and its
magnet behaviour, and supplies one function from point coordinates to figures;
the library supplies the handles, the dragging, the moving and the snapping.
The `define-chart-figure` compiler would emit such templates. The library is
active: version 10.1.0 was released in October 2026.

For general series, Plotly's editable shapes cover the simpler figures with no
client code, but a family — a retracement's levels, a channel's parallels —
would have to be re-derived from its anchors whenever a shape is dragged, by
an adapter listening to Plotly's layout events. That adapter is the provider
interface doing its job, and it is also the place where Plotly would show
whether the vocabulary's joint is real.

### The second-instance test

Exact holds that a joint is confirmed when a second instance fits it unchanged.
A second provider for non-financial series is that test for the figure
vocabulary: if the same `define-chart-figure` forms draw and edit correctly on
both a candlestick provider and a general one, with no figure-specific code in
either adapter, the joint between figure and library is real. If an adapter
needs to know about retracements, the vocabulary has absorbed something it
should not have.

### WebGL

WebGL pays off when hundreds of thousands of points are drawn at once — tick
data, order-book heatmaps, dense scatter plots. A bar chart shows at most a
few thousand bars, which Canvas 2D libraries draw without strain, while WebGL
makes text, crisp lines and hit-testing harder. With bars only in scope, WebGL
is not the lever for expediency. Should dense data enter scope, a WebGL
provider (SciChart.js, deck.gl or ECharts GL, for example) would sit behind the
same interface as a third provider, and would be a further test of the joint.


## The Chart as Branch Operations

The `:chart` branch's inputs map onto the operations SEED-0009 proposes, with
the effect classes it borrows from Impulse:

Table: The chart branch's operations and their effect classes.

| Operation | What it does | Effect class |
|---|---|---|
| `describe` | Reports the operations and the figure definitions available | safe |
| `series` | Returns the bar data for the current analysis | safe |
| `figures` | Returns the figure instances, as names and anchors | safe |
| `commit` | Replaces a figure's anchors or parameters, keyed by figure id | idempotent |
| `create`, `remove` | Adds or deletes a figure | effecting |
| `save` | Writes the analysis file through Philo | effecting |

With anchors in data coordinates and figures keyed by id, `commit` is
idempotent: posting the same edit twice leaves the same result. The file is
written through Philo (SEED-0001), which preserves the rest of the analysis
file and writes atomically.


## The Incremental Path

The rule from the Classic interface Survey applies here as well: `abcd` stays
usable at every step, only one foundational subsystem changes at a time, and
the old and new paths coexist until the new one has proved itself.

Table: A possible sequence of increments. A Plan would decide the final order.

| Step | What changes | What stays |
|---|---|---|
| C1 | The figure vocabulary and its Lisp evaluator: `define-chart-figure` for trend line and the two retracements, with tests | The dygraphs chart is untouched |
| C2 | One persistent form for figures: name and anchors in time and value, as `fx` data; a one-time conversion of existing analysis files through Philo | The client still receives the old shape, converted on the way out |
| C3 | A provider interface and a KLineChart provider behind `:provision-chart`, compiling the figure definitions to overlay templates | dygraphs remains the default; the new provider is selectable per analysis |
| C4 | Interaction through the provider's own handles, movement and magnet; commit on release; the `:chart` branch reorganised around operations | — the dygraphs interaction code is retired once C4 proves out |
| C5 | The remaining presets: channels with any number of parallels, concentric circles, notes, the ruler | — |
| C6 | A second provider for general series, as the second-instance test | — |
| C7 | The properties panel derived from figure parameters through IS/AS/BY, replacing the hand-built entity form | — |

Steps C1 and C2 change nothing the user sees. C3 lets both renderers run side
by side on the same data. The `:chart` branch's move to the branch-object
model in C4 should follow the CMS's step E (SEED-DRAFT-classicinterface), so
that the branch model is not in flux in two places at once.


## Beyond the Browser

The browser's constraints — a single JavaScript thread, canvas text, and the
distance between the client and the Lisp image — do not bind at this scale,
provided interaction stays on the client. If Seed later renders charts outside
the browser, the joint proposed here is what makes it cheap: figure definitions
are geometry in data space, and a native provider would interpret them as the
web providers do. CLIM's presentations, which tie on-screen output to the
objects it presents and support dragging of that output, are the nearest model
for such a provider (SEED-0005). The web remains Seed's delivery medium, and
the analyst who opens a browser and uses the chart without installing anything
(SEED-0006, scenario S5) depends on it.


## Honest Limits

**The vocabulary is sketched, not designed.** The forms above illustrate the
shape of the idea. The real geometry language — which primitives, which
operations on anchors, how labels are formatted — remains to be designed, and
Exact's warning applies: a topology built ahead of its evidence risks
generalising along the wrong lines. The evidence so far is solid for lines and
retracements, which recur in the current code; channels and circles are new.

**Compiled figures are harder to debug.** When a figure's geometry is compiled
to JavaScript, an error in the generated code is hard to trace back to the
definition. The answer Exact gives is to check definitions as fully as
possible when they are defined, and to report errors in the figure's terms.

**Provider capabilities differ.** KLineChart's overlays handle families and
snapping natively; Plotly's shapes do not, and the adapter must re-derive
families from anchors on every edit. The second provider may expose limits in
the vocabulary rather than confirm it.

**The current analysis files execute code.** `init-chart-entities` loads the
analysis file with `load`. Reading figure instances as data, with a restricted
reader, would remove that exposure; it is a property of the persistence step
(C2), not something the vocabulary provides by itself.

**WebGL and dense data are out of scope.** The design leaves a place for a
WebGL provider but does not test it.


## Relationship to Other Work

Within the Seed corpus:

- SEED-0003 and SEED-0004 — the IS/AS/BY ontology and its extension to `(dx)`
  forms and provisioning, including the `:provision-chart` modality the
  providers would implement.
- SEED-0005 — the interface-models Survey, which treats Processing and Ben
  Fry's pipeline from data to interaction as the comparator for chart editing,
  and CLIM presentations as the model for interactive output.
- SEED-0006 — the editor-models Eval, whose scenario S1 is the chart-entity
  editor, and whose finding on unchecked metadata (G2) the figure checks
  address for charts.
- SEED-0009 and SEED-0010 — the branch Survey and the branch-models Eval, whose
  operations, effect classes and commit model the chart branch would adopt.
- SEED-0001 — Philo, the accessor through which analysis files would be read
  and written.
- SEED-DRAFT-classicinterface — the sibling Survey for the CMS, whose rule for
  keeping Seed usable throughout development this survey follows.

External:

- Exact (cited) — the design methodology whose principles organise this
  survey: joints, universals and presets, native notation, duplex description,
  implied checks, and meeting at interfaces.


## Open Questions

### SEED-DRAFT-chartediting-O1 — One provider or two?

KLineChart for financial series and a second library for general series, or
one library for both? Two providers keep each fit to its job and supply the
second-instance test; one provider halves the adapter work. If two, which
general library — Plotly, for its built-in shape editing, or another with
better support for families of figures?

### SEED-DRAFT-chartediting-O2 — How large should the geometry language be?

Which primitives (segment, ray, line, level, circle, arc, polygon, text) and
which operations on anchors (interpolation, offset, perpendicular, distance)
does the vocabulary need for the figures in scope, and where does it stop?
Should label formats be part of the language, or a separate formatting
vocabulary?

### SEED-DRAFT-chartediting-O3 — Compile, or interpret on the client?

Figure geometry could be compiled to JavaScript per figure type, or sent as
data and interpreted by a small generic evaluator on the client. Compilation
is faster and fits KLineChart's template functions; interpretation keeps one
evaluator for all figures and makes new figure types available without
regenerating client code.

### SEED-DRAFT-chartediting-O4 — Time or bar index?

Should anchors record time, bar index, or both? Time is what traders read and
what survives a change of data range; a bar index is what snapping and gaps
(weekends, holidays) make convenient. KLineChart records both.

### SEED-DRAFT-chartediting-O5 — Do anchors need a BY modality?

Figure parameters map onto existing modalities, but dragging an anchor in a
spatial view has no BY modality of its own. Is `:provision-chart` enough, or
should a modality such as `:positioning` describe values moved by dragging, so
that other spatial views (graphs, maps) can share it?

### SEED-DRAFT-chartediting-O6 — Is the ruler a figure?

A ruler measures and is usually discarded. Should it be a transient figure
that is never persisted, a persisted figure the user may keep, or a mode of
the chart rather than a figure at all?

### SEED-DRAFT-chartediting-O7 — What does snapping mean for general series?

For bars, snapping means moving an anchor to a bar's open, high, low or close.
For a general series it might mean the nearest data point, the nearest grid
line, or nothing. Should the magnet setting be part of the figure definition,
the provider, or the series?

### SEED-DRAFT-chartediting-O8 — Where do the existing app.chart classes go?

`app.chart` already models charts, entity sets, styles, and lines and
retracements as CLOS classes. Should the figure vocabulary build on those
classes, replace them, or generate them from figure definitions?
