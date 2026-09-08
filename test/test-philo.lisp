;;;; test/test-philo.lisp
;;;;
;;;; Tests for philo (Positional Heuristic Interaction for Lisp Objects):
;;;; keyed reads and writes over the loose key-then-forms structure of Lisp
;;;; source files and in-memory lists.

(in-package #:seed.generate.test)

;;; =======================================================================
;;; Key-blind reads
;;; =======================================================================

(in-suite philo-read)

(def-test read-offset-and-default ()
  "The bare key and :offset select single forms as atoms."
  (with-philo-file (p *sample-source*)
    (is (equal '(progn (foo 1) (bar 2)) (philo p :main)))
    (is (equal '(a) (philo p :items)))
    (is (equal '(c) (philo p :items :offset 2)))))

(def-test read-range ()
  "A :range returns the forms in the half-open span as a list."
  (with-philo-file (p *sample-source*)
    (is (equal '((b) (c)) (philo p :items :range '(1 3))))))

(def-test read-as-string ()
  "With :as-string the raw source text of the target is returned."
  (with-philo-file (p *sample-source*)
    (is (string= "(progn (foo 1) (bar 2))" (philo p :main :as-string t)))))

(def-test read-predicate-key ()
  "A function KEY anchors on the first form satisfying it."
  (with-philo-file (p *sample-source*)
    (is (equal '(progn (foo 1) (bar 2))
               (philo p (lambda (f) (eql f :main)))))))

(def-test read-missing-key ()
  "A missing key reads as NIL."
  (with-philo-file (p *sample-source*)
    (is-false (philo p :nope))))

;;; =======================================================================
;;; Replace via (setf philo)
;;; =======================================================================

(in-suite philo-write)

(def-test round-trip-identity ()
  "Reading a form as a string and writing it straight back leaves the file
byte-identical."
  (with-philo-file (p *sample-source*)
    (let ((before (slurp p)))
      (setf (philo p :main :as-string t) (philo p :main :as-string t))
      (is (string= before (slurp p))))))

(def-test replace-atom ()
  "A default/:offset write replaces one form; neighbors are untouched."
  (with-philo-file (p *sample-source*)
    (setf (philo p :main) '(progn (baz 42)))
    (is (equal '(progn (baz 42)) (philo p :main)))
    (is (equal '(setf *cell-matrix*
                (make-array '(2 2) :initial-contents '((0 0) (1 1))))
               (philo p :cells)))))

(def-test replace-atom-writes-list-as-one-object ()
  "An :offset write stores NEW-VALUE as a single object."
  (with-philo-file (p *sample-source*)
    (setf (philo p :items :offset 1) '(x y z))
    (is (equal '(x y z) (philo p :items :offset 1)))
    (is (equal '(a) (philo p :items :offset 0)))
    (is (equal '(c) (philo p :items :offset 2)))))

(def-test replace-range-distributes ()
  "A :range write distributes successive items of NEW-VALUE across positions."
  (with-philo-file (p *sample-source*)
    (setf (philo p :items :range '(0 3)) '((x) (y) (z) (ignored)))
    (is (equal '(x) (philo p :items :offset 0)))
    (is (equal '(y) (philo p :items :offset 1)))
    (is (equal '(z) (philo p :items :offset 2)))))

(def-test replace-out-of-range-errors ()
  "An out-of-range write signals an error by default."
  (with-philo-file (p *sample-source*)
    (signals error (setf (philo p :items :offset 99) '(zzz)))))

(def-test replace-any-offset-appends ()
  "With :any-offset an out-of-range write appends at the file end."
  (with-philo-file (p *sample-source*)
    (setf (philo p :items :offset 99 :any-offset t) '(appended))
    (is-true (search "(appended)" (slurp p)))))

;;; =======================================================================
;;; Region reads
;;; =======================================================================

(in-suite philo-region)

(def-test region-default-keyword-boundary ()
  "A region read returns forms up to the next keyword."
  (with-philo-file (p *sample-source*)
    (is (equal '((a) (b) (c)) (philo p :items :region t)))
    (is (equal '((setf *cell-matrix*
                  (make-array '(2 2) :initial-contents '((0 0) (1 1)))))
               (philo p :cells :region t)))))

(def-test region-runs-to-eof ()
  "The last key's region runs to end of file."
  (with-philo-file (p *sample-source*)
    (is (equal '((end)) (philo p :trailer :region t)))))

(def-test region-until-override ()
  ":until bounds the region explicitly and implies a region read."
  (with-philo-file (p *sample-source*)
    (is (equal '((a) (b) (c)) (philo p :items :until :trailer)))))

(def-test region-as-string ()
  "A region read with :as-string spans the whole region's source."
  (with-philo-file (p *sample-source*)
    (is (string= (format nil "(a)~%(b)~%(c)")
                 (philo p :items :region t :as-string t)))))

(def-test region-empty ()
  "An empty region (key followed immediately by a keyword) reads as NIL."
  (with-philo-file (p *empty-region-source*)
    (is-false (philo p :k1 :region t))))

;;; =======================================================================
;;; Insertion: philo-append / philo-insert
;;; =======================================================================

(in-suite philo-insert)

(def-test append-at-region-end ()
  "philo-append adds a form at the end of the key's region, before the next
key, without disturbing the following region."
  (with-philo-file (p *sample-source*)
    (philo-append p :items '(new))
    (is (equal '((a) (b) (c) (new)) (philo p :items :region t)))
    (is (equal '((end)) (philo p :trailer :region t)))))

(def-test insert-at-index ()
  ":at inserts within the region at a 0-based in-region index."
  (with-philo-file (p *sample-source*)
    (philo-insert p :items '(ins) :at 1)
    (is (equal '((a) (ins) (b) (c)) (philo p :items :region t)))))

(def-test insert-at-zero ()
  ":at 0 inserts as the first region item."
  (with-philo-file (p *sample-source*)
    (philo-insert p :items '(first) :at 0)
    (is (equal '((first) (a) (b) (c)) (philo p :items :region t)))))

(def-test insert-at-clamps ()
  "An :at past the region size clamps to the region end (appends, does not
cross into the next key)."
  (with-philo-file (p *sample-source*)
    (philo-insert p :items '(z) :at 99)
    (is (equal '((a) (b) (c) (z)) (philo p :items :region t)))
    (is (equal '((end)) (philo p :trailer :region t)))))

(def-test append-into-empty-region ()
  "Appending into an empty region inserts the sole item between the two keys."
  (with-philo-file (p *empty-region-source*)
    (philo-append p :k1 '(v1))
    (is (equal '((v1)) (philo p :k1 :region t)))
    (is (equal '((v2)) (philo p :k2 :region t)))))

(def-test append-into-eof-region ()
  "Appending into the last key's region lands at end of file."
  (with-philo-file (p *sample-source*)
    (philo-append p :trailer '(tail))
    (is (equal '((end) (tail)) (philo p :trailer :region t)))))

(def-test append-missing-key-is-noop ()
  "Appending to a missing key is a NIL no-op that writes nothing."
  (with-philo-file (p *sample-source*)
    (is-false (philo-append p :nope '(x)))
    (is (equal '((a) (b) (c)) (philo p :items :region t)))))

;;; =======================================================================
;;; In-memory list mode
;;; =======================================================================

(in-suite philo-list)

(def-test list-reads ()
  "List reads mirror file reads."
  (let ((l (sample-list)))
    (is (equal '(progn (foo 1)) (philo l :main)))
    (is (equal '(a) (philo l :items)))
    (is (equal '(c) (philo l :items :offset 2)))
    (is (equal '((b) (c)) (philo l :items :range '(1 3))))
    (is-false (philo l :nope))))

(def-test list-region-reads ()
  "List region reads honor the keyword boundary and :until override."
  (let ((l (sample-list)))
    (is (equal '((a) (b) (c)) (philo l :items :region t)))
    (is (equal '((a) (b) (c)) (philo l :items :until :trailer)))))

(def-test list-as-string-errors ()
  ":as-string is a file-only concept and signals an error for lists."
  (let ((l (sample-list)))
    (signals error (philo l :main :as-string t))
    (signals error (philo l :items :region t :as-string t))))

(def-test list-replace-destructive ()
  "A list (setf philo) mutates in place; the bound variable observes it."
  (let ((l (sample-list)))
    (setf (philo l :main) '(progn (baz 42)))
    (is (equal '(progn (baz 42)) (philo l :main)))
    (setf (philo l :items :offset 1) '(x y z))
    (is (equal '(x y z) (philo l :items :offset 1)))
    (is (equal '(a) (philo l :items :offset 0)))
    (is (equal '(c) (philo l :items :offset 2)))))

(def-test list-append-destructive ()
  "philo-append mutates the list in place at the region end."
  (let ((l (sample-list)))
    (philo-append l :items '(new))
    (is (equal '((a) (b) (c) (new)) (philo l :items :region t)))
    (is (equal '((end)) (philo l :trailer :region t)))))

(def-test list-insert-at ()
  "philo-insert :at inserts within a list region and clamps past the end."
  (let ((l (sample-list)))
    (philo-insert l :items '(ins) :at 1)
    (is (equal '((a) (ins) (b) (c)) (philo l :items :region t))))
  (let ((l (sample-list)))
    (philo-insert l :items '(z) :at 99)
    (is (equal '((a) (b) (c) (z)) (philo l :items :region t)))))

(def-test list-append-empty-region ()
  "Appending into an empty list region inserts between the two keys."
  (let ((l (list :k1 :k2 '(v2))))
    (is-false (philo l :k1 :region t))
    (philo-append l :k1 '(v1))
    (is (equal '((v1)) (philo l :k1 :region t)))
    (is (equal '((v2)) (philo l :k2 :region t)))))

(def-test list-append-missing-key-is-noop ()
  "Appending to a missing key in a list is a NIL no-op."
  (let ((l (sample-list)))
    (is-false (philo-append l :nope '(x)))))
