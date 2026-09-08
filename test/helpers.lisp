;;;; test/helpers.lisp
;;;;
;;;; Shared test infrastructure for seed.generate: the suite hierarchy, a
;;;; temp-file fixture, sample data, and the test runners.

(in-package #:seed.generate.test)

;;; -----------------------------------------------------------------------
;;; Suite hierarchy
;;; -----------------------------------------------------------------------

(def-suite philo :description "All philo (Positional Heuristic Interaction for Lisp Objects) tests")

(def-suite philo-read   :in philo :description "Key-blind reads: offset, range, predicate, as-string")
(def-suite philo-write  :in philo :description "Replace via (setf philo): atom vs list, round-trip, any-offset")
(def-suite philo-region :in philo :description "Region reads: keyword boundary, :until, EOF, empty region")
(def-suite philo-insert :in philo :description "Insertion: philo-append / philo-insert, :at, clamping")
(def-suite philo-list   :in philo :description "In-memory list mode: reads, destructive writes, insertion")

;;; -----------------------------------------------------------------------
;;; Temp-file fixture
;;; -----------------------------------------------------------------------

(defmacro with-philo-file ((var content) &body body)
  "Write CONTENT (a string) to a fresh temporary .lisp file, bind VAR to its
pathname, run BODY, and delete the file on exit."
  `(uiop:with-temporary-file (:pathname ,var :type "lisp" :keep nil)
     (with-open-file (out ,var :direction :output :if-exists :supersede
                               :external-format :utf-8)
       (write-string ,content out))
     ,@body))

(defun slurp (path)
  "Read PATH into a string (UTF-8)."
  (uiop:read-file-string path))

;;; -----------------------------------------------------------------------
;;; Sample data
;;; -----------------------------------------------------------------------

(defparameter *sample-source*
  ";; test.lisp
;; do not edit manually

(in-package #:demo.test)
:cells
(setf *cell-matrix*
      (make-array '(2 2) :initial-contents '((0 0) (1 1))))
:main
(progn (foo 1) (bar 2))
:items
(a)
(b)
(c)
:trailer
(end)
"
  "A key-then-forms source in the shape of Seed's interface files.")

(defparameter *empty-region-source*
  ":k1
:k2
(v2)
"
  "A source in which the key :k1 has an empty value region (immediately
followed by another keyword).")

(defun sample-list ()
  "A fresh in-memory analogue of *SAMPLE-SOURCE*."
  (list :cells '(setf *m* 1)
        :main '(progn (foo 1))
        :items '(a) '(b) '(c)
        :trailer '(end)))

;;; -----------------------------------------------------------------------
;;; Test runners
;;; -----------------------------------------------------------------------

(defun run-all-tests ()
  "Run every philo test.  Returns T if all pass."
  (run! 'philo))

(defun %resolve-suite-name (name)
  "Resolve a suite name (keyword, string, or symbol) to the interned symbol."
  (etypecase name
    (keyword (find-symbol (symbol-name name) :seed.generate.test))
    (string (find-symbol (string-upcase name) :seed.generate.test))
    (symbol name)))

(defun run-suite (suite-name)
  "Run a single named suite.  Accepts a keyword, string, or symbol.  Returns T
if all pass."
  (run! (%resolve-suite-name suite-name)))
