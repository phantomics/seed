;;;; seed.lisp 

(in-package #:portal.model.moss)

(seed :portal.model.moss
      (:bind :package package :of-system of-system :to-grow grow)
      (:contacts)
      (:contactor . #'of-contacts)
      (:branches
       :view
       (lambda (context input)
         (case input (:one 1) (:two 2) (:three 3)))
       :systems
       (lambda (context input)
         (if input (let ((epsym (intern input "KEYWORD")))
                     (of-system :point (intern input "KEYWORD"))
                     ;; (instantiate-priority-macro-reader (asdf:load-system epsym))
                     ;; (load-seed-system epsym) ;; TEMPORARY - RESTORE
                     )
             (-<> (with-meta (of-system :contacts)
                    :type (:form))
               (encode <>))))))
