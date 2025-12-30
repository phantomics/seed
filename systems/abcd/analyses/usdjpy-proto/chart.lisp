(in-package #:abcd)

:properties
(list :name "USDJPY proto" :description "This is an analysis of USDJPY currency pair.")

:chart-entities
(fx
 (chart-view chart-test-usdjpy
  (fx "/tmp/USDJPY.data.csv" (:fx :uicc-field) (:type :text))
  (fx
   (eset
    (fx
     (essource :file-csv
      (fx "" (:fx :uicc-field) (:type :text) (:title :path)))
     (:fx :uic-series :layout (:groups :rows (-2)))
     (:role (uir-call-form :options (list 'line 'retrace)) (uir-reducable))))
   (:fx :uic-series :layout (:groups :rows (1 2)))
   (:role uir-call-form uir-reducable (uir-call :n :populate))))
 (:fx :uic-series :layout (:groups :rows (-2))) (:type :called :removable)
 (:role uir-call-form uir-reducable (uir-sortable :range 2)))
