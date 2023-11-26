;; sheet.lisp
;; Seed-interfaced file - do not edit manually

(in-package #:demo.sheet)
(defvar *profile* nil)
(defvar *graph-nodes* nil)
(defvar *active-graph-item* nil)
(defvar *input* nil)

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
        (:type :set :form)))
:graph-node-indices
'(0 1 2)
:graph
(setf *graph-nodes*
        (seed.generate::build-directed-graph
         (((meta (:title . "First node.")
            (:type :field :text :pair :block :labeled))
           (meta (:dialog . "Knock knock.")
            (:type :field :text :pair :block :labeled)))
          (((meta (:title . "Link to second node.")
             (:type :field :text :pair :block :labeled))
            (meta (:dialog . "Who's there?")
             (:type :field :text :pair :block :labeled)))
           1))
         (((meta (:title . "Second node. aaa")
            (:type :field :text :pair :block :labeled))
           (meta (:dialog . "Bob.")
            (:type :field :text :pair :block :labeled)))
          (((meta (:title . "Link to third node.")
             (:type :field :text :pair :block :labeled))
            (meta (:dialog . "Bob who?")
             (:type :field :text :pair :block :labeled)))
           2))
         (((meta (:title . "Third node.")
            (:type :field :text :pair :block :labeled))
           (meta (:dialog . "Bob Ross.")
            (:type :field :text :pair :block :labeled)))
          (((meta (:title . "Link to first node.")
             (:type :field :text :pair :block :labeled))
            (meta (:dialog . "I'll show you a happy little tree you son of a-")
             (:type :field :text :pair :block :labeled)))
           0)
          (((seed.sublimate:meta (:title . "Link 1")
                                 (:type :field :text :pair :block :labeled))
            (seed.sublimate:meta (:dialog . "Text 1")
                                 (:type :field :text :pair :block :labeled)))
           1)
          (((seed.sublimate:meta (:title . "Link 2")
                                 (:type :field :text :pair :block :labeled))
            (seed.sublimate:meta (:dialog . "Text 2")
                                 (:type :field :text :pair :block :labeled)))
           1)
          (((seed.sublimate:meta (:title . "Link 3")
                                 (:type :field :text :pair :block :labeled))
            (seed.sublimate:meta (:dialog . "")
                                 (:type :field :text :pair :block :labeled)))
           0))))
:graph-original
(setf *graph-nodes*
        (seed.generate::build-directed-graph
         (((meta (:title . "First node.")
            (:type :field :text :pair :block :labeled))
           (meta (:dialog . "Knock knock.")
            (:type :field :text :pair :block :labeled)))
          (((meta (:title . "Link to second node.")
             (:type :field :text :pair :block :labeled))
            (meta (:dialog . "Who's there?")
             (:type :field :text :pair :block :labeled)))
           1))
         (((meta (:title . "Second node.")
            (:type :field :text :pair :block :labeled))
           (meta (:dialog . "Bob.")
            (:type :field :text :pair :block :labeled)))
          (((meta (:title . "Link to third node.")
             (:type :field :text :pair :block :labeled))
            (meta (:dialog . "Bob who?")
             (:type :field :text :pair :block :labeled)))
           2))
         (((meta (:title . "Third node.")
            (:type :field :text :pair :block :labeled))
           (meta (:dialog . "Bob Ross.")
            (:type :field :text :pair :block :labeled)))
          (((meta (:title . "Link to first node.")
             (:type :field :text :pair :block :labeled))
            (meta (:dialog . "I'll show you a happy little tree you son of a-")
             (:type :field :text :pair :block :labeled)))
           0))))
:graph-node-template
(quote (((meta (:title . "Untitled node")
               (:type :field :text :pair :block :labeled))
         (meta (:dialog . "")
               (:type :field :text :pair :block :labeled)))))
:graph-link-template
(quote (((meta (:title . "Untitled link")
               (:type :field :text :pair :block :labeled))
         (meta (:dialog . "")
               (:type :field :text :pair :block :labeled)))))
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
        (:type :set :form :tabular
         )))
