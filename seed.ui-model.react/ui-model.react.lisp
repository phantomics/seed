;;;; ui-model.react.lisp

(in-package #:seed.ui-model.react)

(defmacro react-ui (components &key (url nil) (component nil))
  (append (apply #'append (mapcar (lambda (component)
				    (if (listp component)
					(macroexpand component)
					(macroexpand (list component))))
				  components))
	  `((chain j-query
		   (ajax (create url ,(concatenate 'string "../" url)
				 type "POST"
				 data-type "json"
				 content-type "application/json; charset=utf-8"
				 data (chain -j-s-o-n (stringify (list (@ window portal-id) "grow")))
				 success (lambda (data)
					   ;(chain console (log "DAT" data))
					   (chain -react-d-o-m
						  (render (panic:jsl (,component :data data))
							  (chain document (get-element-by-id "main")))))))))))
