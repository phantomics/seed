;;;; seed.lisp 

(in-package #:portal.model.moss)

;; (seed :portal.model.moss
;;       (:bind :package package :of-system of-system :to-grow grow)
;;       (:branches
;;        :view
;;        (lambda (state input)
;;          (if input (case input (:one 1) (:two 2) (:three 3))
;;              (from-system-file :portal.model.moss "moss.lisp" :a)))
;;        :systems
;;        (lambda (state input)
;;          (if input (let ((epsym (intern input "KEYWORD")))
;;                      (of-system :point (intern input "KEYWORD"))
;;                      )
;;              (-<> (with-meta (of-system :contacts)
;;                     :type (:form))
;;                (encode <>))))))
