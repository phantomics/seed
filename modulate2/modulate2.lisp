;;;; modulate2.lisp
;;;;
;;;; The Seed manifestation system using the IS/AS/BY taxonomy.
;;;;
;;;; IS - What is this? (intrinsic data character and structural identity)
;;;; AS - Why is this here? (semantic role in program or interface)
;;;; BY - How is this accessed? (interaction modality, including layout)
;;;;
;;;; This system provides an alternate expression path for (fx) forms
;;;; annotated with the new taxonomy keywords (:is, :as, :by).

(in-package #:seed.modulate2)

;;; ===================================================================
;;; SECTION: IS vocabulary — data character and structural identity
;;; ===================================================================

;;; The :is axis is mostly inferred from the wrapped value's Lisp type.
;;; Explicit :is annotations are needed only when inference would err
;;; (e.g., nil as boolean vs. absent, string as pathname vs. plain text).

(defun infer-data-character (value)
  "Infer the data character of a value from its Common Lisp type.
   Returns a keyword or list of keywords describing the value's intrinsic nature."
  (typecase value
    (null        :null)
    (boolean     :boolean)
    (integer     :integer)
    (ratio       :ratio)
    (float       :float)
    (number      :number)
    (keyword     :keyword)
    (symbol      :symbol)
    (character   :character)
    (string      :string)
    (cons        :list)
    (vector      :vector)
    (array       :array)
    (hash-table  :hash-table)
    (function   :function)
    (t           :object)))

;;; Structural specializers for :is (used as refinements of the base type):
;;;
;;; (:is :- :associations)   — list structured as an alist
;;; (:is :- :properties)     — list structured as a plist
;;; (:is :pathname)          — string that is a filesystem path
;;; (:is :boolean)           — nil/t representing true/false (not absent/empty)

;;; ===================================================================
;;; SECTION: AS vocabulary — semantic roles
;;; ===================================================================

;;; Program-element roles (for fx forms describing code at rest):

(defparameter +as-program-roles+
  '(;; Structural disambiguators — resolve code/data ambiguity
    :fn-called       ; this list is a function invocation
    :macro-spec      ; this list is a macro invocation with non-obvious structure
    :data-literal    ; this list is quoted/literal data, not a call
    :definition      ; this form defines a named entity
    :binding-form    ; this form establishes bindings (let-like)
    :iteration       ; this form is iterative/mapping

    ;; Semantic roles — irreducible meaning not determinable from position
    :range-from      ; lower bound of an interval
    :range-to        ; upper bound of an interval
    :counter         ; value that advances systematically
    :accumulator     ; value that aggregates
    :selector        ; value that chooses among alternatives
    :flag            ; value indicating a binary state
    :transformation  ; value always computed from others
    :identifier      ; value that names or labels something
    :path            ; value that locates or addresses something

    ;; Code-string language identifiers
    :code            ; (followed by language specifier: :apl, :regex, :sql, :format, etc.)
    )
  "The vocabulary of program-element semantic roles for the :as axis.")

;;; Interface-modality roles (for dx forms describing live interface objects):

(defparameter +as-interface-roles+
  '(:navigation     ; helps the user find/traverse content
    :workspace      ; primary area where interaction happens
    :controls       ; provides action affordances
    :status         ; displays current system state
    :summary        ; provides overview of content/state
    :disclosure     ; expandable/collapsible content region
    :notification   ; alerts and transient messages
    :decoration     ; purely aesthetic, non-functional element
    )
  "The vocabulary of interface-modality semantic roles for the :as axis (dx forms).")

;;; ===================================================================
;;; SECTION: BY vocabulary — interaction modality and presentation
;;; ===================================================================

;;; The :by axis describes how an element is accessed, viewed, and modified.
;;; Default is non-interactive (observation) for fx forms unless an
;;; ancestor marks the context as interactive.

(defparameter +by-modalities+
  '(;; Interaction gestures
    :observing            ; non-interactive display (default for fx)
    :entering             ; user provides/edits arbitrary value
    :choosing             ; user selects from options (subordinates :options)
    :choosing-multiple    ; user selects multiple from options
    :cycling              ; user cycles through ordered states (subordinates :options, :display)
    :activating           ; user triggers an action

    ;; Manipulation modes (for sequences/containers)
    :sorting              ; items can be reordered
    :reducing             ; items can be removed
    :extending            ; items can be added

    ;; Layout/presentation (how the interaction surface is organized)
    :valence              ; grouping structure for sequence items (subordinates numbers)
    )
  "The vocabulary of interaction modalities for the :by axis.")

;;; ===================================================================
;;; SECTION: Manifestation class hierarchy
;;; ===================================================================

;;; The primary class axis is compositional structure.
;;; Other axes (IS, AS, BY) are stored as slot values and consulted
;;; by generate methods during rendering.

(defclass manifestation ()
  ((%value :accessor mfn-value
           :initform nil
           :initarg  :value
           :documentation "The wrapped datum — the actual content this manifestation expresses.")
   (%is    :accessor mfn-is
           :initform nil
           :initarg  :is
           :documentation "Data character: intrinsic type and structural identity. Often inferred.")
   (%as    :accessor mfn-as
           :initform nil
           :initarg  :as
           :documentation "Semantic role: what function this element serves in its context.")
   (%by    :accessor mfn-by
           :initform nil
           :initarg  :by
           :documentation "Interaction modality: how this element is accessed and modified.")
   (%name  :accessor mfn-name
           :initform nil
           :initarg  :name
           :documentation "Identifying name for reference and state attachment.")
   (%path  :accessor mfn-path
           :initform nil
           :initarg  :path
           :documentation "Path from root to this element, for addressing within a tree."))
  (:documentation
   "Base class for all manifestations — objects produced by expressing fx-annotated forms
    through the IS/AS/BY taxonomy. A manifestation carries its datum along with the three
    axis values that describe its character, role, and interaction mode."))

(defclass mfn-atom (manifestation)
  ()
  (:documentation
   "A leaf manifestation — wraps a single atomic value (number, string, symbol, boolean)
    or a compound value treated as indivisible (a function call form, a code string)."))

(defclass mfn-sequence (manifestation)
  ((%members :accessor mfn-members
             :initform nil
             :initarg  :members
             :documentation "Ordered list of child manifestations.")
   (%valence :accessor mfn-valence
             :initform nil
             :initarg  :valence
             :documentation "Valence spec: grouping structure for display. E.g., (-2 4) means
                            first 2 items are header, rest group by 4."))
  (:documentation
   "A sequence manifestation — an ordered collection of child manifestations.
    Corresponds to lists, series of form fields, sortable collections, etc."))

(defclass mfn-container (manifestation)
  ((%members :accessor mfn-members
             :initform nil
             :initarg  :members
             :documentation "Named or structured child manifestations."))
  (:documentation
   "A container manifestation — holds structured content with named regions or slots.
    Used for frames, panels, binding-form bodies, and other compound structures."))

;;; ===================================================================
;;; SECTION: Metadata extraction from fx forms
;;; ===================================================================

(defun extract-axis (metadata axis-key)
  "Extract the value associated with an axis keyword from fx metadata.
   Metadata is an alist/rest-list of the form ((:as :fn-called) (:by :entering) ...).
   Returns the CDR of the matching entry, or nil if not present."
  (let ((entry (assoc axis-key metadata)))
    (when entry (rest entry))))

(defun parse-fx-metadata (raw-metadata)
  "Parse the metadata portion of an fx form (everything after the wrapped value)
   into a structured plist of (:is ... :as ... :by ... :name ...).
   Metadata entries are alist-style: ((:as :fn-called) (:by :choosing (:options ...)))."
  (let ((is-val  (extract-axis raw-metadata :is))
        (as-val  (extract-axis raw-metadata :as))
        (by-val  (extract-axis raw-metadata :by))
        (name    (extract-axis raw-metadata :name)))
    (list :is is-val :as as-val :by by-val :name name)))

;;; ===================================================================
;;; SECTION: Expression — transforming fx-annotated data into manifestations
;;; ===================================================================

(defun resolve-is (value explicit-is)
  "Determine the data character for a value, using explicit :is if provided,
   otherwise inferring from the Lisp type."
  (if explicit-is
      (if (eq :- (first explicit-is))
          ;; :- means 'inferred base type + specializers'
          (cons (infer-data-character value) (rest explicit-is))
          explicit-is)
      (list (infer-data-character value))))

(defun resolve-by (by-spec context-interactive-p)
  "Determine interaction modality. If no :by is specified, default based on context:
   non-interactive (observing) unless the context marks this as interactive."
  (cond (by-spec by-spec)
        (context-interactive-p (list :entering))
        (t (list :observing))))

(defun fx-form-p (form)
  "Test whether a form is an fx-annotated expression (a list starting with the symbol FX)."
  (and (listp form)
       (symbolp (first form))
       (string= "FX" (string (first form)))))

(defun express-new (form &optional path context-interactive-p)
  "Express an fx-annotated form into a manifestation tree using the IS/AS/BY taxonomy.
   FORM is an s-expression, possibly fx-wrapped. PATH tracks position for addressing.
   CONTEXT-INTERACTIVE-P indicates whether the enclosing context enables interaction."
  (let ((path (or path '(0))))
    (cond
      ;; Atom — not a list, just a bare value
      ((atom form)
       (make-instance 'mfn-atom
                      :value form
                      :is (list (infer-data-character form))
                      :path (reverse path)))

      ;; FX-annotated form
      ((fx-form-p form)
       (let* ((value    (second form))
              (metadata (cddr form))
              (parsed   (parse-fx-metadata metadata))
              (is-spec  (getf parsed :is))
              (as-spec  (getf parsed :as))
              (by-spec  (getf parsed :by))
              (name     (getf parsed :name))
              (resolved-is (resolve-is value is-spec))
              (resolved-by (resolve-by by-spec context-interactive-p))
              ;; Determine if this context makes children interactive
              (children-interactive-p (or context-interactive-p
                                         (and by-spec
                                              (not (member :observing by-spec))))))
         ;; Decide manifestation class based on value structure
         (if (and (listp value)
                  (or (every #'fx-form-p value)
                      (and (listp value) (listp (first value)))))
             ;; Value is a list of fx forms or nested lists -> sequence
             (let ((members (loop :for i :from 0
                                  :for item :in value
                                  :collect (express-new item (cons i path)
                                                        children-interactive-p))))
               (make-instance 'mfn-sequence
                              :value value
                              :is resolved-is
                              :as as-spec
                              :by resolved-by
                              :name name
                              :path (reverse path)
                              :members members
                              :valence (extract-valence resolved-by)))
             ;; Value is atomic or a compound form (function call, etc.) -> atom
             (make-instance 'mfn-atom
                            :value value
                            :is resolved-is
                            :as as-spec
                            :by resolved-by
                            :name name
                            :path (reverse path)))))

      ;; Plain list of forms (no fx wrapper) — treat as implicit sequence
      ((and (listp form) (some #'fx-form-p form))
       (make-instance 'mfn-sequence
                      :value form
                      :is (list :list)
                      :path (reverse path)
                      :members (loop :for i :from 0
                                     :for item :in form
                                     :collect (express-new item (cons i path)
                                                           context-interactive-p))))

      ;; Unrecognized form — wrap as atom
      (t
       (make-instance 'mfn-atom
                      :value form
                      :is (list (infer-data-character form))
                      :path (reverse path))))))

(defun extract-valence (by-spec)
  "Extract valence parameters from a :by spec if present.
   E.g., (:valence (-2 4) :sorting) -> (-2 4)"
  (let ((pos (position :valence by-spec)))
    (when (and pos (< (1+ pos) (length by-spec)))
      (let ((next (nth (1+ pos) by-spec)))
        (when (listp next) next)))))

;;; ===================================================================
;;; SECTION: Rendering — generate methods for uim-web
;;; ===================================================================

;;; The generate generic function is imported from seed.modulate.
;;; We define methods specialized on our new manifestation classes.

(defgeneric generate (medium component)
  (:documentation "Generate output markup for a manifestation on a given medium."))

(defmethod generate ((medium seed.modulate::uim-web) (m mfn-atom))
  "Generate HTML for an atomic manifestation."
  (let* ((value (mfn-value m))
         (by   (mfn-by m))
         (as   (mfn-as m))
         (modality (first by)))
    (case modality
      (:entering
       ;; Editable scalar field
       (let ((display-value (if value (princ-to-string value) ""))
             (field-name (or (and (mfn-name m) (lisp->camel-case (mfn-name m))) "")))
         `(:div :class "mfn-atom entering"
                (:label (:span ,field-name))
                (:input :class "input" :type "text"
                        :value ,display-value
                        :name ,field-name))))

      (:choosing
       ;; Selection from options
       (let ((options (rest (member :options by)))
             (field-name (or (and (mfn-name m) (lisp->camel-case (mfn-name m))) ""))
             (current-value (if value (princ-to-string value) "")))
         ;; Options may be directly after :options keyword, or nested
         (when (and options (listp (first options)))
           (setf options (first options)))
         `(:div :class "mfn-atom choosing"
                (:label (:span ,field-name))
                (:span :class "select"
                       (:select :name ,field-name
                                ,@(loop :for opt :in options
                                        :collect (let ((opt-str (princ-to-string opt))
                                                       (selected (and (equalp (princ-to-string opt)
                                                                              current-value)
                                                                      '(:selected "selected"))))
                                                   `(:option ,@selected ,opt-str))))))))

      (:cycling
       ;; Cycle/toggle through states
       (let ((options (rest (member :options by)))
             (display (rest (member :display by)))
             (field-name (or (and (mfn-name m) (lisp->camel-case (mfn-name m))) "")))
         (when (and options (listp (first options)))
           (setf options (first options)))
         (when (and display (listp (first display)))
           (setf display (first display)))
         `(:div :class "mfn-atom cycling"
                (:button :name ,field-name
                         :class "button"
                         ,(or (and display (princ-to-string (first display)))
                              (princ-to-string value))))))

      (:observing
       ;; Non-interactive display
       (let ((display-value (cond ((null value) "")
                                  ((stringp value) value)
                                  (t (princ-to-string value)))))
         `(:span :class ,(format nil "mfn-atom observing~@[ ~a~]"
                                 (when as (string-downcase (princ-to-string (first as)))))
                 ,display-value)))

      (otherwise
       ;; Fallback — display as text
       `(:span :class "mfn-atom"
               ,(if value (princ-to-string value) ""))))))

(defmethod generate ((medium seed.modulate::uim-web) (m mfn-sequence))
  "Generate HTML for a sequence manifestation."
  (let* ((by (mfn-by m))
         (valence (mfn-valence m))
         (members (mfn-members m))
         (class-parts (list "mfn-sequence"))
         (is-sorting  (member :sorting by))
         (is-reducing (member :reducing by)))

    ;; Build CSS class string from properties
    (when is-sorting  (push "sortable" class-parts))
    (when is-reducing (push "reducable" class-parts))

    (let ((class-string (format nil "~{~a~^ ~}" (reverse class-parts))))
      `(:div :class ,class-string
             ,@(if valence
                   (generate-with-valence medium members valence)
                   (loop :for member :in members
                         :for ix :from 0
                         :collect `(:div :class "mfn-item"
                                         :index ,ix
                                         ,(generate medium member))))))))

(defmethod generate ((medium seed.modulate::uim-web) (m mfn-container))
  "Generate HTML for a container manifestation."
  (let ((members (mfn-members m))
        (name (mfn-name m)))
    `(:div :class "mfn-container"
           ,@(when name (list :id (lisp->camel-case name)))
           ,@(loop :for member :in members
                   :collect (generate medium member)))))

;;; Default method for non-manifestation values passed through

(defmethod generate ((medium seed.modulate::uim-web) (m string))
  m)

(defmethod generate ((medium seed.modulate::uim-web) (m symbol))
  (when m (lisp->camel-case m)))

(defmethod generate ((medium seed.modulate::uim-web) (m null))
  nil)

;;; ===================================================================
;;; SECTION: Valence rendering helper
;;; ===================================================================

(defun generate-with-valence (medium members valence)
  "Render sequence members according to a valence specification.
   Valence is a list of numbers where negative values indicate header items
   and positive values indicate body group size.
   E.g., (-2 4) means: first 2 items go in header, rest group by 4."
  (let ((header-items)
        (body-items)
        (index 0)
        (member-count (length members)))

    ;; Parse valence spec: negative numbers = header count, positive = body group size
    (dolist (v valence)
      (if (minusp v)
          ;; Take |v| items as header
          (let ((count (abs v)))
            (loop :for i :below count :while (< index member-count)
                  :do (push (nth index members) header-items)
                      (incf index)))
          ;; Remaining items group by v
          (loop :while (< index member-count)
                :collect (let ((group))
                           (loop :for i :below v :while (< index member-count)
                                 :do (push (nth index members) group)
                                     (incf index))
                           (push (reverse group) body-items)))))

    (setf header-items (reverse header-items)
          body-items   (reverse body-items))

    ;; Generate HTML structure
    (append
     ;; Header section
     (when header-items
       (list `(:div :class "mfn-header"
                    ,@(loop :for item :in header-items
                            :collect (generate medium item)))))
     ;; Body sections (grouped)
     (loop :for group :in body-items
           :collect `(:div :class "mfn-body-group"
                           ,@(loop :for item :in group
                                   :for ix :from 0
                                   :collect `(:div :class "mfn-item"
                                                   ,(generate medium item))))))))

;;; ===================================================================
;;; SECTION: Render method — produces HTML string from manifestation tree
;;; ===================================================================

(defmethod seed.modulate::render ((medium seed.modulate::uim-web) (component manifestation))
  "Render a manifestation tree to an HTML string via spinneret."
  (let* ((out-stream (make-string-output-stream))
         (spinneret:*html-style* :tree)
         (spinneret:*always-quote* t)
         (spinneret:*html* out-stream))
    (spinneret:interpret-html-tree (generate medium component))
    (values (get-output-stream-string out-stream)
            (close out-stream))))
