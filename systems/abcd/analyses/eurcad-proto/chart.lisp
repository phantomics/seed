(in-package #:abcd)

:properties
(list :name "EURCAD Proto" :description "Description of this analysis.")

:chart-entities
(fx
 (chart-view chart-test-eurcad
  (fx "/tmp/EURUSD.data2.csv" (:fx :uicc-field) (:type :text))
  (fx (:fx :uic-series :layout (:groups :rows (-2 4)))
   (:role (uir-call-form :options (list 'line 'retrace)) (uir-reducable)))
  (fx
   (span
    (fx "line" (:fx :uicc-select) (:type :select)
     (:options "line" "retraceX" "retraceY"))
    (fx (nth 0 '(:none :left :right :both)) (:fx :uicc-button) (:type)
     (:role (uir-toggle :symap '(:| ∘─∘ | :|─∘─∘ | :| ∘─∘─| :─∘─∘─))))
    (fx 23 (:fx :uicc-field) (:type :numeric :integer))
    (fx 1.3348284527687297d0 (:fx :uicc-field) (:type :numeric :float))
    (fx 256 (:fx :uicc-field) (:type :numeric :integer))
    (fx 1.3064244136807817d0 (:fx :uicc-field) (:type :numeric :float))
    (fx 1 (:fx :uicc-field) (:type :numeric :float)))
   (:fx :uic-series :layout (:groups :rows (-2 4)))
   (:role (uir-call-form :options (list 'line 'retrace)) (uir-reducable)))
  (fx
   (span
    (fx "line" (:fx :uicc-select) (:type :select)
     (:options "line" "retraceX" "retraceY"))
    (fx (nth 0 '(:none :left :right :both)) (:fx :uicc-button) (:type)
     (:role (uir-toggle :symap '(:| ∘─∘ | :|─∘─∘ | :| ∘─∘─| :─∘─∘─))))
    (fx 42 (:fx :uicc-field) (:type :numeric :integer))
    (fx 1.3612036319218241d0 (:fx :uicc-field) (:type :numeric :float))
    (fx 299 (:fx :uicc-field) (:type :numeric :integer))
    (fx 1.309032947882736d0 (:fx :uicc-field) (:type :numeric :float))
    (fx 1 (:fx :uicc-field) (:type :numeric :float)))
   (:fx :uic-series :layout (:groups :rows (-2 4)))
   (:role (uir-call-form :options (list 'line 'retrace)) (uir-reducable))))
 (:fx :uic-series :layout (:groups :rows (-2))) (:type :called :removable)
 (:role uir-form uir-call-form uir-reducable (uir-sortable :range 2)))
