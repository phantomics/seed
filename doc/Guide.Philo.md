---
id:            SEED-DRAFT-philo-guide
title:         Philo Guide
genre:         Guide
subtype:       tutorial
scope:         component
project:       seed.generate
component:     philo
language:      en
status:        Current
api-version:   0.0.1
provenance:
  assistant:   claude
relates-to:
  - SEED-DRAFT-philo-log
---

# Philo Guide

This tutorial introduces **philo** (Positional Heuristic Interaction for Lisp
Objects), the keyed accessor in `seed.generate` for reading and writing the
loose "key-then-forms" structure of Seed's interface files. By the end you will
be able to read individual forms, ranges, and whole value regions from a file;
replace them; append and insert new forms into a key's region; and do all of the
same against an in-memory list — using the exported operators `philo`,
`(setf philo)`, `philo-insert`, and `philo-append`.

## Prerequisites

- `seed.generate` is loaded (`(ql:quickload :seed.generate)`), so the exported
  symbols `philo`, `philo-insert`, and `philo-append` are available.
- A Lisp source file in the key-then-forms shape (Seed's `sheet.lisp` /
  `chart.lisp` files are the canonical examples), or an in-memory list of the
  same shape.
- Basic REPL familiarity. Examples below show the form and its result with an
  inline `;; =>` comment.

## Design Goals

philo treats a Lisp file (or list) as a flat sequence of top-level forms in
which a **key** — a keyword by convention — is followed by one or more value
forms, "in the manner of a plist but not requiring a strict key/value
structure." Its name names its three axes:

- **Positional** — forms after a key are addressed by a 0-based `:offset` or a
  half-open `:range`.
- **Heuristic** — the anchor is found by a key (matched with `eql`) or by an
  arbitrary predicate function; a *region* boundary is likewise a heuristic (the
  next keyword by default).
- **Interaction** — the same vocabulary both reads and writes.

Files are read whole, parsed once, spliced in string space, and rewritten
atomically (temp file + rename), so there is no partial-write corruption. Lists
are edited destructively in place.

## The Data Model

Consider a file `sheet.lisp`:

```lisp
;; sheet.lisp
(in-package #:demo.sheet)
:cells
(setf *cell-matrix* (make-array '(2 2) :initial-contents '((0 0) (1 1))))
:main
(progn (for-cells "A1.B2" "{+1}"))
:items
(a)
(b)
(c)
:trailer
(end)
```

Every top-level form is a *segment*. A key such as `:items` *anchors* a
position; the forms after it (`(a) (b) (c)`) are addressed by offset. Two
counting models coexist:

- **Key-blind** (`:offset`, `:range`, replace): offsets count forms and pass
  straight through intervening keys.
- **Region-based** (`:region`, `:until`, and the insertion operators): a key's
  *value region* runs from the form after the key up to the next **boundary**
  form — the next keyword by default, or the next form matching `:until`.

Throughout this tutorial, `p` is the pathname of the file above.

## Reading Forms

### Reading a single form

With just a key, philo returns the first form after it, as an atom:

```lisp
(philo p :main)
;; => (PROGN (FOR-CELLS "A1.B2" "{+1}"))
```

### Reading with :offset

`:offset n` selects the form `n` positions after the key (offset 0 is the
default):

```lisp
(philo p :items)            ; offset 0
;; => (A)

(philo p :items :offset 2)
;; => (C)
```

### Reading a :range

`:range '(start end)` is half-open and returns the forms as a **list**:

```lisp
(philo p :items :range '(0 2))
;; => ((A) (B))
```

### Reading raw source with :as-string

For files, `:as-string t` returns the exact source text of the target instead of
the parsed form — useful for round-trips that must preserve formatting:

```lisp
(philo p :main :as-string t)
;; => "(progn (for-cells \"A1.B2\" \"{+1}\"))"
```

### Using a predicate key

When the key is a function it is applied to each form; the first form for which
it returns true is the anchor. This is the "heuristic" in the name:

```lisp
(philo p (lambda (form) (eql form :main)))
;; => (PROGN (FOR-CELLS "A1.B2" "{+1}"))
```

A missing key (or an out-of-range target) reads as `NIL`:

```lisp
(philo p :nope)
;; => NIL
```

## Writing Forms

### Replacing a single form

`(setf philo)` replaces the addressed form. A file target is rewritten
atomically:

```lisp
(setf (philo p :main) '(progn (reset-cells)))
;; => (PROGN (RESET-CELLS))

(philo p :main)
;; => (PROGN (RESET-CELLS))
```

An `:offset` write stores the new value as **one object**, so assigning a list
writes a list into that single position.

### Replacing a range

With `:range`, the new value is a **list** whose successive items are written to
the positions in the span:

```lisp
(setf (philo p :items :range '(0 3)) '((x) (y) (z)))
;; => ((X) (Y) (Z))

(philo p :items :region t)
;; => ((X) (Y) (Z))
```

### Round-trip identity with :as-string

Reading a form as a string and writing it straight back leaves the file
byte-identical — the basis for safe, formatting-preserving edits:

```lisp
(setf (philo p :main :as-string t) (philo p :main :as-string t))
;; the file is unchanged
```

### The :any-offset escape hatch

By default a write outside the existing forms signals an error, guarding against
accidental data loss. Pass `:any-offset t` to instead append at the end of the
file (past all keys):

```lisp
(setf (philo p :items :offset 99 :any-offset t) '(way-out))
;; appends (way-out) at end of file
```

Note the distinction: `:any-offset` appends at the **whole-file** end, whereas
the insertion operators below append at a **region's** end.

## Region Reads

### The keyword boundary default

`:region t` returns every form in a key's value region — up to the next keyword:

```lisp
(philo p :items :region t)
;; => ((A) (B) (C))

(philo p :cells :region t)
;; => ((SETF *CELL-MATRIX* (MAKE-ARRAY '(2 2) :INITIAL-CONTENTS '((0 0) (1 1)))))
```

### Overriding with :until

Because values may themselves be keywords, philo cannot always infer where a
region ends. `:until` names the boundary explicitly (a symbol matched with
`eql`, or a predicate); supplying it implies a region read:

```lisp
(philo p :items :until :trailer)
;; => ((A) (B) (C))
```

### Region reads with :as-string

For a file, a region read with `:as-string t` returns the source text spanning
the whole region:

```lisp
(philo p :items :region t :as-string t)
;; => "(a)
;; (b)
;; (c)"
```

## Inserting and Appending

Insertion **grows** the sequence, so it is a distinct operation from the
replacement `(setf philo)` performs — hence its own operators.

### philo-append at the region end

`philo-append` adds one form at the end of the key's region, before the next
boundary, without disturbing the following region:

```lisp
(philo-append p :items '(d))
;; => (D)

(philo p :items :region t)
;; => ((A) (B) (C) (D))
```

### philo-insert with :at

`philo-insert` takes an in-region index `:at` (0-based). This keyword is distinct
from `:offset` deliberately: `:offset` is key-blind, whereas `:at` counts within
the region:

```lisp
(philo-insert p :items '(a2) :at 1)
;; => (A2)

(philo p :items :region t)
;; => ((A) (A2) (B) (C))
```

### Index clamping

An `:at` past the last item clamps to the region end (it appends rather than
crossing into the next key). `philo-append` is simply `philo-insert` with the
insertion point at the region's end.

### Empty and EOF regions

Appending into an empty region (a key immediately followed by another keyword)
inserts the sole item between the two keys; appending into the last key's region
lands at end of file. A missing key is a `NIL` no-op that writes nothing.

## Working with In-Memory Lists

philo dispatches on its first argument: a **list** (including `NIL`) is treated
as an in-memory sequence of forms; anything else is a file pathname or
namestring. `:as-string` applies only to files and signals an error for lists.

### List reads mirror file reads

```lisp
(defparameter *l* (list :items '(a) '(b) :trailer '(end)))

(philo *l* :items :region t)
;; => ((A) (B))
```

### Destructive writes and insertion

List writes are **destructive**: they mutate the existing conses in place, so a
variable bound to the list observes the change. Because a key always precedes its
values, the list head is never disturbed.

```lisp
(philo-append *l* :items '(c))
;; => (C)

*l*
;; => (:ITEMS (A) (B) (C) :TRAILER (END))
```

`(setf philo)`, `philo-insert`, and `philo-append` all behave for lists exactly
as for files, minus `:as-string`.

## Running the Tests

philo's behavior is pinned by the FiveAM suite in `test/`:

```lisp
(ql:quickload :seed.generate.test)
(asdf:test-system :seed.generate.test)
;; => 56 checks, 0 failures

(seed.generate.test:run-suite :philo-region)  ; a single suite
```

You have now used every philo capability: key-blind reads (`:offset`, `:range`,
`:as-string`, predicate keys), replacement via `(setf philo)`, region reads
(`:region`, `:until`), the insertion operators (`philo-append`, `philo-insert`
with `:at`), and in-memory list mode. For the design rationale and engineering
history behind these features, see the philo development log (`SEED-DRAFT-philo-log`).
