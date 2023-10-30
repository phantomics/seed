;; sheet.lisp
;; Seed-interfaced file - do not edit manually

(in-package #:demo.sheet)

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
:table
(defvar *input*
  '(meta (((meta nil (:name . :to-solve) (:title . "?") (:type :trigger))
           (meta 0 (:name . :v-0) (:type :field :numeric))
           (meta "" (:name . :u-0) (:type :select :dropdown) (:title . "Unit")
            (:action . :branch-reload)
            (:options "mm" "cm" "in" "ft")))
          ((meta nil (:name . :to-solve) (:title . "?") (:type :trigger))
           (meta 0 (:name . :v-1) (:type :field :numeric))
           (meta "" (:name . :u-1) (:type :select :dropdown) (:title . "Unit")
            (:action . :branch-reload)
            (:options "mm" "cm" "in" "ft"))))
    (:type :set :form :tabular
     )))
