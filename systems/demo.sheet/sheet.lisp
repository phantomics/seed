;; sheet.lisp
;; Seed-interfaced file - do not edit manually

(in-package #:demo.sheet)
(defvar *profile* nil)
(defvar *graph-nodes* nil)
(defvar *esgraph-nodes* nil)
(defvar *active-graph-item* nil)
(defvar *input* nil)

;; (quote
;; (list
;;  (DRAW LINE 1534114800000 1.5352056 1538067600000 1.4786885)
;;  (DRAW LINE 1534230000000 1.4762203999999999d0 1538456400000 1.5159552)
;;  (DRAW LINE 1534230000000 1.4762203999999999d0 1538456400000 1.5159552)
;; ))

:cells
(setf *cell-matrix*
      (make-array '(10 10) :initial-contents
                  '((0 0 0 0 0 0 0 0 0 0) (0 0 0 0 0 0 0 0 0 0)
                    (9 9 9 0 0 0 0 0 0 0) (4 0 0 0 0 0 0 0 0 0)
                    (5 0 0 0 0 0 0 0 0 0) (0 0 0 0 0 0 0 0 0 0)
                    (0 6 0 0 0 0 0 0 0 0) (0 7 0 0 0 0 0 0 0 0)
                    (0 0 0 0 0 0 0 0 0 0) (0 0 0 0 0 0 0 0 0 0))))
:main
(progn
(for-cells "C2.G8" "{5+⍵}")
(for-cells "A3.B4" "{3×⍵}")
)
:chart-entities
(quote
 (meta ((meta "This is a test."
              (:fx . :uicc-field) (:type :text))
        (meta "This is a test 2."
              (:fx . :uicc-field) (:type :text))
        (meta ((meta (:point-from . 10)
                     (:fx . :uicc-field) (:type :numeric :integer :pair :named))
               (meta (:point-to . 20)
                     (:fx . :uicc-field) (:type :numeric :integer :pair :named)))
              (:fx . :uic-series) (:type :enum) (:layout :group :rows (2)))
        (meta ((meta (:point-from . 11)
                     (:fx . :uicc-field) (:type :numeric :integer :pair :named))
               (meta (:point-to . 21)
                     (:fx . :uicc-field) (:type :numeric :integer :pair :named)))
              (:fx . :uic-series) (:type :enum) (:layout :group :rows (2)))
        (meta ((meta (:point-from . 12)
                     (:fx . :uicc-field) (:type :numeric :integer :pair :named))
               (meta (:point-to . 22)
                     (:fx . :uicc-field) (:type :numeric :integer :pair :named)))
              (:fx . :uic-series) (:type :enum) (:layout :group :rows (2)))
        (meta ((meta (:point-from . 13)
                     (:fx . :uicc-field) (:type :numeric :integer :pair :named))
               (meta (:point-to . 23)
                     (:fx . :uicc-field) (:type :numeric :integer :pair :named)))
              (:fx . :uic-series) (:type :enum) (:layout :group :rows (2))))
      (:fx . :uic-series) (:type :sortable)))
:form
(setf *profile*
      '(meta ((meta "Dave" (:title . "Name") (:name . :name) (:type :field :text))
              (meta 34 (:title . "Age") (:name . :age)
               (:type :field :numeric :integer))
              (meta "Red" (:title . "Fav. Color") (:options "Red" "Green" "Blue")
               (:name . :fav-color) (:type :select))
              (meta nil (:title . "Member?") (:name . :member) (:type :boolean))
              (meta nil (:title . "Submit") (:name . :submit)
               (:type :submit-control)))
        (:type :series :form)))
:graph-node-indices
'(0 1 2 3 4 5 6 7)
#|
           (meta (:type . :option) (:options :option :switch :input :gate)
            (:fx . :uicc-select) (:name . :type)
            (:type :select :dropdown))

|#
:graph-node-template
(quote (((meta (:title . "Untitled node")
               (:fx . :uicc-field) (:type :text :pair :named :block))
         (meta (:image . "none") (:title . "Image")
               (:options "none" "man-relaxed" "man-irritated"
                         "girl-relaxed" "girl-irritated")
               (:fx . :uicc-select) (:name . :persona-image) (:type :select))
         (meta (:dialog . "")
               (:fx . :uicc-field) (:type :text :area :pair :named :block)))))
:graph-link-template
(quote (((meta (:title . "Untitled link")
               (:fx . :uicc-field) (:type :text :pair :named :block))
         (meta (:dialog . "")
               (:fx . :uicc-field) (:type :text :pair :named :block)))))
:graph
(setf *graph-nodes*
        (seed.generate::build-directed-graph
         (((meta (:title . "Introductory sentence") (:fx . :uicc-field)
            (:type :text :pair :named :block))
           (meta (:image . "none") (:template meta-template.customers-image)
                 ;; (:title . "Image")
                 ;; (:options "none" "man-relaxed" "man-irritated" "girl-relaxed"
                 ;;           "girl-irritated")
                 ;; (:fx . :uicc-select) (:name . :persona-image)
                 ;; (: type :select :dropdown)
                 )
           (meta
            (:dialog
             . "Two people appear at the counter. Guests, most likely. HELLO")
            (:fx . :uicc-field) (:type :text :area :pair :named :block)))
          (((meta (:title . "Ask who?") (:fx . :uicc-field)
             (:type :text :pair :named :block))
            (meta (:dialog . "Who are you?") (:fx . :uicc-field)
             (:type :text :area :pair :named :block)))
           1)
          (((meta (:title . "Ask why?") (:fx . :uicc-field)
             (:type :text :pair :named :block))
            (meta (:dialog . "Why are you calling me?") (:fx . :uicc-field)
             (:type :text :area :pair :named :block)))
           2))
         (((meta (:title . "Why we're here") (:fx . :uicc-field)
            (:type :text :pair :named :block))
           (meta (:image . "man-relaxed") (:template meta-template.customers-image)
                 ;; (:title . "Image")
                 ;; (:options "none" "man-relaxed" "man-irritated" "girl-relaxed"
                 ;;           "girl-irritated")
                 ;; (:fx . :uicc-select) (:name . :persona-image) (:type :select)
                 )
           (meta
            (:dialog
             . "We have an event scheduled here, it's happening in two weeks and we haven't received the confirmation we requested from you. ")
            (:fx . :uicc-field) (:type :text :area :pair :named :block)))
          (((meta (:title . "Back") (:fx . :uicc-field)
             (:type :text :pair :named :block))
            (meta (:dialog . "Back to start.") (:fx . :uicc-field)
             (:type :text :pair :named :block)))
           0))
         (((meta (:title . "We got a receipt") (:fx . :uicc-field)
            (:type :text :pair :named :block))
           (meta (:image . "man-irritated") (:title . "Image")
            (:options "none" "man-relaxed" "man-irritated" "girl-relaxed"
             "girl-irritated")
            (:fx . :uicc-select) (:name . :persona-image) (:type :select))
           (meta
            (:dialog
             . "\"I know for a fact that our group reservation was acknowledged, your website gave us a receipt number. It's 000XB71.\"")
            (:fx . :uicc-field) (:type :text :area :pair :named :block))))
         (((meta (:title . "Who we are: Annapurna") (:fx . :uicc-field)
            (:type :text :pair :named :block))
           (meta (:image . "girl-relaxed") (:title . "Image")
            (:options "none" "man-relaxed" "man-irritated" "girl-relaxed"
             "girl-irritated")
            (:fx . :uicc-select) (:name . :persona-image) (:type :select))
           (meta
            (:dialog
             . "\"We're organizing the 2025 Global Guru Collective for Annapurna Essential Oils. Annapurna is on a mission to use our 2000 years' Vedic study of pure plant essences to bring humankind closer to samadhi.\"")
            (:fx . :uicc-field) (:type :text :area :pair :named :block))))
         (((meta (:title . "Annapurna: Gurus, not sales reps")
            (:fx . :uicc-field) (:type :text :pair :named :block))
           (meta (:image . "girl-relaxed") (:title . "Image")
            (:options "none" "man-relaxed" "man-irritated" "girl-relaxed"
             "girl-irritated")
            (:fx . :uicc-select) (:name . :persona-image) (:type :select))
           (meta
            (:dialog
             . "\"You see, Annapurna isn't a business in the traditional sense. We're dedicated to spiritual evolution. We don't have employees, distributors, consultants or coaches. Annapurna products are conveyed to customers by the hands of our Gurus, who learn to impart the wisdom of the four jhanas along with our line of products.\"")
            (:fx . :uicc-field) (:type :text :area :pair :named :block))))
         (((meta (:title . "Annapurna: Gurus, not sales reps 1")
            (:fx . :uicc-field) (:type :text :pair :named :block))
           (meta (:image . "girl-relaxed") (:title . "Image")
            (:options "none" "man-relaxed" "man-irritated" "girl-relaxed"
             "girl-irritated")
            (:fx . :uicc-select) (:name . :persona-image) (:type :select))
           (meta
            (:dialog
             . "\"You see, Annapurna isn't a business in the traditional sense. We're dedicated to spiritual evolution. We don't have employees, distributors, consultants or coaches. Annapurna products are conveyed to customers by the hands of our Gurus, who learn to impart the wisdom of the four jhanas along with our line of products.\"")
            (:fx . :uicc-field) (:type :text :area :pair :named :block))))
         (((meta (:title . "More stuff") (:fx . :uicc-field)
            (:type :text :pair :named :block))
           (meta (:image . "none") (:title . "Image")
            (:options "none" "man-relaxed" "man-irritated" "girl-relaxed"
             "girl-irritated")
            (:fx . :uicc-select) (:name . :persona-image) (:type :select))
           (meta (:dialog . "") (:fx . :uicc-field)
            (:type :text :area :pair :named :block))))
         (((meta (:title . "Untitled node") (:fx . :uicc-field)
            (:type :text :pair :named :block))
           (meta (:image . "none") (:title . "Image")
            (:options "none" "man-relaxed" "man-irritated" "girl-relaxed"
             "girl-irritated")
            (:fx . :uicc-select) (:name . :persona-image) (:type :select))
           (meta (:dialog . "") (:fx . :uicc-field)
            (:type :text :area :pair :named :block))))
         (((meta (:title . "Untitled node") (:fx . :uicc-field)
            (:type :text :pair :named :block))
           (meta (:image . "none") (:title . "Image")
            (:options "none" "man-relaxed" "man-irritated" "girl-relaxed"
             "girl-irritated")
            (:fx . :uicc-select) (:name . :persona-image) (:type :select))
           (meta (:dialog . "") (:fx . :uicc-field)
            (:type :text :area :pair :named :block))))))
;; :graph-original
#|
(setf *graph-nodes*
        (seed.generate::build-directed-graph
         (((meta (:title . "First node.")
            (:fx . :uicc-field) (:type :text :pair :named :block))
           (meta (:dialog . "Knock knock.")
            (:fx . :uicc-field) (:type :text :pair :named :block)))
          (((meta (:title . "Link to second node.")
             (:fx . :uicc-field) (:type :text :pair :named :block))
            (meta (:dialog . "Who's there?")
             (:fx . :uicc-field) (:type :text :pair :named :block)))
           1))
         (((meta (:title . "Second node.")
            (:fx . :uicc-field) (:type :text :pair :named :block))
           (meta (:dialog . "Bob.")
            (:fx . :uicc-field) (:type :text :pair :named :block)))
          (((meta (:title . "Link to third node.")
             (:fx . :uicc-field) (:type :text :pair :named :block))
            (meta (:dialog . "Bob who?")
             (:fx . :uicc-field) (:type :text :pair :named :block)))
           2))
         (((meta (:title . "Third node.")
            (:fx . :uicc-field) (:type :text :pair :named :block))
           (meta (:dialog . "Bob Ross.")
            (:fx . :uicc-field) (:type :text :pair :named :block)))
          (((meta (:title . "Link to first node.")
             (:fx . :uicc-field) (:type :text :pair :named :block))
            (meta (:dialog . "I'll show you a happy little tree you son of a-")
             (:fx . :uicc-field) (:type :text :pair :named :block)))
           0))))
|#
:esgraph-node-template
(quote (((meta (:title . "Untitled node")
               (:fx . :uicc-field) (:type :text :pair :named :block))
         (meta (:code . "")
               (:type :code-area :lang-apl)))))
:esgraph-link-template
(quote (((meta (:title . "Untitled link")
               (:fx . :uicc-field) (:type :text :pair :named :block)))))
:esgraph-node-indices
'(0 1 2)
:esgraph
(setf *esgraph-nodes*
        (seed.generate::build-directed-graph
         (((meta (:title . "Untitled node 1")
            (:fx . :uicc-field) (:type :text :pair :named :block))
           (meta (:code . "myNS←baseManifest myNS")
            (:type :code-area :lang-apl)))
          (((meta (:title . "To node 2")
             (:fx . :uicc-field) (:type :text :pair :named :block)))
           1)
          (((meta (:title . "To node 2 second")
             (:fx . :uicc-field) (:type :text :pair :named :block)))
           1))
         (((meta (:title . "Untitled node 2")
            (:fx . :uicc-field) (:type :text :pair :named :block))
           (meta (:code . "myNS←reduceRadiiLogical myNS")
            (:type :code-area :lang-apl)))
          (((meta (:title . "To node 3")
             (:fx . :uicc-field) (:type :text :pair :named :block)))
           2))
         (((meta (:title . "Untitled node 3")
            (:fx . :uicc-field) (:type :text :pair :named :block))
           (meta (:code . "myNS←reduceSlotConductorsWhole myNS")
            (:type :code-area :lang-apl)))
          (((meta (:title . "Back to start")
             (:fx . :uicc-field) (:type :text :pair :named :block)))
           0))))
:table
(setf *input*
      '(meta (((meta nil (:name . :to-solve) (:title . "? Flow Rate") (:type :trigger))
               (meta 400.0 (:name . :v-0) (:type :field :numeric))
               (meta "STB/d" (:name . :u-0) (:type :select :dropdown) (:title . "Unit")
                (:action . :branch-reload)
                (:options "STB/d")))
              ((meta nil (:name . :to-solve) (:title . "? Well Pressure") (:type :trigger))
               (meta 500.0 (:name . :v-1) (:type :field :numeric))
               (meta "psi" (:name . :u-1) (:type :select :dropdown) (:title . "Unit")
                (:action . :branch-reload)
                (:options "psi")))
              ((meta nil (:name . :to-solve) (:title . "? Avg. Res. Pres.") (:type :trigger))
               (meta 1500.0 (:name . :v-2) (:type :field :numeric))
               (meta "psi" (:name . :u-2) (:type :select :dropdown) (:title . "Unit")
                (:action . :branch-reload)
                (:options "psi")))
              ((meta nil (:name . :to-solve) (:title . "? Permeability") (:type :trigger))
               (meta 50.0 (:name . :v-3) (:type :field :numeric))
               (meta "mD" (:name . :u-3) (:type :select :dropdown) (:title . "Unit")
                (:action . :branch-reload)
                (:options "mD")))
              ((meta nil (:name . :to-solve) (:title . "? Formation Thickness") (:type :trigger))
               (meta 25.0 (:name . :v-4) (:type :field :numeric))
               (meta "ft" (:name . :u-4) (:type :select :dropdown) (:title . "Unit")
                (:action . :branch-reload)
                (:options "ft")))
              ((meta nil (:name . :to-solve) (:title . "? Viscosity") (:type :trigger))
               (meta 2.8345143463802374 (:name . :v-5) (:type :field :numeric))
               (meta "cP" (:name . :u-5) (:type :select :dropdown) (:title . "Unit")
                (:action . :branch-reload)
                (:options "cP")))
              ((meta nil (:name . :to-solve) (:title . "? Formation Factor") (:type :trigger))
               (meta 1.20 (:name . :v-6) (:type :field :numeric))
               (meta "res-ft^{3}/std-ft^{3}" (:name . :u-6) (:type :select :dropdown) (:title . "Unit")
                (:action . :branch-reload)
                (:options "res-ft^{3}/std-ft^{3}")))
              ((meta nil (:name . :to-solve) (:title . "? Well Radius") (:type :trigger))
               (meta 0.5 (:name . :v-7) (:type :field :numeric))
               (meta "ft" (:name . :u-7) (:type :select :dropdown) (:title . "Unit")
                (:action . :branch-reload)
                (:options "ft")))
              ((meta nil (:name . :to-solve) (:title . "? Drainage Radius") (:type :trigger))
               (meta 1500.0 (:name . :v-8) (:type :field :numeric))
               (meta "ft" (:name . :u-8) (:type :select :dropdown) (:title . "Unit")
                (:action . :branch-reload)
                (:options "ft")))
              ((meta nil (:name . :to-solve) (:title . "? Skin Factor") (:type :trigger))
               (meta -1.0 (:name . :v-9) (:type :field :numeric)))
              )
        (:type :series :form :tabular
         )))
