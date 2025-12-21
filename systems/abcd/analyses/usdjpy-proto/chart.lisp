(in-package #:abcd)

:properties
(list :name "USDJPY proto" :description "This is an analysis of USDJPY currency pair.")

:chart-entities
(fx
 (chart-view :chart-test
  (fx "/tmp/USDJPY.data.csv" (:fx :uicc-field) (:type :text)))
 (:fx :uic-series :layout (:groups :rows (-2))) (:type :called :removable)
 (:role uir-call-form uir-reducable (uir-sortable :range 2)))
