(in-package #:abcd)

:properties
(list :name "USDJPY proto" :description "This is an analysis of USDJPY currency pair.")

:chart-entities
(fx (chart-view :chart-test "data")
    (:fx :uic-series :layout (:groups :rows (-2)))
    (:type :called) (:role uir-call-form (uir-sortable :range 2)))
