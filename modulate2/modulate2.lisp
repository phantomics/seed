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
;;;;
;;;; The expression pipeline runs in two tiers:
;;;;   Tier 2 (named): branch-supplied :adapting processors, applied to the
;;;;                   manifestation tree in series (medium-independent).
;;;;   Tier 1 (default): modality-driven affordances (:reducing -> remove
;;;;                   controls, etc.), injected at generate time when the
;;;;                   medium is known.

(in-package #:seed.modulate2)

;;; ===================================================================
;;; SECTION: IS vocabulary — data character and structural identity
;;; ===================================================================

;;; The :is axis is mostly inferred from the wrapped value's Lisp type.
;;; Explicit :is annotations are needed only when inference would err
;;; (e.g., nil as boolean vs. absent, string as pathname vs. plain text).
;;;
;;; Two strata live within IS:
;;;   Stratum 1 — structural identity that the type system verifies
;;;               (:integer, :string, :list ...). Ground truth.
;;;   Stratum 2 — conventional interpretation the developer asserts
;;;               (:properties, :associations, :pathname). Not provable
;;;               from the data alone; the decimal point that the packed
;;;               format does not itself carry. Never inferred presumptuously
;;;               — only via explicit annotation or (eventually) an explicit
;;;               contextual directive that authorizes the inference.

(defun infer-data-character (value)
  "Infer the stratum-1 data character of a value from its Common Lisp type.
   Returns a keyword describing the value's intrinsic structural nature."
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
    (function    :function)
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

;;; Roles that mark a list value as compound-atomic: the list is a unit
;;; (a call, a definition) rather than a sequence of expressible members.

(defparameter +as-atomic-roles+
  '(:fn-called :macro-spec :definition :binding-form :iteration :code :data-literal)
  "AS roles whose list values are treated as a single atom, not a sequence.")

;;; Interface-structural roles (for dx forms describing live interface objects).
;;; AS in dx answers the same question as in fx — "what is your role in the
;;; containing whole?" — but the containing whole is the interface rather than
;;; the program.  Layout directives are structured sub-forms under :as,
;;; parsed out by parse-as-spec, e.g. (:as :workspace (:layout :horizontal :even)).

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
  "The vocabulary of interface-structural semantic roles for the :as axis (dx forms).
   Layout directives appear as structured sub-forms: (:layout ...).  The layout
   vocabulary grows from usage; no fixed enumeration is imposed.")

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
    :activating           ; user triggers an action (injected controls use this)

    ;; Manipulation modes (for sequences/containers)
    :sorting              ; items can be reordered
    :reducing             ; items can be removed
    :extending            ; items can be added

    ;; Provisioning — abstract engagement modes for rich content.  The medium's
    ;; generate methods choose the concrete widget (CodeMirror, dygraph, etc.).
    :provision-text       ; engage with character data through an editor
    :provision-sheet      ; engage with tabular data
    :provision-chart      ; engage with time-series / plotted data
    :provision-graph      ; engage with a node-link network
    :provision-form       ; engage with structured fields as a submittable unit

    ;; Suppression
    :bare                 ; suppress Tier-1 default affordances for this node
    )
  "The vocabulary of interaction modalities for the :by axis.  Structured
   sub-forms (:valence ...) and (:adapting ...) are parsed out separately.")

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
           :documentation "Interaction modality: the flat modality keywords for this element.")
   (%name  :accessor mfn-name
           :initform nil
           :initarg  :name
           :documentation "Identifying name for reference and state attachment.")
   (%path  :accessor mfn-path
           :initform nil
           :initarg  :path
           :documentation "Path from root to this element, for addressing within a tree.")
   (%adapting :accessor mfn-adapting
              :initform nil
              :initarg  :adapting
              :documentation "Named :adapting hooks (keywords) this node is receptive to.
                             Tier-2 processors from the lexicon are matched against these.")
   (%controls :accessor mfn-controls
              :initform nil
              :initarg  :controls
              :documentation "Control manifestations injected for this node's header region.
                             Populated by Tier-1 modality defaults and processors.")
   (%defaults-applied :accessor mfn-defaults-applied
                      :initform nil
                      :documentation "Guard so Tier-1 modality defaults run at most once."))
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
                            first 2 items are header, rest group by 4.")
   (%layout  :accessor mfn-layout
             :initform nil
             :initarg  :layout
             :documentation "Layout directive from an (:as (:layout ...)) sub-form. E.g.,
                            (:horizontal :even) or (:vertical :of 3 1 1 1). The vocabulary
                            is open-ended and interpreted by the medium's generate methods."))
  (:documentation
   "A sequence manifestation — an ordered collection of child manifestations.
    Corresponds to lists, series of form fields, sortable collections, etc."))

(defclass mfn-container (manifestation)
  ((%members :accessor mfn-members
             :initform nil
             :initarg  :members
             :documentation "Named or structured child manifestations.")
   (%layout  :accessor mfn-layout
             :initform nil
             :initarg  :layout
             :documentation "Layout directive, as for mfn-sequence."))
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

(defun parse-as-spec (as-spec)
  "Separate an :as spec into its components. An :as spec mixes flat role
   keywords with structured sub-forms, e.g.
     (:workspace (:layout :horizontal :even))
   Returns two values: the flat role keyword list and the layout directive
   (or nil).  The layout vocabulary is open-ended and not enumerated."
  (let ((roles) (layout))
    (dolist (item as-spec)
      (cond ((keywordp item) (push item roles))
            ((and (consp item) (eq :layout (first item)))
             (setf layout (rest item)))))
    (values (nreverse roles) layout)))

(defun parse-by-spec (by-spec)
  "Separate a :by spec into its components. A :by spec mixes flat modality
   keywords with structured sub-forms, e.g.
     (:sorting :reducing (:valence (-2 4)) (:adapting :upload-spec :info-spec))
   Returns three values: the modality keyword list, the valence spec (or nil),
   and the list of :adapting hook keywords (or nil)."
  (let ((modalities) (valence) (adapting))
    (dolist (item by-spec)
      (cond ((keywordp item) (push item modalities))
            ((consp item)
             (case (first item)
               (:valence  (setf valence (second item)))
               (:adapting (setf adapting (rest item)))
               (t nil)))))
    (values (nreverse modalities) valence adapting)))

;;; ===================================================================
;;; SECTION: Expression — transforming fx-annotated data into manifestations
;;; ===================================================================

(defun resolve-is (value explicit-is)
  "Determine the data character for a value, using explicit :is if provided,
   otherwise inferring from the Lisp type. The :- sentinel means
   'inferred base type plus these developer-asserted specializers'."
  (if explicit-is
      (if (eq :- (first explicit-is))
          (cons (infer-data-character value) (rest explicit-is))
          explicit-is)
      (list (infer-data-character value))))

(defun resolve-by (modalities context-interactive-p)
  "Determine the interaction modalities. If none are specified, default based
   on context: non-interactive (observing) unless the context is interactive."
  (cond (modalities modalities)
        (context-interactive-p (list :entering))
        (t (list :observing))))

(defun fx-form-p (form)
  "Test whether a form is an fx-annotated expression (a list starting with the symbol FX)."
  (and (listp form)
       (symbolp (first form))
       (string= "FX" (string (first form)))))

(defun atomic-as-p (as-spec)
  "True when an :as role marks a list value as compound-atomic (a unit, not a
   sequence of expressible members) — e.g. :fn-called, :definition, :code."
  (loop :for role :in as-spec :thereis (member role +as-atomic-roles+)))

(defun express-new (form &key path context-interactive-p)
  "Express an fx-annotated form into a manifestation tree using the IS/AS/BY taxonomy.
   FORM is an s-expression, possibly fx-wrapped. PATH tracks position for addressing.
   CONTEXT-INTERACTIVE-P indicates whether the enclosing context enables interaction.
   Named :adapting processors and Tier-1 modality defaults are applied later, by
   MANIFEST and by the generate pipeline respectively."
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
              (as-raw   (getf parsed :as))
              (by-raw   (getf parsed :by))
              (name     (getf parsed :name))
              (resolved-is (resolve-is value is-spec)))
         (multiple-value-bind (as-roles layout) (parse-as-spec as-raw)
           (multiple-value-bind (modalities valence adapting) (parse-by-spec by-raw)
             (let* ((resolved-by (resolve-by modalities context-interactive-p))
                    ;; A context becomes interactive for children when an explicit
                    ;; interactive modality (anything other than :observing) is present.
                    (children-interactive-p
                      (or context-interactive-p
                          (and modalities (not (member :observing modalities)))))
                    ;; A list value is a sequence unless its :as role marks it atomic.
                    (sequence-p (and (listp value)
                                     (not (atomic-as-p as-roles)))))
               (if sequence-p
                   (let ((members (loop :for i :from 0
                                        :for item :in value
                                        :collect (express-new item
                                                              :path (cons i path)
                                                              :context-interactive-p
                                                              children-interactive-p))))
                     (make-instance 'mfn-sequence
                                    :value value
                                    :is resolved-is
                                    :as as-roles
                                    :by resolved-by
                                    :name name
                                    :path (reverse path)
                                    :adapting adapting
                                    :members members
                                    :valence valence
                                    :layout layout))
                   (make-instance 'mfn-atom
                                  :value value
                                  :is resolved-is
                                  :as as-roles
                                  :by resolved-by
                                  :name name
                                  :adapting adapting
                                  :path (reverse path))))))))

      ;; Plain list of forms (no fx wrapper) — treat as implicit sequence
      ((and (listp form) (some #'fx-form-p form))
       (make-instance 'mfn-sequence
                      :value form
                      :is (list :list)
                      :path (reverse path)
                      :members (loop :for i :from 0
                                     :for item :in form
                                     :collect (express-new item
                                                           :path (cons i path)
                                                           :context-interactive-p
                                                           context-interactive-p))))

      ;; Unrecognized form — wrap as atom
      (t
       (make-instance 'mfn-atom
                      :value form
                      :is (list (infer-data-character form))
                      :path (reverse path))))))

;;; ===================================================================
;;; SECTION: Tier 2 — named :adapting processors
;;; ===================================================================

(defun map-members (fn node)
  "Apply FN to each member of a sequence/container node, replacing the
   member list with the results. Returns NODE."
  (when (typep node '(or mfn-sequence mfn-container))
    (setf (mfn-members node) (mapcar fn (mfn-members node))))
  node)

(defun apply-named-processors (tree processors)
  "Walk the manifestation TREE depth-first; for each node, apply any named
   :adapting processors found in the PROCESSORS lexicon (a plist of
   hook-keyword -> function-of-one-node), in declared order. Each processor
   receives a manifestation and returns a manifestation (possibly the same one,
   possibly a replacement). A hook with no matching processor is silently
   skipped, so the same data expresses differently across branches. Children
   are processed before their parent, so a parent processor sees adapted
   children. Returns the (possibly replaced) tree."
  (when tree
    (map-members (lambda (m) (apply-named-processors m processors)) tree)
    (let ((result tree))
      (dolist (hook (mfn-adapting tree))
        (let ((fn (getf processors hook)))
          (when fn (setf result (funcall fn result)))))
      result)))

;;; ===================================================================
;;; SECTION: Orchestration
;;; ===================================================================

(defun manifest (form &key path processors)
  "Express FORM into a manifestation tree and apply the branch-supplied
   Tier-2 :adapting PROCESSORS. Tier-1 modality defaults are applied later,
   during generation, when the medium is known. Returns a tree ready to render."
  (apply-named-processors (express-new form :path path) processors))

;;; ===================================================================
;;; SECTION: Tier 1 — default modality processors (injected affordances)
;;; ===================================================================

;;; Tier-1 processors inject control manifestations into the tree based on a
;;; node's :by modalities. They run during generation (the medium is then
;;; known) and dispatch on (medium node-class), so a uim-web sorting default
;;; can differ from a future uim-terminal one. A node tagged :bare opts out.

(defun make-control (action label target)
  "Build a control manifestation: a leaf with interface role :controls and
   modality :activating. ACTION is a keyword naming the action, LABEL is the
   display text, TARGET is the path of the element the control acts upon."
  (make-instance 'mfn-atom
                 :value (list :action action :label label :target target)
                 :as (list :controls)
                 :by (list :activating)))

(defun apply-reducing-default (medium node)
  "Tier-1 :reducing — each member of the sequence may be removed. Inject a
   remove control into each member's header region (its %controls). The
   control's target is the member's path, which the renderer wires to the
   reduce action."
  (declare (ignore medium))
  (dolist (member (mfn-members node))
    (when (typep member 'manifestation)
      (push (make-control :remove "×" (mfn-path member))
            (mfn-controls member)))))

(defun apply-sorting-default (medium node)
  "Tier-1 :sorting — STUB. Items may be reordered; a drag-handle wrapper
   should be injected per item. Not yet implemented."
  (declare (ignore medium node))
  ;; TODO: inject per-item drag-handle wrappers (uim-web: htmx/Alpine DnD).
  nil)

(defun apply-extending-default (medium node)
  "Tier-1 :extending — STUB. The sequence may gain items; an 'add item'
   control should be injected into the sequence's own header. Not yet
   implemented."
  (declare (ignore medium node))
  ;; TODO: inject an add-item control into NODE's own %controls.
  nil)

(defgeneric apply-modality-defaults (medium node)
  (:documentation
   "Inject Tier-1 default affordances into NODE based on its :by modalities,
    for the given MEDIUM. Mutates the node (or its members). Specialize per
    medium and per manifestation class."))

(defmethod apply-modality-defaults ((medium seed.modulate::uim-web) (node manifestation))
  "Default: no affordances."
  (declare (ignore medium node))
  nil)

(defmethod apply-modality-defaults ((medium seed.modulate::uim-web) (node mfn-sequence))
  "Inject sequence-level default affordances unless the node is :bare."
  (let ((by (mfn-by node)))
    (unless (member :bare by)
      (when (member :reducing by)  (apply-reducing-default medium node))
      (when (member :sorting by)   (apply-sorting-default medium node))
      (when (member :extending by) (apply-extending-default medium node)))))

;;; ===================================================================
;;; SECTION: Rendering — generate methods for uim-web
;;; ===================================================================

;;; The generate generic here is distinct from seed.modulate's generate, by
;;; design: seed.modulate delegates to it via the *generate-foreign* hook for
;;; manifestation objects, and we delegate back via the (uim-web t) catch-all
;;; for any old-grammar component embedded in a manifestation tree. This lets
;;; the two systems coexist during the migration.

(defgeneric generate (medium component)
  (:documentation "Generate output markup for a manifestation on a given medium."))

(defmethod generate ((medium seed.modulate::uim-web) (m t))
  "Catch-all: a non-manifestation component (e.g. an old-grammar uic object,
   produced by an :adapting processor) embedded in a manifestation tree.
   Delegate to seed.modulate's generate."
  (seed.modulate::generate medium m))

;;; Tier-1 defaults run once per node, just before its body is generated, so
;;; the medium is known and the node's members exist. Injected controls are
;;; then rendered by the header helper.

(defmethod generate :around ((medium seed.modulate::uim-web) (m manifestation))
  (unless (mfn-defaults-applied m)
    (apply-modality-defaults medium m)
    (setf (mfn-defaults-applied m) t))
  (call-next-method))

;;; ===================================================================
;;; SECTION: Provisioning — generate methods for BY :provision-* modalities
;;; ===================================================================

;;; Provisioning modalities describe abstract modes of human engagement with
;;; rich content.  The generate methods here are specialized per medium; the
;;; uim-web methods emit the HTML structure and JavaScript setup for the
;;; concrete browser widgets.

(defun provisioning-modality (by-spec)
  "Return the first :provision-* keyword found in a :by modality list, or nil."
  (find-if (lambda (k) (and (keywordp k)
                             (> (length (string k)) 10)
                             (string= "PROVISION-" (string k) :end2 10)))
           by-spec))

(defun provision-token (name system branch)
  "Build an element-id token from NAME, SYSTEM and BRANCH keywords, matching
   the naming convention used by the existing Seed client-side code."
  (format nil "~@[~a-~]~a~@[-~a~]"
          (when name (string-downcase (string name)))
          (if system (string-downcase (string system)) "local")
          (when branch (string-downcase (string branch)))))

(defun generate-provisioned (medium m)
  "Generate HTML for a provisioned manifestation.  Called from the mfn-atom
   and mfn-sequence primary methods when a :provision-* modality is present."
  (let* ((prov (provisioning-modality (mfn-by m)))
         (name (mfn-name m))
         (value (mfn-value m)))
    (case prov
      (:provision-text
       ;; CodeMirror text editor.  Value is (system branch) for server-fetched
       ;; content, or a string for direct content.
       (let* ((sys-branch (and (listp value) (= 2 (length value)) value))
              (system (first sys-branch))
              (branch (second sys-branch))
              (token  (if sys-branch
                          (format nil "cm-texteditor-~a-~a"
                                  (string-downcase (string system))
                                  (string-downcase (string branch)))
                          (format nil "cm-~a" (or (and name (string-downcase (string name)))
                                                  "editor")))))
         (if sys-branch
             ;; Server-fetched: emit x-init that calls fetch-contact then creates CodeMirror.
             ;; The JavaScript is built at runtime via ps* to avoid compile-time
             ;; package issues with Parenscript pseudo-variables.
             (let ((branch-str (string-downcase (string branch))))
               `(:div :id ,token
                      :class "mfn-provision provision-text"
                      :x-init ,(ps* `(progn (setf (@ window codemirror) nil)
                                            (setf (getprop (@ window seed-elements) ,branch-str)
                                                  $el)
                                            (fetch-contact
                                             $el mode (create text (list 0))
                                             (lambda (data)
                                               (setf (getprop (@ window seed-data) ,token)
                                                     (create-codemirror
                                                      (chain document (get-element-by-id ,token))
                                                      (@ data text)))))))))
             ;; Direct content: emit a div that CodeMirror attaches to, with the
             ;; text as initial content.
             `(:div :id ,token
                    :class "mfn-provision provision-text"
                    :data-content ,(if (stringp value) value "")))))

      (:provision-sheet
       ;; Stub: canvas-datagrid.
       `(:div :class "mfn-provision provision-sheet"
              ,@(when name (list :id (string-downcase (string name))))))

      (:provision-chart
       ;; Stub: dygraph.
       `(:div :class "mfn-provision provision-chart"
              ,@(when name (list :id (string-downcase (string name))))))

      (:provision-graph
       ;; Stub: SVG graph editor.
       `(:div :class "mfn-provision provision-graph"
              ,@(when name (list :id (string-downcase (string name))))))

      (:provision-form
       ;; Stub: submittable form.
       `(:form :class "mfn-provision provision-form"
               ,@(when name (list :id (string-downcase (string name))))))

      (otherwise nil))))

;;; ===================================================================
;;; SECTION: Layout — CSS grid positioning for sequence items
;;; ===================================================================

(defun locate-item (layout index total-members item-html)
  "Apply CSS grid positioning to a rendered item according to a LAYOUT
   directive.  LAYOUT is e.g. (:horizontal :even) or (:vertical :of 3 1 1 1).
   INDEX is the item's position; TOTAL-MEMBERS is the count.  ITEM-HTML is
   the spinneret tree for the item.  Returns the tree with :style added."
  (when (and layout (consp layout) (>= (length layout) 2))
    (destructuring-bind (direction style &rest props) layout
      (when (member direction '(:horizontal :vertical))
        (let ((default-segments 12))
          (case style
            ((:even :of)
             (let* ((divisions (or (first props) default-segments))
                    (width (/ divisions total-members))
                    (start-index index)
                    (next-index 0))
               (if (eq :of style)
                   ;; Proportional: each item gets its declared proportion.
                   ;; Props = (total p1 p2 p3 ...) where p1+p2+... = total.
                   (setf width 1
                         start-index (loop :for i :in (rest props)
                                           :for x :below index
                                           :summing i)
                         next-index (if (= index (1- total-members))
                                        (first props)
                                        (+ start-index (nth index (rest props)))))
                   ;; Even: each item gets equal width.
                   (setf start-index (floor (* width index))
                         next-index  (floor (* width (1+ index)))))
               ;; Splice :style into the item-html tree. The tree is
               ;; (:div :class "..." ... content) — we insert after the tag.
               (let* ((grid-prop (if (eq direction :horizontal)
                                     "grid-column" "grid-row"))
                      (style-val (format nil "~a-start: ~a; ~a-end: ~a;"
                                         grid-prop (1+ start-index)
                                         grid-prop (1+ next-index))))
                 ;; Find existing :style in the item's plist and extend it,
                 ;; or insert a new one.
                 (if (and (consp item-html) (keywordp (first item-html)))
                     (let ((rest-items (rest item-html))
                           (existing-style-pos (position :style (rest item-html))))
                       (if existing-style-pos
                           (setf (nth (1+ existing-style-pos) rest-items)
                                 (format nil "~a ~a"
                                         (nth (1+ existing-style-pos) rest-items)
                                         style-val))
                           ;; Insert :style after the tag keyword.
                           (setf rest-items (list* :style style-val rest-items)))
                       (cons (first item-html) rest-items))
                     item-html))))))))))


(defun emit-header (medium node &optional header-members)
  "Produce the header div for NODE if it has injected controls or designated
   header members, else NIL. Controls and valence header members share the
   header region. Even a node with no valence has a header when it carries
   controls."
  (let ((controls (mfn-controls node)))
    (when (or controls header-members)
      `(:div :class "mfn-header"
             ,@(loop :for hm :in header-members :collect (generate medium hm))
             ,@(loop :for c :in controls :collect (generate medium c))))))

(defmethod generate ((medium seed.modulate::uim-web) (m mfn-atom))
  "Generate HTML for an atomic manifestation, wrapping it with a header when
   it carries injected controls (e.g. a per-item remove button)."
  (let* ((value (mfn-value m))
         (by   (mfn-by m))
         (as   (mfn-as m))
         (modality (first by))
         (provisioned (and (provisioning-modality by)
                           (generate-provisioned medium m)))
         (body
           (or provisioned
            (case modality
             (:activating
              ;; An injected control: render as a button.
              (destructuring-bind (&key action label target) value
                `(:button :class ,(format nil "button mfn-control~@[ ~a~]"
                                          (when action (string-downcase (string action))))
                          ,@(when action
                              (list :data-action (string-downcase (string action))))
                          ,@(when target
                              (list :data-target (format nil "~{~a~^ ~}" target)))
                          ,(or label ""))))

             (:entering
              (let ((display-value (if value (princ-to-string value) ""))
                    (field-name (or (and (mfn-name m) (lisp->camel-case (mfn-name m))) "")))
                `(:div :class "mfn-atom entering"
                       (:label (:span ,field-name))
                       (:input :class "input" :type "text"
                               :value ,display-value
                               :name ,field-name))))

             (:choosing
              (let ((options (rest (member :options by)))
                    (field-name (or (and (mfn-name m) (lisp->camel-case (mfn-name m))) ""))
                    (current-value (if value (princ-to-string value) "")))
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
              (let ((display (rest (member :display by)))
                    (field-name (or (and (mfn-name m) (lisp->camel-case (mfn-name m))) "")))
                (when (and display (listp (first display)))
                  (setf display (first display)))
                `(:div :class "mfn-atom cycling"
                       (:button :name ,field-name
                                :class "button"
                                ,(or (and display (princ-to-string (first display)))
                                     (princ-to-string value))))))

             (:observing
              (let ((display-value (cond ((null value) "")
                                         ((stringp value) value)
                                         (t (princ-to-string value)))))
                `(:span :class ,(format nil "mfn-atom observing~@[ ~a~]"
                                        (when as (string-downcase (princ-to-string (first as)))))
                        ,display-value)))

             (otherwise
              `(:span :class "mfn-atom"
                      ,(if value (princ-to-string value) "")))))))
    (let ((header (emit-header medium m)))
      (if header
          `(:div :class "mfn-item-wrap" ,header ,body)
          body))))

(defun generate-item-list (medium items layout)
  "Generate a list of mfn-item divs from ITEMS, applying CSS grid positioning
   via LAYOUT when present."
  (let ((total (length items)))
    (loop :for item :in items
          :for ix :from 0
          :collect (let ((rendered `(:div :class "mfn-item" :index ,ix
                                         ,(generate medium item))))
                    (if layout
                        (or (locate-item layout ix total rendered) rendered)
                        rendered)))))

(defmethod generate ((medium seed.modulate::uim-web) (m mfn-sequence))
  "Generate HTML for a sequence manifestation. Items carrying their own
   injected controls render those in their own headers; the sequence itself
   renders a header for any controls injected at its level (plus valence
   header members). When a layout directive is present, items are positioned
   via CSS grid within each body group (or the whole member list if no
   valence)."
  (let* ((by (mfn-by m))
         (valence (mfn-valence m))
         (layout  (and (typep m 'mfn-sequence) (mfn-layout m)))
         (members (mfn-members m))
         (provisioned (and (provisioning-modality by)
                           (generate-provisioned medium m)))
         (class-parts (list "mfn-sequence"))
         (is-sorting  (member :sorting by))
         (is-reducing (member :reducing by)))

    (when is-sorting  (push "sortable" class-parts))
    (when is-reducing (push "reducable" class-parts))
    (when layout      (push "grid-layout" class-parts))

    (or provisioned
        (let ((class-string (format nil "~{~a~^ ~}" (reverse class-parts))))
          (if valence
              (multiple-value-bind (header-members body-groups) (split-by-valence members valence)
                `(:div :class ,class-string
                       ,@(let ((h (emit-header medium m header-members))) (when h (list h)))
                       ,@(loop :for group :in body-groups
                               :collect `(:div :class "mfn-body-group"
                                               ,@(generate-item-list medium group layout)))))
              `(:div :class ,class-string
                     ,@(let ((h (emit-header medium m))) (when h (list h)))
                     ,@(generate-item-list medium members layout)))))))

(defmethod generate ((medium seed.modulate::uim-web) (m mfn-container))
  "Generate HTML for a container manifestation."
  (let ((members (mfn-members m))
        (name (mfn-name m)))
    `(:div :class "mfn-container"
           ,@(when name (list :id (lisp->camel-case name)))
           ,@(let ((h (emit-header medium m))) (when h (list h)))
           ,@(loop :for member :in members
                   :collect (generate medium member)))))

;;; Default methods for non-manifestation values passed through

(defmethod generate ((medium seed.modulate::uim-web) (m string))
  m)

(defmethod generate ((medium seed.modulate::uim-web) (m symbol))
  (when m (lisp->camel-case m)))

(defmethod generate ((medium seed.modulate::uim-web) (m null))
  nil)

;;; ===================================================================
;;; SECTION: Valence splitting helper
;;; ===================================================================

(defun split-by-valence (members valence)
  "Split sequence MEMBERS according to a VALENCE spec. Negative numbers take
   that many items into the header; positive numbers group the remaining items
   by that size. Returns two values: the header members, and a list of body
   groups. E.g. (-2 4) over 10 members => 2 header items, then groups of 4."
  (let ((header-items)
        (body-groups)
        (index 0)
        (member-count (length members)))
    (dolist (v valence)
      (if (minusp v)
          (let ((count (abs v)))
            (loop :for i :below count :while (< index member-count)
                  :do (push (nth index members) header-items)
                      (incf index)))
          (loop :while (< index member-count)
                :do (let ((group))
                      (loop :for i :below v :while (< index member-count)
                            :do (push (nth index members) group)
                                (incf index))
                      (push (nreverse group) body-groups)))))
    ;; Any members beyond the valence spec become a final group.
    (when (< index member-count)
      (push (nthcdr index members) body-groups))
    (values (nreverse header-items)
            (nreverse body-groups))))

;;; ===================================================================
;;; SECTION: Construction — building manifestations from dx-style specs
;;; ===================================================================

;;; construct is the runtime counterpart of express-new.  Where express-new
;;; walks a stored (fx) form, construct builds from live values in the branch's
;;; lexical scope.  It is called by the *dx-foreign* hook when the dx macro
;;; encounters a new-grammar (IS/AS/BY keyword) spec list.

(defun parse-dx-spec (spec-list)
  "Parse a dx spec list into its axis components. The spec list is a flat
   interleaving of axis keywords and their values, where values may be atoms
   or structured sub-forms:
     (:as :workspace (:layout :horizontal :even) :by :provision-text :name :main)
   Returns a plist of (:is ... :as-raw ... :by-raw ... :name ...) where the
   -raw values are lists ready for parse-as-spec / parse-by-spec."
  (let ((is) (as-parts) (by-parts) (name) (current-axis nil))
    (dolist (item spec-list)
      (cond
        ;; An axis keyword: switch the current axis.
        ((member item '(:is :as :by :name))
         (setf current-axis item))
        ;; A structured sub-form (list): append to the current axis.
        ((and (consp item) current-axis)
         (case current-axis
           (:as (push item as-parts))
           (:by (push item by-parts))
           (:is (push item is))
           (:name (setf name item))))
        ;; An atom value: assign/append to the current axis.
        (current-axis
         (case current-axis
           (:as   (push item as-parts))
           (:by   (push item by-parts))
           (:is   (push item is))
           (:name (setf name item))))))
    (list :is (nreverse is) :as-raw (nreverse as-parts)
          :by-raw (nreverse by-parts) :name name)))

(defun construct (spec-plist children)
  "Build a manifestation from a dx-style spec list and child values.
   SPEC-PLIST is the evaluated spec list from the dx macro, e.g.
     (:as :workspace (:layout :horizontal :even) :by :provision-text :name :main).
   CHILDREN is the content: nil, a single value, or a list of values (which may
   themselves be manifestations, strings, symbols, or other objects).

   Classification rules:
     - If CHILDREN is nil or atomic, build an mfn-atom.
     - If CHILDREN is a list, build an mfn-sequence with each element as a member.
       Elements that are already manifestations pass through; other values are
       wrapped as mfn-atoms."
  (let* ((parsed (parse-dx-spec spec-plist))
         (is-spec (getf parsed :is))
         (as-raw  (getf parsed :as-raw))
         (by-raw  (getf parsed :by-raw))
         (name    (getf parsed :name)))
    (multiple-value-bind (as-roles layout) (parse-as-spec as-raw)
      (multiple-value-bind (modalities valence adapting) (parse-by-spec by-raw)
        (let ((resolved-by (or modalities (list :observing))))
          (if (and children (listp children))
              ;; Sequence: each child is a member.
              (make-instance 'mfn-sequence
                             :value children
                             :is (or is-spec (list :list))
                             :as as-roles
                             :by resolved-by
                             :name name
                             :adapting adapting
                             :members (loop :for child :in children
                                            :collect (ensure-manifestation child))
                             :valence valence
                             :layout layout)
              ;; Atom: single value or nil.
              (make-instance 'mfn-atom
                             :value children
                             :is (or is-spec (list (infer-data-character children)))
                             :as as-roles
                             :by resolved-by
                             :name name
                             :adapting adapting)))))))

(defun ensure-manifestation (value)
  "If VALUE is already a manifestation, return it unchanged.  Otherwise wrap
   it as an mfn-atom with inferred IS.  This lets dx children mix
   manifestations, strings, symbols, and other values freely."
  (if (typep value 'manifestation)
      value
      (make-instance 'mfn-atom
                     :value value
                     :is (list (infer-data-character value)))))

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

;;; ===================================================================
;;; SECTION: Bridge registration
;;; ===================================================================

;;; Fill in seed.modulate's hooks so it can delegate new-grammar expression and
;;; manifestation generation to us. seed.modulate2 depends on seed.modulate, so
;;; these references are safe; the reverse direction never names this package.

(setf seed.modulate::*express-foreign*
      (lambda (form &key params path processors)
        (declare (ignore params))
        (manifest form :path path :processors processors)))

(setf seed.modulate::*generate-foreign*
      (lambda (medium component)
        (generate medium component)))

(setf seed.modulate::*dx-foreign*
      (lambda (spec-plist children)
        (construct spec-plist children)))
