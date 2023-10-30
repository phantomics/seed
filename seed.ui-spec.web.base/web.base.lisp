;;;; seed.ui-spec.web.base.lisp

(in-package #:seed.ui-spec.web.base)

(defpsmacro bla ()
    )

;; (panic:defcomponent -view
;;     (:get-initial-state
;;      (lambda () (chain this (initialize (@ this props))))
;;      :size 0
;;      :initialize
;;      (lambda (props)
;;        (let* ((self this)
;; 	      (data (funcall inherit self props
;; 			     (lambda (d) (@ d data))
;; 			     (lambda (pd) (@ pd data)))))
;; 	 (setf (@ data context view-scope)
;; 	       (if (@ props context view-scope)
;; 		   (cond ((= "full" (@ props context view-scope))
;; 			  (@ props context breadth))
;; 			 ((= "short" (@ props context view-scope))
;; 			  (if (= "brief" (@ props context breadth))
;; 			      "brief" "short"))
;; 			 ((= "brief" (@ props context view-scope))
;; 			  "brief"))
;; 		   (@ props context breadth))
;; 	       (@ data space) (@ props space))
;; 	 data))
;;      :component-will-receive-props
;;      (lambda (next-props)
;;        (let ((self this))
;; 	 (setf (@ self size) 0)
;; 	 (chain this (set-state (chain this (initialize next-props))))
;; 	 (chain this props (extend-response this next-props)))))
;;   (defvar self this)
;;   (if (or (not (@ this props data))
;; 	  (= 0 (@ this props data length)))
;;       (panic:jsl (:div))
;;       (progn (setf (@ self rendered) (chain self props (fill self (@ self state space))))
;; 	     (panic:jsl (:div :class-name (+ "vista " (@ self props context breadth))
;; 			      (chain self props (enclose self (@ self rendered))))))))
