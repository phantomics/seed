;;;; test/helpers-m2.lisp
;;;;
;;;; Shared test infrastructure for seed.modulate2: suite hierarchy, a web
;;;; medium factory, and the test runners.

(in-package #:seed.modulate2.test)

;;; -----------------------------------------------------------------------
;;; Suite hierarchy
;;; -----------------------------------------------------------------------

(def-suite modulate2 :description "All seed.modulate2 tests")

(def-suite m2-is         :in modulate2 :description "IS inference and resolution")
(def-suite m2-expression :in modulate2 :description "express-new: fx → manifestation")
(def-suite m2-construct  :in modulate2 :description "construct: dx spec → manifestation")
(def-suite m2-controls   :in modulate2 :description "make-control and Tier-1 defaults")
(def-suite m2-rendering  :in modulate2 :description "generate for uim-web")
(def-suite m2-bridge     :in modulate2 :description "modulate ↔ modulate2 bridge hooks")

;;; -----------------------------------------------------------------------
;;; Helpers
;;; -----------------------------------------------------------------------

(defun make-web-medium ()
  "Create a uim-web instance for rendering tests."
  (make-instance 'seed.modulate::uim-web))

(defun tree-tag (tree)
  "Return the tag keyword of a Spinneret tree (its first element)."
  (and (listp tree) (first tree)))

(defun tree-attr (tree attr)
  "Return the value of ATTR in a Spinneret tree's attribute plist."
  (loop :for (k v) :on (rest tree) :by #'cddr
        :when (and (keywordp k) (eql k attr))
          :return v))

(defun tree-class (tree)
  "Return the :class string of a Spinneret tree."
  (tree-attr tree :class))

(defun tree-children (tree)
  "Return the non-attribute children of a Spinneret tree."
  (let ((rest (rest tree))
        (children))
    (loop :while rest
          :do (if (keywordp (first rest))
                  (setf rest (cddr rest))
                  (progn (push (first rest) children)
                         (setf rest (cdr rest)))))
    (nreverse children)))

;;; -----------------------------------------------------------------------
;;; Test runners
;;; -----------------------------------------------------------------------

(defun run-all-tests ()
  "Run every modulate2 test.  Returns T if all pass."
  (let ((results (fiveam:run 'modulate2)))
    (fiveam:explain! results)
    (fiveam:results-status results)))

(defun %resolve-suite-name (name)
  "Resolve a suite name (keyword, string, or symbol) to the interned symbol."
  (etypecase name
    (keyword (find-symbol (symbol-name name) :seed.modulate2.test))
    (string (find-symbol (string-upcase name) :seed.modulate2.test))
    (symbol name)))

(defun run-suite (suite-name)
  "Run a single named suite.  Accepts a keyword, string, or symbol."
  (run! (%resolve-suite-name suite-name)))
