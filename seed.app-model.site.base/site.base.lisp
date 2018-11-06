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
			 ;; (chain console (log 9091 element interaction-data
			 ;; 		     data
			 ;; 		     (chain element (find "button.submit"))))
			 (chain (chain element (find "button.submit"))
				(on "click" (lambda (event)
					      (chain event (prevent-default))
					      (chain j-query
						     (ajax (create url "../portal"
								   type "POST"
								   data-type "json"
								   content-type "application/json; charset=utf-8"
								   data (chain -j-s-o-n
									       (stringify
										(chain interaction-data
										       (concat
											(chain
											 element
											 (serialize-j-s-o-n))))))
								   success (lambda (data)
									     (chain console (log :returned data))
									     ;; (callback stage-data data)
									     )
								   error (lambda (data err)
									   (chain console (log 11 data err)))
								   ))))))))))))

(defvar form-support-effects)
(setq form-support-effects
      `(list ,simple-form-facility))

(defmacro standard-form-effects ()
  `(lambda (interface)
     (chain ,form-support-effects (map (lambda (effect) (funcall effect interface))))))
