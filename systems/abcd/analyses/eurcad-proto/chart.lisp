(in-package #:abcd)

:properties
(list :name "EURCAD Proto" :description "Description of this analysis.")

:chart-entities
(fx (chart-view :chart-test "data")
    (:fx :uic-series :layout (:groups :rows (-2))) (:type :called) (:role uir-call-form (uir-sortable :range 2)))
