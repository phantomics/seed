# PHILO (Positional Heuristic Interaction for Lisp Objects): Development Log

This document chronicles the design and implementation of `philo` --
Seed's keyed accessor over the loose "key-then-forms" structure of Lisp
source, extended to operate identically on files and on in-memory lists.
`philo` is the successor to `from-system-file`: it keeps that function's
plist-like read/write model but fixes its robustness defects, decouples
it from ASDF system organization, and generalizes its addressing from
"the single form after a key" to positional offsets, ranges, and
predicate anchors.

**Date:** 2026-08-04


## Problem

Seed stores interface state as ordinary Lisp source files -- e.g.
`systems/demo.sheet/sheet.lisp` is a flat stream of alternating keys and
forms:

```lisp
:cells
(setf *cell-matrix* (make-array '(10 10) ...))
:main
(progn (for-cells "C2.G8" "{5+/}") ...)
:graph-node-indices
'(0 1 2 3 ...)
```

The existing accessor, `from-system-file` (and a near-identical copy in
`modulate.lisp`), read and wrote a single form following a key, treating
the file "in the manner of a plist (but not requiring a strict key,
value structure)." It worked, and several branches depended on it, but a
close reading turned up a set of defects and limitations serious enough
to justify a redesign rather than a patch:

- **Unhandled EOF.** The scan loop `(loop :while (not form-start) :for
  item := (read stream) :while item ...)` assumed `read` returns `NIL`
  at end of file. It does not -- default `read` signals `end-of-file`.
  A missing key therefore raised an unhandled condition instead of
  returning `NIL`, and a literal `nil` form mid-file would terminate the
  scan early.

- **Character/byte position conflation.** The writer captured
  `file-position` values from a *character* stream and used them as
  indices into *byte* arrays. On SBCL/UTF-8 these happen to coincide, but
  the code was implicitly non-portable, and the comment acknowledging the
  Unicode hazard only patched the before/after byte segments, not the
  positions themselves.

- **Non-atomic three-pass write.** The setter opened the same file three
  times (`:supersede`, then two `:overwrite` passes), truncating the file
  in the first pass. A crash between passes left the file irrecoverably
  corrupt.

- **System coupling.** The first argument was an ASDF system designator,
  so the accessor conflated "where a file lives" with "how to read/write
  its contents." Callers all over the tree repeated the
  `(asdf:system-relative-pathname (intern (package-name *package*)
  "KEYWORD") ...)` incantation.

- **Limited addressing.** Only the single form immediately following a
  key was reachable. The loose, count-based structure of these files
  invites richer addressing -- the nth form, a range of forms, or a key
  located by predicate rather than by `eql`.

A final observation motivated the largest generalization: the same
key-then-forms shape that a file has on disk, an s-expression has in
memory. A tool that can home to a position in a file by key should be
able to do the same to a live list, with the file/memory distinction
being an implementation detail of the target rather than a separate API.


## Design Decisions

The following were settled through discussion before implementation.

### 1. Pathname-first, not system-first

`philo` takes a *pathname* (or namestring), never an ASDF system. System
resolution is a separate, composable concern (a branch-scoped
`with-paths-in-system` sugar was sketched but is explicitly out of scope
for `philo` itself). This removes the absolute-vs-relative special-casing
from the accessor and lets it operate uniformly on system files, absolute
paths, and scratch files. `from-system-file` is retained unchanged as a
thin compatibility surface; migrating its call sites and de-duplicating
the `modulate.lisp` copy are deferred.

### 2. A function, not a macro

`philo` is a plain function with a companion `(setf philo)`. This is what
makes `(setf (philo path key) value)` compose for free; a macro would
have required a hand-written setf-expander. The extra selectors are
ordinary `&key` arguments, so the reader and the setf-writer share one
lambda list.

### 3. Whole-file string splice + atomic rename

The core reads the entire file into a UTF-8 string, parses it *once* into
segments, splices in string space, and writes the whole file back via a
sibling temp file and an atomic rename. This single decision dissolves
three of the original defects at once: there is no byte/char arithmetic
(so no Unicode hazard), no partial-write window (the rename is atomic),
and EOF is simply "the end of the segment vector." For the KB-scale
config files involved, reading and rewriting the whole file is free.

### 4. 0-based, count-based, half-open addressing

Offsets are 0-based relative to the form *following* the key (offset 0 =
the first following form, matching the old default). Ranges are half-open
`[start, end)`. Addressing is purely positional/count-based -- it does
*not* stop at the next key -- consistent with the files' loose structure.
An out-of-range **write** signals an error by default; `:any-offset t`
lifts the guard so a caller may deliberately skip past following keys
(appending at the end). An out-of-range **read** returns `NIL`.

### 5. Atoms vs. lists: `:offset` and `:range` are semantically distinct

This was the subtlest decision. `:offset n` (and the bare default) treat
the target as a single **atom**: a read returns that one form; a write
stores `new-value` as one object (so assigning a list writes a list into
that one position). `:range '(s e)` treats the target as a **list**: a
read returns the forms as a list; a write takes `new-value` to be a list
and distributes its successive items across positions `s, s+1, ...`.
Thus `:offset 3` is *not* equivalent to `:range '(3 4)` even though both
address one position -- the former is atomic, the latter list-valued.
Assigning `'(:x :y :z)` to `:range '(2 5)` writes `:x`, `:y`, `:z` to
positions 2, 3, 4; assigning it to `:offset 2` writes the whole list
`(:x :y :z)` into position 2.

### 6. Key as symbol or predicate

A `key` that is a symbol is matched with `eql` (keywords, the common
case, compare correctly regardless of package). A `key` that is a
*function* is applied as a predicate to each top-level form, and the
first form for which it returns true is the anchor. This directly
addresses the fragility of the old `eq` symbol match and opens the door
to structural anchors (e.g. "the first `defvar` form").

### 7. Files and lists behind one interface, dispatched by type

`philo` and `(setf philo)` accept either a pathname/namestring (file
mode) or a list (in-memory mode), chosen by `listp` on the target. `NIL`
is a list (empty, no anchor -> `NIL`). Everything else is a file.

### 8. In-memory writes are destructive

`(setf (philo place key) v)` expands to `(funcall #'(setf philo) v place
key)` -- the setf-function receives the list's *value*, not the *place*,
so it cannot rebind `place`. The only way an edit can persist is to
mutate the existing conses in place (`rplaca`/`rplacd`). This is a clean
fit precisely because a key always *precedes* its values: every
key-anchored write targets index >= 1, so the head cons is never
disturbed and the caller's variable keeps pointing at the (now mutated)
list. The single unreachable case -- a negative `:any-offset` target
*before* the head -- signals an error rather than silently failing.
`:as-string` is a file-only concept and signals an error in list mode.


## Implementation

All code lives in `generate/generate.lisp`; `philo` is exported from
`generate/package.lisp`. Nothing was deleted -- `from-system-file` and
its setf-writer remain intact above the new code.

### File-mode core (first increment)

Four helpers form the file substrate:

- **`philo-read-file-string`** -- reads the whole file as UTF-8, or `NIL`
  if absent. It allocates `file-length` characters (a byte upper bound)
  and trims to the actual `read-sequence` count, which is correct for
  multi-byte content.
- **`philo-write-file-atomically`** -- writes to a sibling
  `*-philo-tmp` file and calls `uiop:rename-file-overwriting-target`.
- **`philo-parse-segments`** -- the parse-once index. Over a
  `with-input-from-string` stream, with `*read-eval*` bound to `NIL`, it
  loops `peek-char`/`read-preserving-whitespace` against a gensym EOF
  sentinel, recording `(form start end)` character spans. The
  round-trip guarantee is that `string[0:start] + string[start:end] +
  string[end:]` reproduces the source, so any splice preserves the
  surrounding text and comments exactly.
- **`philo-find-anchor`** -- first segment whose form matches `key`
  (`eql`, or predicate if `key` is a function).

The reader and setf-writer selected the target span from the anchor and
the `:offset`/`:range` options, then either returned forms / raw
substring (read) or spliced the new text into the whole-file string and
wrote it atomically (write).

### Extension to in-memory lists (second increment)

The offset/range arithmetic was factored out so file and list modes
cannot drift:

- **`philo-target-indices`** -- given an anchor and `:offset`/`:range`,
  returns `(values lo hi)`, the absolute `[lo, hi)` span after the anchor
  (for an offset, `hi = lo+1`). Range supersedes offset. Both the file
  and list paths call it.

The existing reader/writer bodies became mode-specific helpers, and
`philo` / `(setf philo)` became thin type-dispatchers:

- **`philo-from-file`** / **`philo-from-list`** -- the readers.
  `philo-from-list` finds its anchor with `position`/`position-if`,
  returns `(nth ti list)` for an atom or `(subseq list lo hi)` for a
  range, and errors on `:as-string`.
- **`philo-set-file`** -- the file writer (the original whole-file splice
  logic, now driven by `philo-target-indices`).
- **`philo-set-list`** -- the destructive list writer. For an in-bounds
  atom, `(setf (nth ti list) new-value)`. For an in-bounds range,
  `(setf (cdr (nthcdr (1- lo) list)) (nconc (copy-list items) (nthcdr hi
  list)))` -- an interior cons splice that also handles a `new-value`
  shorter than the range width by shrinking the span. `:any-offset`
  appends via the last cons. A target before the head signals an error.
- **`philo`** / **`(setf philo)`** -- dispatch on `(listp target)`,
  guarding `:as-string` in list mode.

Because keys precede their values, the destructive splices only ever
`rplaca`/`rplacd` interior conses; the list head is invariant, so a bound
variable observes every mutation.


## Pitfalls and Subtleties

### `read` does not return `NIL` at EOF

The defect that most motivated the rewrite is a trap worth restating:
`(read stream)` signals `end-of-file` by default. The correct idiom --
and what `philo-parse-segments` uses -- is an explicit sentinel:
`(read-preserving-whitespace stream nil eof)` with `(eq form eof)` as the
loop terminator. `read-preserving-whitespace` (rather than `read`) keeps
trailing whitespace out of the recorded span, and the whole parse runs
under `*read-eval* nil` so a data file cannot execute code at read time.

### The head-cons constraint is a feature, not just a limitation

A setf-function cannot rebind its place, so list-mode edits must be
destructive, which in turn means the list head cannot change. Rather than
being a wart, this is exactly consistent with the key-then-values model:
you never address position 0 (that's a key), so head-preserving
destructive mutation is sufficient for every legitimate write. The only
excluded operation -- prepending before the head via a negative
`:any-offset` -- is the one operation that genuinely needs the caller's
place, and it is reported as an error instead of failing quietly.

### `:offset` vs `:range` on a single position

During planning these were briefly considered equivalent, then
deliberately separated: `:offset` is atomic and `:range` is list-valued.
Keeping them distinct is what lets a caller write a *list* into one
position (`:offset`) versus spreading a list *across* positions
(`:range`), which the file's heterogeneous contents (a position may hold
an atom, a `quote` form, or a `setf` form) make genuinely useful.

### Comment fidelity

Because a segment's span runs from a form's start to its end, comments
*between* a key and its value are bundled into the preceding segment and
are preserved on any surrounding splice. Comments *inside* a replaced
range are not preserved, and reprinted forms are downcased via
`*print-case*` -- an accepted, documented contract, not a bug.


## Verification

A standalone SBCL harness (`philo-standalone.lisp`) exercises a copy of
the functions -- they depend only on CL and UIOP -- against temporary
files and fresh lists, so the logic is validated without loading the full
`seed.generate` system and its many dependencies.

- **File mode (20 checks):** form and `:as-string` reads; `:offset` and
  `:range` reads; predicate keys; missing keys; byte-identical
  round-trip (`:as-string` get then set); atom-vs-list write semantics;
  range distribution; out-of-range error and `:any-offset` append.
- **List mode (21 checks):** the same read matrix; `:as-string` rejected;
  destructive atom set observed through the bound variable; list written
  as one object at an `:offset`; range distribution; range shrink with a
  short `new-value`; out-of-range error and `:any-offset` append;
  `:as-string` rejected on write; predicate-key set.

Result: **41 checks, 0 failures.** Separately, the exact edited region of
`generate/generate.lisp` (lines 465-713) was extracted and
`compile-file`d in a bare SBCL to confirm the integrated source compiles
with no warnings.


## Region Reads and Insertion

After the initial file+list accessor stabilized, the code was extracted
from `generate/generate.lisp` into its own file, `generate/philo.lisp`
(registered in `generate/seed.generate.asd` after `generate`), and the
expansion was renamed from *Positional Homing In Lisp Objects* to
**Positional Heuristic Interaction for Lisp Objects** -- "Heuristic"
because an offset or range is itself a simple positional heuristic, and a
predicate key opens the door to arbitrarily complex ones.

The next feature was appending a value to a key -- adding an item to the
run of forms that follow a key. This turned out to be more subtle than it
looks, because it forced a concept philo had deliberately avoided.

### The tension: append needs a "region"; philo was key-blind

Every prior operation (`:offset`, `:range`, replace) is **count-based and
key-blind**: offsets count forms and pass straight through intervening
keys. "Append to a key" instead needs to know where that key's **value
region ends** -- i.e. what the *next key* is. That single requirement is
the source of the design's only real ambiguity.

### The root ambiguity: symbol-valued items vs. the next key

philo's premise is "loose structure, not strict key/value," and values
may themselves be symbols. In

```
:items
:a
:b
:main
(progn ...)
```

is `:a` the first *value* of `:items`, or the *next key*? The data cannot
answer this -- only the caller knows which symbols are keys. So the
region boundary is exposed rather than inferred:

- **Default:** the region ends at the next top-level **keyword**
  (`keywordp`), which matches how Seed's data files actually use keys.
- **Override:** `:until x` bounds the region at the next form matching a
  symbol (`eql`) or predicate -- the same symbol/predicate duality philo
  already uses for `key`.

The boundary being a *heuristic* the caller can tune is, fittingly, what
the renamed acronym now advertises.

### Three further decisions

1. **A distinct index keyword, `:at`.** In replace mode `:offset 2` means
   "third form after the key, counting across keys"; for insertion it
   would have to mean "third slot *within* the region." Rather than give
   `:offset` two counting bases, insertion uses its own `:at n` (0-based,
   in-region, clamped to `[0, region-size]`), leaving `:offset` its
   existing key-blind meaning untouched.

2. **Separate operators, not `(setf philo)`.** `(setf philo)` *replaces* a
   span; insertion *grows* the sequence. Overloading one form to sometimes
   replace and sometimes insert would be ambiguous, so insertion is
   `philo-insert` (with `:at`) and `philo-append` (a wrapper that omits
   `:at`, appending at the region's end).

3. **A read dual.** The natural counterpart to "append into a region" is
   "read a region," so the reader gained `:region t` (and `:until`, which
   implies it): both return the region's forms as a list, sharing the
   boundary machinery.

### Implementation

Three small helpers carry the region concept, working identically over a
file's segment vector and a list via an index-to-form accessor:

- **`philo-boundary-test`** turns `until` into a predicate (`keywordp`
  when NIL).
- **`philo-boundary-index`** scans forward for the first boundary form,
  or the end of the sequence.
- **`philo-region-bounds`** returns the `[rstart, rend)` region span.

The readers (`philo-from-file` / `philo-from-list`) short-circuit to a
region read when `:region` or `:until` is present. Insertion resolves an
absolute index with **`philo-insert-position`** (`:at` clamped to the
region size, defaulting to the region end) and then:

- **files** splice the printed form plus a newline at the character
  position of the form currently occupying that index (or at end-of-file
  when the region runs to EOF), then rewrite atomically;
- **lists** destructively splice a fresh cons at the interior position --
  always safe, since a region index is never the list head.

### Defined behaviors for the edges

- **Empty region** (key immediately followed by a keyword): the sole item
  is inserted between them; a region read returns `NIL`.
- **Key at EOF:** the region runs to end-of-file and append lands there.
- **Trailing comments** before the boundary belong (per the parser's
  segment model) to the boundary form, so an append lands *before* them --
  a defined, documented consequence rather than a surprise.
- **`:at` past the last item** clamps to the region end (appends) instead
  of spilling into the next key.
- **Missing key / nil target:** nil no-op, consistent with reads.
- Insertion is **single-item**; list-spread is deferred.


## Verification (region + insertion)

The standalone harness was refocused on the region features (its function
bodies are extracted verbatim from `generate/philo.lisp`, with only the
`in-package` form removed, so it exercises the shipped code). Coverage:
default-keyword and `:until` boundaries; region reads as forms and as
source text; append at region end (not disturbing the next key); `:at`
insertion mid-region, at 0, and clamped past the end; empty-region and
EOF-region append; destructive list append observed through a bound
variable; and missing-key no-ops -- across both file and list modes.

Result: **36 checks, 0 failures.** The full `philo.lisp` (with
`in-package` stripped) also `compile-file`d in a bare SBCL with
`WARNINGS-P = NIL` and `FAILURE-P = NIL`.


## Files

| File | Action | Description |
|------|--------|-------------|
| `generate/philo.lisp` | New | The complete `philo` implementation (extracted from `generate/generate.lisp`): read/write/parse helpers, `philo-find-anchor`, `philo-target-indices`, the boundary machinery (`philo-boundary-test`, `philo-boundary-index`, `philo-region-bounds`), the readers, `(setf philo)` writers, and the insertion operators `philo-insert` / `philo-append`. |
| `generate/seed.generate.asd` | Modified | Registered the `philo` component after `generate`. |
| `generate/package.lisp` | Modified | Exported `#:philo`, `#:philo-insert`, `#:philo-append`. |
| `doc/DevLog.Philo.md` | New | This log. |


## Outstanding Work

- **`with-paths-in-system`.** The branch-scoped sugar for resolving
  system-relative pathnames, so callers write `(setf (philo (syspath
  "./sheet.lisp") key) v)` instead of repeating ASDF incantations.
  Out of scope for `philo` proper; owned by the maintainer.
- **Migrate `from-system-file` to a `philo` shim** and remove the
  duplicate implementation in `modulate.lisp`. Deferred to keep the
  current change additive and its blast radius small.
- **Concurrency.** Atomic rename makes each write all-or-nothing, but
  concurrent writers are still last-writer-wins. Advisory locking or a
  serialized write queue is future work if portals begin writing the same
  file concurrently.
- **Read hardening.** `*read-eval*` is disabled, but a data file naming a
  package that is not loaded will still error at read time -- the same
  exposure the old accessor had. A pure paren-balancing tokenizer would
  remove even that dependency, at the cost of not being able to interpret
  key symbols directly.
