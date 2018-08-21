;;;; seed.app-model.site.base.lisp

(in-package #:seed.app-model.site.base)

(defvar simple-form-facility)
(setq simple-form-facility
      `(lambda ()
	 (chain (j-query ".service-terminal")
		(map (lambda (index data)
		       (let* ((element (j-query data))
			      (interaction-data (chain element (attr "interaction")
						       (split " "))))
			 (chain console (log 9091 element interaction-data
					     (chain element (find "button.submit"))))
			 (chain (chain element (find "button.submit"))
				(on "click" (lambda (event)
					      (chain event (prevent-default))
					      (chain console (log 515
								  (chain element (serialize-j-s-o-n)))))))))))))

(defvar form-support-effects)
(setq form-support-effects
      `(list ,simple-form-facility))

(defmacro standard-form-effects ()
  `(lambda (interface)
     (chain ,form-support-effects (map (lambda (effect) (funcall effect interface))))))
