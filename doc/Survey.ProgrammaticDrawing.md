---
id:            SEED-0014
title:         "Programmatic Drawing: Layers and Strokes as APL Effects"
genre:         Survey
scope:         project
project:       Seed
language:      en
status:        Accepted
authors:
  - Andrew Sengul
approved-by:   Andrew Sengul
reviewed:      2026-11-16
provenance:
  assistant:   claude-opus-5-5
relates-to:
  - SEED-0001
  - SEED-0003
  - SEED-0004
  - SEED-0005
  - SEED-0009
  - SEED-0012
  - SEED-0011
  - SEED-0015
cites:
  - title:     "Exact: Essential eXpression Articulating Coherent Topology"
    locator:   "~/src/chat/Exact.md"
    external:  true
  - title:     "April: x86 effectors"
    locator:   "April repository, varray/effectors/x86.lisp, at revision 6ef1d4d"
    external:  true
  - title:     "Atrament"
    locator:   "Version 4.6.0, README and dist/esm/index.js as installed under portals/portal.demo1/ui-browser/npm-interfaces/atrament; https://github.com/jakubfiala/atrament"
    external:  true
  - title:     "Apply and manage Smart Filters in Photoshop"
    locator:   "Adobe Help, https://helpx.adobe.com/photoshop/desktop/effects-filters/smart-filters/apply-and-manage-smart-filters.html (October 2026)"
    external:  true
  - title:     "Mask Smart Filter effects in Photoshop"
    locator:   "Adobe Help, https://helpx.adobe.com/photoshop/desktop/effects-filters/smart-filters/mask-smart-filter-effects.html (October 2026)"
    external:  true
  - title:     "GIMP 3.0 Release Notes"
    locator:   "GIMP, https://www.gimp.org/release-notes/gimp-3.0.html (March 2025)"
    external:  true
  - title:     "GIMP 3.0 released"
    locator:   "Libre Arts, https://librearts.org/2025/03/gimp-3-0-released (March 2025)"
    external:  true
  - title:     "Filter Layer; Filter Masks; Basic Concepts"
    locator:   "Krita Manual 5.3.0, https://docs.krita.org/en/reference_manual/layers_and_masks/filter_layers.html and filter_masks.html"
    external:  true
  - title:     "How to Add a Filter in Krita"
    locator:   "Virtual Curiosities, https://www.virtualcuriosities.com/articles/1289/how-to-add-a-filter-in-krita (June 2024)"
    external:  true
  - title:     "Live filter layers"
    locator:   "Affinity Help Center, https://www.affinity.studio/help/layers-livefilters (consulted November 2026)"
    external:  true
  - title:     "drawn masks; history stack; input color profile"
    locator:   "darktable 5.6 user manual, https://docs.darktable.org/usermanual/5.6/en/ (consulted November 2026)"
    external:  true
  - title:     "Vector layers"
    locator:   "Clip Studio Paint User Guide, https://help.clip-studio.com/en-us/manual_en/180_layers/Vector_layers.htm (consulted November 2026)"
    external:  true
  - title:     "The FX Special Effects Image Operator"
    locator:   "ImageMagick, https://imagemagick.org/fx/ (v7.1.2, consulted November 2026)"
    external:  true
  - title:     "Pixel Math"
    locator:   "PixInsight documentation, https://pixinsight.com/doc/legacy/LE/22_pixel_math/pixel_math/pixel_math.html; Siril 1.4.4 documentation, https://siril.readthedocs.io/en/stable/processing/pixelmath.html (consulted November 2026)"
    external:  true
  - title:     "G'MIC — GREYC's Magic for Image Computing"
    locator:   "https://gmic.eu/; G'MIC-Qt, https://github.com/c-koi/gmic-qt; Krita Manual, G'Mic Settings (consulted November 2026)"
    external:  true
  - title:     "Halide: A Language and Compiler for Optimizing Parallelism, Locality, and Recomputation in Image Processing Pipelines"
    locator:   "Ragan-Kelley, J. et al. Proc. PLDI 2013, doi:10.1145/2491956.2462176"
    external:  true
  - title:     "Image processing in middle-school mathematics"
    locator:   "Tanimoto, S. L. Proc. IEEE ICIP 1994, doi:10.1109/ICIP.1994.413364"
    external:  true
  - title:     "An Interdisciplinary Introduction to Image Processing: Pixels, Numbers, and Programs"
    locator:   "Tanimoto, S. L. MIT Press, 2012; support site https://pixels.cs.washington.edu/"
    external:  true
  - title:     "What's New in WebGPU (Chrome 117)"
    locator:   "Chrome for Developers, https://developer.chrome.com/blog/new-in-webgpu-117"
    external:  true
  - title:     "Naga"
    locator:   "gfx-rs/wgpu repository, naga/README.md, https://github.com/gfx-rs/wgpu/blob/trunk/naga/README.md (consulted November 2026)"
    external:  true
  - title:     "Window positions under Wayland"
    locator:   "Canonical, Mir documentation 2.26, https://canonical.com/mir/docs/2.26/explanation/window-positions-under-wayland"
    external:  true
  - title:     "Support for window placement in Wayland (issue 68)"
    locator:   "W3C window-management repository, https://github.com/w3c/window-management/issues/68 (October 2021)"
    external:  true
open-questions:
  - SEED-O37
  - SEED-O38
  - SEED-O39
  - SEED-O40
  - SEED-O41
  - SEED-O42
  - SEED-O43
  - SEED-O44
  - SEED-O45
---

# Programmatic Drawing: Layers and Strokes as APL Effects

This document surveys the design of a programmatic drawing tool as a Seed
demonstration application. The tool works like a layered image editor, but
every layer and every drawn stroke is an explicit, editable program: a function
written in APL, evaluated by April, that takes an image — and optionally the
points of a stroke — and returns an image. Drawing a line and assigning it the
effect "erase drawn" makes the pixels under the line transparent in the layer
below; changing the effect to "airbrush drawn" paints along the same line
instead. Nothing is merged into pixels until the image is exported, so every
stroke and every layer can be edited, reordered or undone at any time.

The survey takes its method from Exact (cited): find the domain's joints, build
the core from universals with familiar tools as presets, write the domain in
its own notation, and let one description serve every use. It is exploratory
and non-normative; it proposes directions for a later Plan. It assumes the
IS/AS/BY ontology (SEED-0003, SEED-0004), the branch Survey (SEED-0009) and the
chart-editing Survey (SEED-0012), with which it shares a figure
vocabulary.


## Motivation

Seed's demonstration applications are chosen to cover different kinds of
interface, so that the general forms derived from them are tested against
unlike needs. The Classic CMS (SEED-0011) tests documents
and workflow; chart editing (SEED-0012) tests geometry and direct
manipulation over data. A drawing tool tests a third kind: dense numeric
arrays, edited through gestures, where the result of an edit is computed
rather than stored.

It is also the application that most directly exercises April. An image is an
array, an effect is an array function, and APL's rank operator lets a function
written for one image apply to a stack of images without change. A tool whose
effects are short APL strings lets its users write new tools and variants of
existing ones, in a notation that states the arithmetic of an effect directly.

Mainstream editors offer parts of this as "non-destructive" filters and
adjustment layers, but, as the Prior Art section shows, each stops short: masks
are painted pixels rather than editable strokes, the set of effects is fixed by
the vendor or extended only through plug-ins (compiled, or scripts like
G'MIC's that run outside the layer model), and the semantics of
what a filter layer sees are left implicit. Their base models were designed
around pixel layers, and the non-destructive features were added to them later.

### Scope of the first version

- **Stills only.** Video — applying one frame's edits to many frames — is a
  later goal, as broker execution is for the charting work. The model is shaped
  so that video needs no new machinery (see "Templates and rank").
- **Rendering in a local Lisp image.** The "server" is a Common Lisp image on
  the user's own computer. The browser draws the interface and a provisional
  stroke; the image renders.
- **A layer list by default, a graph as an advanced mode.** Both are views of
  one document.


## Prior Art

The systems below were examined through their published documentation in
November 2026, cited in the front-matter; the account of who uses
PixInsight's PixelMath, and for what, rests on community tutorials. Statements
about node compositors,
SVG filters and Shadertoy, Photoshop's adjustment layers, and the colour-space
column for Photoshop, Krita and Affinity rest on general knowledge and were
not re-checked for this survey.

Table: How established editors make effects editable. "Mask" is how the area an effect applies to is described.

| System | Editable effects | Mask | Who defines effects | Stack semantics | Colour space |
|---|---|---|---|---|---|
| Photoshop | Smart Filters on Smart Objects; adjustment layers | Painted pixels; one mask shared by all Smart Filters on an object | Adobe; plug-ins | Smart Filters apply bottom to top under their object | Document mode |
| GIMP 3 | Non-destructive filters for GEGL operations, saved in XCF | Painted layer masks | GIMP; GEGL operations in C | Filters stacked on a layer or group | Per image, widened in 3.0 |
| Krita | Filter layers and filter masks | Painted greyscale | Krita's native filters (not G'MIC) | A filter layer affects all layers below it in the same group | Per image |
| Affinity Photo | Live filter layers | Painted; vector masks available | Serif | Affects layers below, or a clipped layer or group | Per document |
| darktable | Every module in the pipeline | Drawn vector shapes with feathering, and parametric masks | darktable; modules in C | A fixed-order pipeline | Working profile, linear Rec. 2020 by default |
| Clip Studio Paint | Vector lines, editable after drawing | — | Brush shapes | Ordinary layers | — |
| Node compositors | Every node | Rotoscoped splines with feather | Vendor; plug-ins; expressions | An explicit graph | Explicit, per node or project |

**Photoshop.** Smart Filters are filters applied to a Smart Object; each keeps
its settings and blending options, and they are processed from bottom to top.
Some filters, Lens Blur among them, cannot be applied as Smart Filters. A
single filter mask controls all the Smart Filters on an object: individual
Smart Filters cannot be masked separately, and the mask is painted.

**GIMP 3.** Since GIMP 3.0, filters built on GEGL stay editable after they are
applied: they can be re-edited, toggled, reordered and deleted, and are saved
in XCF files. Third-party filters are discarded on loading if they are not
installed. A review of the release found that an XCF file with many layer
filters is slow to open, because every filter is replayed — a reminder that a
document of effects must be rendered before it can be seen.

**Krita.** A filter layer shows the layers beneath it, filtered; a filter mask
applies a filter to one layer, in the area its painted greyscale mask selects.
A filter layer affects all layers below it *in the same hierarchy*, so what a
filter sees depends on grouping and on a group's pass-through setting — a
behaviour a third-party guide (Virtual Curiosities, cited) expects many users
to mistake for a filter that does not work. This is the "reach" question of
this survey, answered implicitly by the layer tree.

**Affinity Photo.** Live filter layers are separate layers that affect
everything below them, or only a layer or group they are clipped to. They
carry their own mask, painted with brushes.

**darktable** is the closest prior art, in three respects:
- **Drawn masks are vectors.** Shapes — brush strokes, circles, ellipses, paths
  and gradients — are stored as vectors, in the coordinates of the original
  image, and rendered at the resolution the pipeline needs. Each has a feather
  or hardness, a brush stroke is converted into editable nodes, and a
  tablet's pressure can drive a stroke's width, hardness and opacity. A shape
  drawn for one module can be reused by another, and edits to it are reflected
  everywhere it is used.
- **Edits are templates.** An image's history stack can be copied, in whole or
  in part, and pasted onto any number of other images.
- **The working colour space is explicit.** Modules work in a working profile
  (linear Rec. 2020 by default) on 32-bit floating-point buffers; a module can
  declare a different space, and the pipeline converts to it.

Its limits for this purpose: the order of the pipeline is fixed by design and
changing it is discouraged, modules are written in C, and a drawn shape selects
where a module applies rather than being an effect in its own right.

**Clip Studio Paint.** Lines on a vector layer keep their control points. After
drawing, a line can be reshaped, its width and opacity adjusted at each control
point, and its brush shape changed. That is the editability this tool wants for
strokes; but the brush determines how a line is drawn, and cannot act on the
layers beneath it.

**Node compositors** — Nuke, Fusion, Natron, Blender's compositor — represent
a composite as an explicit graph of operations, apply it to every frame of a
sequence, and draw masks as animated splines with feathered edges. They are
the model for the graph mode and for the later video goal.

**SVG filters** describe a graph of filter primitives, each naming its inputs
and its result, applied to vector shapes — a declarative effect graph over
vector geometry, with a fixed set of primitives.

**Shaders and Shadertoy** show per-pixel effects written as short programs and
edited live; Processing (SEED-0005) is the creative-coding comparator for
programs that draw.

**Halide** separates an image-processing *algorithm* — images as functions over
an unbounded integer domain, pipelines as compositions of functions — from its
*schedule*: tiling, fusion, vectorisation and parallelism, chosen separately
and changeable without touching the algorithm (Ragan-Kelley et al., 2013). It
is the model for keeping effects free of rendering strategy.

**PixelMath and the Pixel Calculator.** The project "Mathematics Experiences
Through Image Processing", begun at the University of Washington in 1991 under
Steven Tanimoto, produced the Pixel Calculator for Windows, in which a
calculator key stood for the current pixel's value, so that a calculation was
applied across a selected region. It was followed by a colour version, a "METIP
Programming Environment" that combined the Color Pixel Calculator with a Lisp
system, and PixelMath, first written in 1999 by Jeremy Baer, with a formula
page and later a Python window. It is the teaching tool behind this survey's
idea: an image editor in which an effect is a formula over pixel values.

PixelMath's idea survives in three tools in active use, each of which writes
image effects as expressions or programs:

**ImageMagick's `-fx`.** The FX operator applies a mathematical expression
to each channel of each pixel of an image. The expression language has
variables, conditionals and loops; it reads the current pixel's channels
(`r`, `g`, `b`, `a`), its coordinates (`i`, `j`), the image's size and
statistics, and other pixels by relative or absolute position (`p[-1,-1]`,
`p{12,34}`), and it can combine several images of a sequence (`u`, `v`).
Values are normalised to 0–1. The expression is compiled once and run in
parallel across threads. It is the closest existing match to an effect as a
short formula — but it is a command-line operator: the region it applies to
is the whole image, or a channel, never a stroke, and nothing records it as
an editable layer.

**PixInsight's PixelMath** (and the similar **Pixel Math** tool in Siril).
In these astronomical image processors, PixelMath evaluates expressions —
one for all channels, or one per channel — over a target image and other
open images, referring to the target by a symbol (`$T`), with optional
rescaling of the result; the result replaces the target or creates a new
image. Astronomers use it for blending, calibration arithmetic, masks and
channel recombination. It shows that expression-based effects are a working
practice among technically skilled users, not only a teaching device. Like
`-fx`, it applies to whole images and masks, not to editable strokes.

**G'MIC.** G'MIC defines a scripting language for designing image-processing
operators and pipelines, with a large library of filters written in it. Its
G'MIC-Qt front end is a plug-in for GIMP, Krita, Paint.NET and digiKam, and
filters a user writes in a command file can be added to that plug-in. G'MIC
comes closest to "new tools are short programs" inside a layered editor. But
its filters run through the plug-in on the layer's pixels: Krita's filter
layers and masks cannot use G'MIC filters, which are applied destructively,
so a G'MIC effect is not an editable layer, and its region is a selection,
not a stroke.

### What the prior art establishes

Each ingredient exists somewhere: editable effect layers (all the editors),
vector masks with feathering (darktable), strokes editable after drawing (Clip
Studio), explicit working colour spaces (darktable, compositors), effect graphs
(compositors, SVG, GEGL), separation of algorithm from schedule (Halide), and
effects as formulas or programs (PixelMath, ImageMagick's `-fx`, PixInsight's
PixelMath, G'MIC, shaders). No system examined combines them: in none is a
drawn stroke an editable object whose effect is an arbitrary program, applied
uniformly with every other layer in a document the user can read. The
programmable tools apply their expressions to whole images, channels or
selections, and record no editable layer; the layered editors record
editable layers, but with effects from a fixed or compiled set.


## Finding the Joints

The user's examples — "erase drawn", "airbrush drawn", the thickness and
gradation of an erasure radiating from the line — come apart at four joints.

1. **Shape.** Vector geometry in image coordinates: a line, a polyline, an
   ellipse, a rectangle, a path. A shape is a set of anchors and the geometry
   derived from them, as a chart figure is.
2. **Field.** The shape turned into a value at every pixel — usually the
   distance from the pixel to the shape, or a signed distance for closed shapes.
3. **Profile.** A falloff from distance to strength: hard-edged, linear,
   Gaussian, or any function the user writes. Thickness and gradation are the
   profile's parameters, not properties of a brush.
4. **Operation.** What the strength does to the target pixels: scale their
   alpha (erase), composite a colour over them (paint), mix in a blurred copy
   (blur), lighten (dodge), shift a hue.

Table: Familiar tools as arrangements of the four stages.

| Tool | Shape | Profile | Operation |
|---|---|---|---|
| Erase drawn | Stroke | Gaussian, width 8 | Scale alpha by 1 − strength |
| Airbrush drawn | Stroke | Gaussian, width 12 | Composite a colour at flow × strength |
| Hard eraser | Stroke | Hard edge | Scale alpha |
| Vignette | Ellipse | Linear, inverted | Darken |
| Blur near a line | Stroke | Linear | Mix with a blurred copy |
| Graduated filter | Line | Linear across the line | Any adjustment |

Changing "erase drawn" to "airbrush drawn" changes only the operation; the
shape, its field and the profile stay. In Exact's terms (Universals), brushes
are presets — named arrangements of shape, profile and operation — not
primitives, and tools that no editor names, such as a smudge confined to a
curve, cost nothing extra.

The same separation holds for layers. A layer is a function from images to an
image, optionally with parameters such as a stroke. The generic empty layer a
user creates first is the identity function; giving it the effect "blur" or
"overlay" replaces the function, not the layer.


## The Document as a Graph

### A stack is a special case

A list of layers is a chain of functions: each takes the result of the layers
below it. Once an effect takes more than one input — a blend of two layers, a
mask computed from another layer, an erasure that reaches several layers — the
document is a directed acyclic graph, as in a node compositor. The list is then
a view of the graph, valid for the graphs that can be drawn as a list.

### Reach

An erasure with a reach of 2 acts on the two layers below it. There are two
readings, and they give different pixels:

- **Per layer:** erase each of the two layers, then composite them.
- **On the composite:** composite the two layers, then erase the result.

For an erasure of full strength, or of none, the two readings agree. Inside the
gradation — exactly where the profile matters — they differ, because
compositing is not linear in alpha. For a blur the difference is larger still:
blurring two layers separately is not blurring their composite. Krita answers
the question implicitly through grouping and pass-through; this tool should
make the reading an explicit property of the effect or of the layer
(SEED-O38).

### What the list can show

The list can show chains, groups (including colour-space scopes), masks
attached to a layer, and reach. It cannot show an output used by two
consumers, or an effect with two inputs that are not adjacent. Such nodes can
appear in the list as reference rows — "uses :photo" — as Krita's clone layers
do, and be edited in the graph view. Which graphs the list represents exactly,
and how it presents the rest, is open (SEED-O39).

### Colour-space scopes

A group can carry an input and an output transform: convert to LAB, apply the
effects inside, convert back. Each effect can also declare the space it
expects — linear light, LAB, display-referred — as darktable's modules do. A
mismatch between an effect's declared space and the space of its scope is
then found when the document is read, before anything renders (Exact's Implied
Checks). The document as a whole has a working space and a precision, and the
display and export each have an output transform. Which spaces, which
precision, and whether alpha is premultiplied are open
(SEED-O40).


## A Sketch of the Vocabulary

The following sketches what effects and documents could look like. It is
illustrative: April's calling convention, and how Lisp names are bound to APL
variables, are not shown as they are. An image is an array of shape
4 × height × width — four channel planes, red, green, blue and alpha. In the
effects below, `rgb` names its first three planes (shape 3 × height × width)
and `a` its alpha plane (height × width); `s` is the strength at each pixel,
from the profile, also height × width.

```lisp
;; Profiles: distance (⍵) to strength, parameterised by width w.
(define-profile hard     (w) "w≥⍵")
(define-profile linear   (w) "0⌈1-⍵÷w")
(define-profile gaussian (w) "*-2*⍨⍵÷w")

;; Operations: what strength s does to the pixels.
(define-effect erase-drawn
  (:inputs rgb a s)
  (:space :any)
  (:apl "a←a×1-s"))

(define-effect airbrush-drawn
  (:inputs rgb a s)
  (:parameters (colour #(1 0.8 0.6)) (flow 0.4))
  (:space :linear)
  (:apl "k←flow×s ⋄ rgb←(rgb×⍤2⊢1-k)+colour∘.×k ⋄ a←a+k×1-a"))
```

A brush is then a named arrangement:

```lisp
(define-brush soft-eraser (:profile gaussian :width 8) (:effect erase-drawn))
```

The document is data:

```lisp
(drawing (:size (3840 2160) :space :linear-srgb :precision :single-float)
  (layer :photo (:source (image "photo.tif")))
  (layer :retouch
    (:stroke (polyline (120 340) (180 360) (260 355)) :pressure (0.4 0.7 0.6))
    (:brush soft-eraser :width 10)
    (:reach 2 :reading :per-layer))
  (group :grade (:space :lab)
    (layer :warm (:effect curves :channel :b (0 0) (0.5 0.55) (1 1)))))
```

The sketch already shows why the colour conventions must be stated. If alpha is
premultiplied, `erase-drawn` must scale the colour planes as well as `a`; if it
is not, `airbrush-drawn` as written is correct only over opaque pixels. An
effect's definition should say which convention it assumes, and the check
should come from that statement.

### One description, many uses

One `define-effect` would serve, in Exact's terms (Duplex):

- **rendering**, by April's interpreter and, where the effect lies in the
  subset it can compile, by a generated kernel (see "Back Ends");
- **checking** — its inputs, parameters and colour space, when a document is
  read;
- **property editing** — its parameters, as ordinary `fx` data with IS/AS/BY
  annotations, so that the property panel for a layer is derived, not built;
- **documentation** — its APL is short enough to be its own description, in
  the domain's own notation (Exact's Native Notation).

### Templates and rank

A drawing whose source image is left as a parameter is a function from images
to an image. Applying it to many images is a map — darktable's pasted history
stack, as a value. And because effects are array functions, one written for a
single image — an array of shape 4 × height × width, as in the sketch —
applies to a stack of frames, of shape frames × 4 × height × width, through
APL's rank operator, with no new machinery. This is the path to the later
video goal, with one honest limit: a global grade carries over to every frame,
but a stroke drawn on one frame fits the others only if the content under it
does not move. Moving content needs keyframed anchors or motion tracking.

### Undo and history

The document is data, so undo, redo and variants are versions of it — the
history stage of SEED-0009 — rather than a separate undo system. Saving goes
through Philo (SEED-0001), which writes the document atomically and preserves
whatever else the file contains.


## The Drawing in IS/AS/BY

The document fits the ontology directly:

- **IS:** a stroke's anchors and pressures; a layer's parameters; a group's
  colour space.
- **AS:** each node's role — `:layer`, `:group`, `:stroke`, and the effect it
  carries.
- **BY:** the layer list is a sequence: z-order by `:sorting`, deletion by
  `:reducing`, new layers by `:extending`, selection by `:choosing`, an effect
  chosen from the vocabulary by `:choosing`, parameters by `:entering`. Copying
  a layer is a branch operation rather than a modality. The graph view is
  `:provision-graph`. Each of these is in Seed's existing vocabulary
  (`modulate2/modulate2.lisp:+by-modalities+@bf51998`).

Two things have no modality yet. The canvas — an image the user draws on — has
no provisioning mode alongside `:provision-chart` and `:provision-graph`; and
an anchor moved by dragging is the same unnamed modality the chart Survey asks
about (SEED-O33). Both are open
(SEED-O41).


## The Interface

### List and graph, one document

The layer list is the default view; the graph is the advanced one. They are two
views of one document, not two models, so an edit in either appears in both.

The list is an instance of the tabular-list modality under consideration for
Seed: rows that share a shape, reordered as data (z-order), selected, with
per-row properties, grouping and drag-and-drop. It is the layer-panel use case
in that derivation.

The graph view can start from the graph editor of the scenario pane in
`systems/demo.sheet`, which renders a node-link network as SVG with draggable
nodes and writes changes back to the system's file
(`modulate/modulate.lisp:svrender-graph@bf51998`). That code is in the older
`modulate`; in `modulate2`, `:provision-graph` is a stub. Porting the editor to
`:provision-graph`, with the scenario network as its first instance and the
image graph as its second, would be the second-instance test for the graph
modality, as the layer list is for the tabular list.

### Strokes

Drawing happens in the browser. Atrament, already one of Seed's npm
interfaces, draws the stroke at once on a canvas as a provisional rendering,
and the Lisp image's render replaces it when it is ready. The delay the user
feels is the browser's, not the image's.

Atrament 4.6.0, the version installed, can record strokes: with
`recordStrokes` set it emits `segmentdrawn` during a stroke and
`strokerecorded` at its end, each segment carrying a point and a time. It reads
the pointer's pressure to vary the drawn line, but does not record it. Since a
stroke's pressure should be part of the stroke's data — darktable lets pressure
drive width, hardness and opacity — the browser must capture it beside
Atrament or extend it (SEED-O42).

What matters is the **stroke event stream**: points, times and pressures, in
image coordinates, independent of what produced them. Whatever draws the
provisional stroke, the image receives the same stream, so a different input
source later changes nothing downstream.

A shape — a line, an ellipse, a rectangle — is a figure in the sense of the
chart Survey: anchors, derived geometry, and handles for editing. Whether
drawing shapes and chart figures share one figure form is the chart
vocabulary's second-instance test (SEED-O43).


## Rendering and Display

### Getting pixels to the browser

On one machine, transport is unlikely to be what limits speed. A full frame of
1920 × 1080 pixels with four channels (red, green, blue and alpha) at 8 bits
per channel is about 8 MB; over a local WebSocket,
sent as raw binary with no image encoding, it should take a few milliseconds.
That estimate has not been measured. Updates during a stroke need only the
changed region. In the browser, a Worker can receive the frames and draw them
to an OffscreenCanvas, by `putImageData` or by uploading a WebGL or WebGPU
texture, at most once per animation frame, so that the page's main thread
never blocks.

### Rendering incrementally

Re-evaluating every layer of a large image on every pointer movement will not
be interactive. Several techniques are needed together:

- **cache** each node's output;
- **invalidate** only what lies downstream of a change;
- **restrict** work to the region a change affects: a stroke's bounding box,
  widened by its profile's reach and by the footprint of its effect — a blur's
  radius, for instance;
- **tile** large images;
- **preview** at reduced resolution while dragging, and refine when the
  gesture ends.

These are the renderer's concerns, not the effects'. Halide's separation of
algorithm from schedule is the model: an effect says what it computes; the
renderer decides tiles, order and caching. An effect may need to declare one
thing for this — its footprint, how far beyond a pixel it reads — so that the
renderer can compute the affected region.

April's speed on arrays of this size is unknown and should be measured early,
before the design depends on it.

### Native windows

A native window positioned over a blank rectangle of the browser page is ruled
out. A page does not know reliably where it sits on the screen; the overlay
would have to track every move, resize and scroll, and stay above the browser
but below its menus; and under Wayland a client cannot place its top-level
window at a position on the screen at all — a deliberate part of the
protocol's design, and a 2021 report found that Chrome's `window.screenX` and
`window.screenY` were always 0 there.

Native windows are therefore contingent on a **native Seed interface mode**: a
medium in which Seed itself owns the window — drawing the canvas with the GPU
and taking the pointer directly — rather than one window laid over another.
Whether and when Seed has such a mode is open
(SEED-O37).


## Back Ends

### The interpreter as reference

April's interpreter runs every effect, and its output is the reference against
which every other back end is tested.

### Generated kernels

April already contains the beginning of a kernel generator (April: x86
effectors, cited). For a chain of structural array functions — section (take
and drop), reverse and rotate (`⌽` and `⊖`), transpose (`⍉`) and expand
(`\`) — it fuses the chain into a single loop over encoded coordinates,
emitted as an SBCL virtual operation in x86 assembly and divided among worker
threads. In APL's terms, rotate is a cyclic shift along an axis, not a
geometric rotation. In the drawing tool's terms, those functions cover its
geometric operations on whole pixels: cropping is a section, flipping is a
reverse, a quarter turn is a transpose composed with a reverse, and a
wrap-around offset is a rotate. Arithmetic effects — compositing, profiles,
blurs — are not yet within its reach.

The generator is being generalised into a model of assembly code as CLOS
instances — counted and unrolled loops, function definitions, guarded
sections — with classes for architectures, and a method that renders code by
dispatching on both the architecture and the structure of the program. This is
Exact's Duplex principle applied to code generation, and SPIR-V is a target
among the architectures it is meant to reach.

Two checks follow. When an effect is defined, it can be determined whether it
lies in the subset a back end compiles; outside that subset, it runs in the
interpreter. And the interpreter's output is the oracle for differential tests
of every compiled back end.

### The GPU, inside and outside the browser

SPIR-V fits the Lisp image's side, through Vulkan. Browsers accept only WGSL:
since Chrome 117, passing SPIR-V to WebGPU's `createShaderModule` throws an
error unless an unsafe flag is set. A GPU preview in the browser would need
either a WGSL target in the generator, or translation from SPIR-V to WGSL —
Naga, the translator in the wgpu project, reads SPIR-V and writes WGSL, its
WGSL output having secondary support (SEED-O44).

One consequence bears on the native interface mode. If the image renders on
the GPU, showing the result in a browser means reading the pixels back from
the GPU first; a native window could show the GPU's result directly.

### Running users' APL safely

Tools written as APL strings are meant to be shared. Even in a local image, a
template from elsewhere runs code. An effect is meant to be a pure function of
its inputs, which is a checkable property: its evaluation should be confined to
its arguments, with whatever reach April gives programs beyond them — system
functions, evaluation of further strings, calls into Lisp — closed off, and with
limits on time and memory (SEED-O45).


## The Incremental Path

The drawing tool is a new application, so building it disturbs no existing
system. Where it shares forms with other work — the figure vocabulary, the
tabular list, `:provision-graph` — the rule from the Classic interface Survey
applies: only one foundational subsystem changes at a time, and the shared
form is changed once, in the order the Plans set.

Table: A possible sequence of increments. A Plan would decide the final order.

| Step | What is built | What it proves |
|---|---|---|
| P1 | `define-profile`, `define-effect` and the document form; a renderer that writes a file, with tests; no interface | Effects as APL strings; April's speed on real image sizes |
| P2 | The document read and written through Philo; a read-only layer list in the browser beside the rendered image | The document as data; frames to the browser |
| P3 | Strokes: Atrament's provisional rendering, the stroke event stream to the image, the image's render replacing the provisional one | The two-tier display |
| P4 | Incremental rendering: caches, invalidation, affected regions, preview resolution | Interactive speed |
| P5 | The layer list as an editor: create, copy, delete, reorder, change effect, edit parameters | The layer panel as a tabular list |
| P6 | Shapes with handles, sharing the chart figure vocabulary where it fits | The figure vocabulary's second instance |
| P7 | The graph view, through `:provision-graph` ported from the scenario editor | The graph modality's second instance |
| P8 | Colour-space scopes and compiled kernels for selected effects | Implied checks for colour; back ends against the interpreter |

P1 is deliberately without an interface: it settles whether April evaluates
effects fast enough before anything is built on the assumption. P6 should
follow the chart Survey's C1, so that the figure vocabulary has one owner at a
time. For the same reason, P5 should follow step 3 of the CMS Plan
(SEED-0015): the layer list's controls (create, copy, delete,
change effect) need the working `:activating` controls of its step 2, and a
layer's parameters the submittable forms of its step 3.


## Honest Limits

**Speed is the unknown.** Nothing here has been measured. Whether April's
interpreter is fast enough for interactive editing at useful sizes, with
caching and affected regions, decides how much depends on the kernel
generator, which today covers structural functions only.

**The provisional stroke is only an outline of most effects.** Atrament can
draw and erase on its canvas, so a preview of painting or erasing is close; a
preview of a blur, a hue shift or a multi-layer reach is not. For those, the
user waits for the image.

**APL is a barrier for many users.** Presets and derived property panels hide
it for ordinary use, but writing a new tool means writing APL. That is the
design's intent, and also its narrowest point of entry.

**Colour management is detailed work.** Working spaces, precision, alpha
conventions, ICC conversions for display and print: none of it is novel, all
of it must be stated, and the sketch above shows how easily an effect assumes
a convention silently.

**Video is limited by motion.** Templates over frames work for edits that do
not depend on where things are; strokes need keyframes or tracking.

**This is not a competitor to mature editors.** Seed will not match their
breadth of filters, file formats or painting engines. Its claim is narrower:
that a drawing whose every layer and stroke is a stated program can be edited,
templated and extended without leaving its own notation.


## Relationship to Other Work

Within the Seed corpus:

- SEED-0003 and SEED-0004 — the IS/AS/BY ontology and its provisioning
  modalities, including `:provision-graph`, which the graph view would
  implement.
- SEED-0005 — the interface-models Survey, with Processing as the
  creative-coding comparator.
- SEED-0009 — the branch Survey, whose history stage provides undo and
  variants, and whose operations the drawing branch would adopt.
- SEED-0001 — Philo, through which documents are read and written.
- SEED-0012 — the chart-editing Survey, whose figure vocabulary
  shapes would share, and whose question about a modality for dragged anchors
  recurs here.
- SEED-0011 — the Classic interface Survey, whose rule for
  keeping Seed usable during development this survey follows.
- SEED-0015 — the CMS Plan, whose working controls and forms in
  modulate2 the layer-list editor (P5) would use.

External:

- Exact (cited) — joints, universals and presets, native notation, duplex
  description, implied checks.
- April's x86 effectors (cited) — the present kernel generator.
- The editors, compositors, languages and teaching tools under Prior Art.


## Open Questions

### SEED-O37 — A native Seed interface mode

A native window laid over the browser is ruled out. Should Seed have a native
interface mode, in which it owns its window and draws with the GPU — and if so,
is the drawing tool the occasion to build it, or a later client of it? Until
then, the browser is the drawing tool's only medium.

### SEED-O38 — What does reach mean?

Does an effect with a reach of several layers act on each layer before they
are composited, or on their composite? Is the reading a property of the effect
(an erasure might default to per layer, a blur to the composite), of the layer,
or chosen by the user? How is it shown in the list?

### SEED-O39 — Which graphs can the list show?

The list shows chains, groups, masks and reach. Which further graph structures
can it show, and how are the others presented — as reference rows, as a
notice that the graph view is needed, or by forbidding them outside the graph
view?

### SEED-O40 — The colour pipeline

Which working space by default, and which others for scopes? Single or double
float? Premultiplied alpha or not? ICC conversions through LittleCMS for
display and export, and OpenColorIO if video arrives? Where does the display
transform run — in the image, or in the browser?

### SEED-O41 — Modalities for the canvas

Is a canvas a new provisioning mode — a `:provision-image`, beside
`:provision-chart` — and does dragging an anchor need a modality of its own,
shared with charts and graphs (SEED-O33)?

### SEED-O42 — Where does the stroke stream come from?

Atrament 4.6.0 records points and times but not pressure. Should the browser
capture pressure from pointer events beside Atrament, extend Atrament, or
replace it for recording and keep it only for the provisional rendering? How
are raw points smoothed and simplified into editable anchors — darktable
converts a brush stroke into nodes with a smoothing setting — and is the raw
stream kept?

### SEED-O43 — One figure form or two?

Should drawing shapes and chart figures be instances of one general figure
form, with `define-chart-figure` as its charting preset? Anchors in image
pixels and anchors in time and price differ in their coordinates and their
snapping; the question is whether that difference belongs to the space a
figure lives in or to the figure.

### SEED-O44 — Which back ends, in which order?

Beyond the interpreter: x86 kernels for which effects first; SPIR-V for Vulkan
in the image; and, for a GPU preview in the browser, a WGSL target of the
generator or translation through Naga? How is an effect's eligibility for each
back end stated and checked?

### SEED-O45 — Restricting user APL

What restricted mode of April evaluation do shared effects run in, how are
time and memory limited, and is purity — dependence only on an effect's
declared inputs — checked when an effect is defined or enforced when it runs?
