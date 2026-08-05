;;; --------------------------------------------------------------------------
;;; PHILO -- Positional Heuristic Interaction for Lisp Objects
;;;
;;; A pathname-based accessor over the loose "key-then-forms" structure of a
;;; Lisp source file.  The file is treated as a flat sequence of top-level
;;; forms; a KEY (a symbol matched with EQL, or a predicate function applied to
;;; each form) anchors a position, and forms are addressed by a 0-based offset
;;; relative to the form immediately following the key.
;;;
;;;   (philo path key)                  ; first form after KEY (as an atom)
;;;   (philo path key :offset 2)        ; third form after KEY (as an atom)
;;;   (philo path key :range '(2 5))    ; forms at offsets 2,3,4 (as a list)
;;;   (philo path key :as-string t)     ; raw source text instead of parsed form
;;;   (setf (philo path key) new-form)  ; replace that form
;;;
;;; The whole file is read into a string, parsed once, spliced in string space,
;;; and written back atomically (temp file + rename), so there is no byte/char
;;; position arithmetic and no partial-write corruption window.
;;; --------------------------------------------------------------------------

(in-package #:seed.generate)

(defun philo-read-file-string (path)
  "Read PATH into a string using UTF-8.  Return NIL if the file is absent."
  (with-open-file (stream path :direction :input :external-format :utf-8
                               :if-does-not-exist nil)
    (when stream
      (let* ((buffer (make-string (file-length stream)))
             (n (read-sequence buffer stream)))
        (subseq buffer 0 n)))))

(defun philo-write-file-atomically (path string)
  "Write STRING to PATH via a sibling temp file and an atomic rename."
  (let ((tmp (make-pathname :defaults path
                            :name (concatenate 'string
                                               (or (pathname-name path) "philo")
                                               "-philo-tmp"))))
    (with-open-file (out tmp :direction :output :external-format :utf-8
                             :if-exists :supersede :if-does-not-exist :create)
      (write-string string out))
    (uiop:rename-file-overwriting-target tmp path)
    string))

(defun philo-parse-segments (string)
  "Parse STRING into a vector of (FORM START END) top-level segments, where
START and END are character indices delimiting the source of FORM.  Forms are
read with *READ-EVAL* disabled for safety."
  (let ((segments (make-array 0 :adjustable t :fill-pointer 0))
        (eof '#:eof)
        (*read-eval* nil))
    (with-input-from-string (stream string)
      (loop
        (let ((next (peek-char t stream nil eof)))
          (when (eq next eof) (return))
          (let* ((start (file-position stream))
                 (form (read-preserving-whitespace stream nil eof)))
            (when (eq form eof) (return))
            (vector-push-extend (list form start (file-position stream))
                                segments)))))
    segments))

(defun philo-find-anchor (segments key)
  "Return the index in SEGMENTS of the first form matching KEY, or NIL.  KEY is
compared with EQL unless it is a function, in which case it is called as a
predicate on each form."
  (let ((test (if (functionp key) key (lambda (form) (eql form key)))))
    (dotimes (i (length segments))
      (when (funcall test (first (aref segments i)))
        (return i)))))

(defun philo-target-indices (anchor &key offset range)
  "Resolve the target segment indices for ANCHOR under OFFSET or RANGE.
Returns (values LO HI): the absolute [LO, HI) span addressed after the anchor
(for an offset, HI = LO+1).  RANGE supersedes OFFSET.  Indices are not clamped."
  (if range
      (destructuring-bind (rstart rend) range
        (values (+ anchor 1 rstart) (+ anchor 1 rend)))
      (let ((ti (+ anchor 1 (or offset 0))))
        (values ti (1+ ti)))))

(defun philo-from-file (path key offset range as-string)
  "Read form(s) from the file at PATH (see PHILO)."
  (let ((string (philo-read-file-string path)))
    (when string
      (let* ((segments (philo-parse-segments string))
             (anchor (philo-find-anchor segments key)))
        (when anchor
          (multiple-value-bind (lo hi)
              (philo-target-indices anchor :offset offset :range range)
            (if range
                (let ((lo (max 0 lo))
                      (hi (min (length segments) hi)))
                  (when (< lo hi)
                    (if as-string
                        (subseq string
                                (second (aref segments lo))
                                (third (aref segments (1- hi))))
                        (loop :for i :from lo :below hi
                              :collect (first (aref segments i))))))
                (let ((ti lo))
                  (when (and (>= ti 0) (< ti (length segments)))
                    (if as-string
                        (subseq string
                                (second (aref segments ti))
                                (third (aref segments ti)))
                        (first (aref segments ti))))))))))))

(defun philo-from-list (list key offset range as-string)
  "Read form(s) from the in-memory LIST (see PHILO).  Non-destructive."
  (when as-string
    (error "PHILO: :as-string does not apply to list targets"))
  (let ((anchor (if (functionp key)
                    (position-if key list)
                    (position key list :test #'eql))))
    (when anchor
      (let ((len (length list)))
        (multiple-value-bind (lo hi)
            (philo-target-indices anchor :offset offset :range range)
          (if range
              (let ((lo (max 0 lo))
                    (hi (min len hi)))
                (when (< lo hi)
                  (subseq list lo hi)))
              (let ((ti lo))
                (when (and (>= ti 0) (< ti len))
                  (nth ti list)))))))))

(defun philo (target key &key offset range as-string any-offset)
  "Positional Heuristic Interaction for Lisp Objects.
Read form(s) anchored at the first form matching KEY.  TARGET is either a file
(a pathname or namestring) or an in-memory list of forms; the mode is chosen by
type -- a LIST (including NIL) reads from memory, anything else reads from a
file.  KEY is compared with EQL, or, when it is a function, applied as a
predicate to each form.  Offsets are 0-based relative to the form following KEY.

  :OFFSET n    return the single form at offset N (an atom; default offset 0).
  :RANGE (s e) return the forms at offsets [S, E) as a list.
  :AS-STRING t (files only) return the raw source text spanning the target.

RANGE supersedes OFFSET.  Returns NIL when the file/key is missing or the target
is out of range.  :AS-STRING with a list target signals an error.  ANY-OFFSET is
accepted for symmetry with the writer and ignored on read."
  (declare (ignore any-offset))
  (if (listp target)
      (philo-from-list target key offset range as-string)
      (philo-from-file target key offset range as-string)))

(defun philo-set-file (new-value path key offset range as-string any-offset)
  "Replace form(s) anchored at KEY in the file at PATH (see (SETF PHILO))."
  (let ((string (philo-read-file-string path)))
    (when string
      (let* ((segments (philo-parse-segments string))
             (anchor (philo-find-anchor segments key))
             (len (length segments))
             (end-of-file (length string))
             (cstart nil) (cend nil) (replacement nil))
        (when anchor
          (multiple-value-bind (lo hi)
              (philo-target-indices anchor :offset offset :range range)
            (if range
                (let ((width (max 0 (- hi lo))))
                  (unless (and (>= lo 0) (<= hi len))
                    (unless any-offset
                      (error "PHILO: range ~S for key ~S is out of bounds in ~A"
                             range key path)))
                  (let* ((clo (max 0 lo))
                         (chi (min len hi))
                         (items (if (listp new-value)
                                    (subseq new-value 0 (min width (length new-value)))
                                    (list new-value))))
                    (if (< clo chi)
                        (setf cstart (second (aref segments clo))
                              cend   (third (aref segments (1- chi))))
                        (setf cstart end-of-file cend end-of-file))
                    (setf replacement
                          (if as-string
                              (if (stringp new-value)
                                  new-value
                                  (format nil "~{~A~^~%~}" items))
                              (let ((*print-case* :downcase))
                                (format nil "~{~A~^~%~}"
                                        (mapcar #'prin1-to-string items)))))))
                (let ((ti lo))
                  (cond ((and (>= ti 0) (< ti len))
                         (setf cstart (second (aref segments ti))
                               cend   (third (aref segments ti))))
                        (any-offset
                         (if (>= ti len)
                             (setf cstart end-of-file cend end-of-file)
                             (setf cstart 0 cend 0)))
                        (t (error "PHILO: offset ~S for key ~S is out of bounds in ~A"
                                  (or offset 0) key path)))
                  (setf replacement
                        (if as-string new-value
                            (let ((*print-case* :downcase))
                              (prin1-to-string new-value)))))))
          (when replacement
            (when (and (= cstart cend) (= cstart end-of-file) (> end-of-file 0))
              (setf replacement (concatenate 'string (string #\Newline) replacement)))
            (when (and (= cstart cend) (= cstart 0))
              (setf replacement (concatenate 'string replacement (string #\Newline))))
            (philo-write-file-atomically
             path (concatenate 'string (subseq string 0 cstart)
                               replacement (subseq string cend)))
            new-value))))))

(defun philo-set-list (new-value list key offset range any-offset)
  "Destructively replace form(s) anchored at KEY within LIST (see (SETF PHILO)).
Mutates the existing conses in place (RPLACA/RPLACD) and returns NEW-VALUE, or
NIL when KEY is absent.  Signals an error for a target before the list head,
since a SETF-function cannot rebind the caller's place."
  (let ((anchor (if (functionp key)
                    (position-if key list)
                    (position key list :test #'eql))))
    (when anchor
      (let ((len (length list)))
        (multiple-value-bind (lo hi)
            (philo-target-indices anchor :offset offset :range range)
          (when (< lo 1)
            (error "PHILO: target before the list head for key ~S is unsupported in list mode"
                   key))
          (if range
              (let* ((width (max 0 (- hi lo)))
                     (items (if (listp new-value)
                                (subseq new-value 0 (min width (length new-value)))
                                (list new-value))))
                (cond
                  ((<= hi len)
                   (setf (cdr (nthcdr (1- lo) list))
                         (nconc (copy-list items) (nthcdr hi list))))
                  ((not any-offset)
                   (error "PHILO: range ~S for key ~S is out of bounds" range key))
                  ((<= lo len)
                   (setf (cdr (nthcdr (1- lo) list)) (copy-list items)))
                  (items
                   (setf (cdr (last list)) (copy-list items)))))
              (cond
                ((< lo len)
                 (setf (nth lo list) new-value))
                ((not any-offset)
                 (error "PHILO: offset ~S for key ~S is out of bounds" (or offset 0) key))
                (t
                 (setf (cdr (last list)) (list new-value))))))
        new-value))))

(defun (setf philo) (new-value target key &key offset range as-string any-offset)
  "Replace form(s) anchored at KEY in TARGET with NEW-VALUE.  TARGET is either a
file (pathname or namestring) or an in-memory list of forms, chosen by type: a
LIST target is edited DESTRUCTIVELY in place (rplaca/rplacd), a file target is
rewritten atomically.

  :OFFSET n    replace the single form at offset N (default 0).  NEW-VALUE is
               written as one object, so a list is written as a list.
  :RANGE (s e) replace the forms at offsets [S, E); NEW-VALUE is a list whose
               successive items are written to those positions.
  :AS-STRING t (files only) insert NEW-VALUE verbatim instead of printing it.

By default a target outside the existing forms signals an error; pass
:ANY-OFFSET T to skip past following keys (appending at the end, or prepending
at the start of a file for a negative target).  Returns NEW-VALUE, or NIL when
the file/key is missing.  In list mode a target before the head, or :AS-STRING,
signals an error."
  (if (listp target)
      (progn
        (when as-string
          (error "PHILO: :as-string does not apply to list targets"))
        (philo-set-list new-value target key offset range any-offset))
      (philo-set-file new-value target key offset range as-string any-offset)))
