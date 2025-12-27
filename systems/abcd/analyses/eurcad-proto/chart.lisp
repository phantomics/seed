(in-package #:abcd)

:properties
(list :name "EURCAD Proto" :description "Description of this analysis.")

:chart-entities
(fx
 (chart-view chart-test-eurcad
  (fx "/tmp/EURUSDX.csv" (:fx :uicc-field) (:type :text))
  (fx
   (span
    (fx "line" (:fx :uicc-select) (:type :select)
     (:options "line" "retraceX" "retraceY"))
    (fx (nth 0 '(:none :left :right :both)) (:fx :uicc-button) (:type)
     (:role (uir-toggle :symap '(:| ∘─∘ | :|─∘─∘ | :| ∘─∘─| :─∘─∘─))))
    (fx 364 (:fx :uicc-field) (:type :numeric :integer))
    (fx 1.5145164983713355d0 (:fx :uicc-field) (:type :numeric :float))
    (fx 1454 (:fx :uicc-field) (:type :numeric :integer))
    (fx 1.3330432736156352d0 (:fx :uicc-field) (:type :numeric :float)))
   (:fx :uic-series :layout (:groups :rows (-2 4)))
   (:role uir-form uir-call-form (uir-reducable)))
  (fx
   (span
    (fx "line" (:fx :uicc-select) (:type :select)
     (:options "line" "retraceX" "retraceY"))
    (fx (nth 0 '(:none :left :right :both)) (:fx :uicc-button) (:type)
     (:role (uir-toggle :symap '(:| ∘─∘ | :|─∘─∘ | :| ∘─∘─| :─∘─∘─))))
    (fx 364 (:fx :uicc-field) (:type :numeric :integer))
    (fx 1.5145164983713355d0 (:fx :uicc-field) (:type :numeric :float))
    (fx 948 (:fx :uicc-field) (:type :numeric :integer))
    (fx 1.3669097557003258d0 (:fx :uicc-field) (:type :numeric :float)))
   (:fx :uic-series :layout (:groups :rows (-2 4)))
   (:role uir-form uir-call-form (uir-reducable)))
  (fx
   (span
    (fx "line" (:fx :uicc-select) (:type :select)
     (:options "line" "retraceX" "retraceY"))
    (fx (nth 0 '(:none :left :right :both)) (:fx :uicc-button) (:type)
     (:role (uir-toggle :symap '(:| ∘─∘ | :|─∘─∘ | :| ∘─∘─| :─∘─∘─))))
    (fx 360 (:fx :uicc-field) (:type :numeric :integer))
    (fx 1.5145164983713355d0 (:fx :uicc-field) (:type :numeric :float))
    (fx 1852 (:fx :uicc-field) (:type :numeric :integer))
    (fx 1.4269748371335504d0 (:fx :uicc-field) (:type :numeric :float)))
   (:fx :uic-series :layout (:groups :rows (-2 4)))
   (:role uir-call-form (uir-reducable))))
 (:fx :uic-series :layout (:groups :rows (-2))) (:type :called :removable)
 (:role uir-form uir-call-form uir-reducable (uir-sortable :range 2)))
