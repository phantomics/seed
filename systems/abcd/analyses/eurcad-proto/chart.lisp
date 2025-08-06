(in-package #:abcd)

:properties
(list :name "EURCAD Proto" :description "Description of this analysis.")

:chart-entities
(fx (chart-view :chart-test "data"
      (fx
       (span
        (fx "line" (:fx :uicc-select) (:type :select)
            (:options "line" "retraceX" "retraceY"))
        (fx 1324252800000 (:fx :uicc-field)
            (:type :numeric :integer))
        (fx 491.8025728987993d0 (:fx :uicc-field)
            (:type :numeric :float))
        (fx 1328572800000 (:fx :uicc-field)
            (:type :numeric :integer))
        (fx 379.4218113207547d0 (:fx :uicc-field)
            (:type :numeric :float)))
       (:fx :uic-series :layout (:groups :rows (-1 4)))
       (:role (uir-call-form :options (list 'line 'retrace))))
      (fx
       (span
        (fx "line" (:fx :uicc-select) (:type :select)
            (:options "line" "retraceX" "retraceY"))
        (fx 1324080000000 (:fx :uicc-field)
            (:type :numeric :integer))
        (fx 418.7822229845626d0 (:fx :uicc-field)
            (:type :numeric :float))
        (fx 1327881600000 (:fx :uicc-field)
            (:type :numeric :integer))
        (fx 482.84468610634656d0 (:fx :uicc-field)
            (:type :numeric :float)))
       (:fx :uic-series :layout (:groups :rows (-1 4)))
       (:role (uir-call-form :options (list 'line 'retrace)))))
    (:fx :uic-series :layout (:groups :rows (-2)))
    (:type :called)
    (:role uir-call-form (uir-sortable :range 2)))
