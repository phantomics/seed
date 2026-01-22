(in-package #:abcd)

:properties
(list :name "(#| TMPL_VAR name |#)" :description "")

:chart-entities
(fx
 (chart-view chart-test-(#| TMPL_VAR index |#) (fx "" (:fx :uicc-field) (:type :text)))
 (:fx :uic-series :layout (:groups :rows (-2))) (:type :called :removable)
 (:role uir-call-form uir-reducable (uir-sortable :range 2)))
