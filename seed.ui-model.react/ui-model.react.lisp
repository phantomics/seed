;;;; ui-model.react.lisp

(in-package #:seed.ui-model.react)

(defpsmacro handle-actions (action-obj state props &rest pairs)
  ;; Handle actions that propagate to a component according to the component's properties, 
  ;; such as whether it is currently the point or along the path of the point trace.
  (let ((conditions (list :actions-any-branch
			  ;; actions to be taken for all branches available
			  (lambda (action-list)
			    `(cond ,@(mapcar (lambda (action)
					       (let ((action-id (first action))
						     (action-content (rest action)))
						 `((= action ,(lisp->camel-case action-id))
						   ,@action-content
						   (if action-confirm (action-confirm)))))
					     action-list)))
			  :actions-branch-id
			  ;; actions to be taken when the branch's id matches one specified
			  (lambda (action-list)
			    `(cond ,@(mapcar (lambda (action)
					       (let ((action-id (first action))
						     (branch-id (second action))
						     (action-content (cddr action)))
						 `((and (= action ,(lisp->camel-case action-id))
							(= ,branch-id (@ self state data id)))
						   ,@action-content
						   (if action-confirm (action-confirm)))))
					     action-list)))
			  :actions-point
			  (lambda (action-list)
			    `(cond ,@(mapcar (lambda (action)
					       (let ((action-id (first action))
						     (action-content (rest action)))
						 `((and (= action ,(lisp->camel-case action-id))
							(or (@ state context is-point)
							    (and (@ props meta)
								 (@ props meta is-point))))
						   ,@action-content
						   (if action-confirm (action-confirm)))))
					     action-list)))
			  :actions-point-and-focus
			  (lambda (action-list)
			    `(cond ,@(mapcar (lambda (action)
					       (let ((action-id (first action))
						     (action-content (rest action)))
						 `((and (= action ,(lisp->camel-case action-id))
							;(@ state context in-focus)
							(or (@ state context is-point)
							    (and (@ props meta)
								 (@ props meta is-point))))
						   ;(chain console (log 33 (@ state context)))
						   (if (and (@ state point-attrs)
							    (@ state point-attrs props)
							    (@ state point-attrs props meta)
							    (@ state point-attrs props meta if)
							    (@ state point-attrs props meta if interaction)
							    (@ self interactions)
							    (getprop self "interactions"
								     (chain state point-attrs props meta if
									    interaction (substr 2)))
							    (getprop self "interactions"
								     (chain state point-attrs props meta if
									    interaction (substr 2))
								     ,(lisp->camel-case action-id)))
						       (funcall (getprop self "interactions"
									 (chain state point-attrs props meta if
										interaction (substr 2))
									 ,(lisp->camel-case action-id))
								self (@ state point-data))
						       (progn ,@action-content))
						   (if action-confirm (action-confirm)))))
					     action-list))))))
    `(if ,action-obj (let ((action (@ ,action-obj id))
			   (params (@ ,action-obj params))
			   (action-confirm (@ ,action-obj confirm))
			   (state ,state) (props ,props))
		       ,@(loop for item in pairs when (and (keywordp item) (getf conditions item))
			    collect (funcall (getf conditions item)
					     (getf pairs item)))))))

(defpsmacro extend-state (&rest items)
  "Extend the state of a component using an object or array."
  (let ((deep (eq :deep (first items))))
    (labels ((process-pairs (items &optional output)
	       (if items 
		   (process-pairs (cddr items)
				  (append output (list (first items)
						       `(chain j-query (extend ,@(if deep (list t))
									       (create)
									       (@ self state ,(first items))
									       ,(second items))))))
		   output)))
      `(chain self (set-state (create ,@(process-pairs (if deep (rest items)
							   items))))))))

;; (defmacro subcomponent (symbol data &optional &key (context nil) (addendum nil))
;;   ;; Create a subcomponent for use within a Seed interface.
;;   (declare (ignorable addendum))
;;   (labels ((assign-sub-context (pairs &optional output)
;; 	     (if pairs
;; 		 (assign-sub-context (cddr pairs)
;; 				     (append (list `(@ sub-con ,(first pairs)) (second pairs))
;; 					     output))
;; 		 output)))
;;     `(panic:jsl (,(if (symbolp symbol)
;; 		      (intern (string-upcase symbol) "KEYWORD")
;; 		      symbol)
;; 		  :data ,data
;; 		  :context (let ((sub-con (chain j-query (extend t (create) (@ self state context)))))
;; 			     (progn ,(cons 'setf (assign-sub-context context))
;; 				    sub-con))
;; 		  :action (if (not (= "undefined" (typeof (@ self act))))
;; 			      ;; the act property is only present at the top-level portal component
;; 			      (@ self state action)
;; 			      (@ self props action))))))

(defpsmacro subcomponent (symbol data &optional &key (context nil) (addendum nil))
  ;; Create a subcomponent for use within a Seed interface.
  (declare (ignorable addendum))
  (labels ((assign-sub-context (pairs &optional output)
	     (if pairs
		 (assign-sub-context (cddr pairs)
				     (append (list `(@ sub-con ,(first pairs)) (second pairs))
					     output))
		 output)))
    `(panic:jsl (,(if (symbolp symbol)
		      (intern (string-upcase symbol) "KEYWORD")
		      symbol)
		  :data ,data
		  :context (let ((sub-con (chain j-query (extend t (create) (@ self state context)))))
			     (progn ,(cons 'setf (assign-sub-context context))
				    sub-con))
		  :action (if (not (= "undefined" (typeof (@ self act))))
			      ;; the act property is only present at the top-level portal component
			      (@ self state action)
			      (@ self props action))))))

(defpsmacro vista (space context fill-by &optional respond-by encloser)
  ;; Create a vista, which contains components or sub-vistas within a Seed interface.
  `(panic:jsl (:-vista :key (+ "vista-" index)
		       :fill ,fill-by
		       :extend-response ,respond-by
		       :enclose ,(if encloser encloser `(lambda (item) item))
		       :data (@ self state data)
		       :space ,space
		       :context ,context
		       :action (if (not (= "undefined" (typeof (@ self act))))
				   ;; the act property is only present at the top-level portal component
				   (@ self state action)
				   (@ self props action)))))

(defmacro specify-components (name &rest params)
  "Define (part of) a component set specification to be used in building a React interface."
  `(defmacro ,name ()
     `(,@',params)))

(defmacro component-set (name &rest components)
  "Top-level wrapper for the component specification functions, which turns the list of component definitions into a form ready for conversion to Javascript. The order of the component definitions is reversed so that the components are produced in Javascript in the same order as they are listed."
  (labels ((process-subcomponents (items &optional output)
	     (if (not items)
		 output (process-subcomponents (cddr items)
					       (append (list (symbol-munger:lisp->camel-case (first items))
							     (if (symbolp (second items))
								 (macroexpand (list (second items)))
								 (second items)))
						       output)))))
    `(setq ,name (funcall (lambda ()
			    (let ((pairs (create))
				  (self this))
			      ,@(loop for item in components append
				     (if (listp item)
					 `((funcall (lambda ()
						      (let ((subcomponents (create ,@(process-subcomponents
										      (rest item)))))
							,@(mapcar (lambda (item)
								    `(defcomponent (@ pairs ,(first item))
									 ,@(rest item)))
								  (macroexpand (list (first item))))))))
					 (mapcar (lambda (item) `(defcomponent (@ pairs ,(first item))
								     ,@(rest item)))
						 (macroexpand (list item)))))
			      pairs))))))

(defmacro react-ui (components &key (url nil) (component nil))
  "Generate a React-based Seed user interface."
  (append (loop for comp in components append (macroexpand (if (listp comp)
							       comp (list comp))))
	  `((chain j-query
		   (ajax (create url ,(concatenate 'string "../" url)
				 type "POST"
				 data-type "json"
				 content-type "application/json; charset=utf-8"
				 data (chain -j-s-o-n (stringify (list (@ window portal-id) "grow")))
				 success (lambda (data)
					   ;; (chain console (log "DAT" data))
					   (chain -react-d-o-m
						  (render (panic:jsl (,component :data data))
							  (chain document (get-element-by-id "main")))))))))))
