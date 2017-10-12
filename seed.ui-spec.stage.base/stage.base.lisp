;;;; seed.ui-spec.stage.base.lisp

(in-package #:seed.ui-spec.stage.base)

(defmacro simple-portal-layout (body &rest params)
  (declare (ignore body))
  `(((meta ((meta ,(intern (package-name *package*) "KEYWORD")
		 :if (:type :portal-name))
	   (meta ,params :if (:type :portal-system-list :index -1)
		 :each (:if (:interaction :select-system))))
	  :if (:type :vista :breadth :short :layout :column :name :portal-specs
		     :fill :fill-overview :enclose :enclose-overview)))
    (meta nil :if (:type :vista :fill :fill-main-stage :transparent t))))

(defmacro simple-branch-layout (branch-specs-symbol)
  (let ((specs (gensym)) (prospec-main (gensym)) (prospec-adj (gensym)) (name (gensym))
	(param-checks (gensym)) (stage-params (gensym)) (secondary-controls (gensym))
	(meta (intern "META" (package-name *package*))))
    `(labels ((,prospec-main (,specs &optional output)
		(let* ((,name (intern (string-upcase (caar ,specs)) "KEYWORD"))
		       (,param-checks (mapcar #'cadr (find-form-in-spec 'is-param (first ,specs))))
		       (,stage-params (cdar (find-form-in-spec 'stage-params (first ,specs))))
		       (insert-fibo-points 
			`(,',META
			  (SPIRAL-POINTS 100 100
					 (,',META
					  ((,',META ((:CIRCLE :R 3 :STROKE-WIDTH 2 
							      :STROKE "#E3DBDB" :FILL "#88AA00"))
						    :IF (:REMOVABLE T :TITLE "Small Green Circle" :TYPE :ITEM)))
					  :IF (:OPTIONS
					       ((:VALUE
						 (,',META ((:CIRCLE :R 3 :STROKE-WIDTH 2 
								 :STROKE "#E3DBDB" :FILL "#88AA00"))
						       :IF (:TYPE :ITEM :TITLE "Small Green Circle" :REMOVABLE T))
						 :TITLE "Small Green Circle")
						(:VALUE
						 (,',META ((:CIRCLE :R 5 :STROKE-WIDTH 2 
								 :STROKE "#E3DBDB" :FILL "#87AADE"))
						       :IF (:TYPE :ITEM :TITLE "Big Blue Circle" :REMOVABLE T))
						 :TITLE "Big Blue Circle"))
					       :REMOVABLE NIL :FILL-BY :SELECT :TYPE :LIST)))
			  :FORMAT SPIRAL-POINTS-EXPAND))
		       (,secondary-controls (append (if (find :save ,param-checks)
							(list `(,',meta :save :if (:interaction :commit))))
						    (if (find :revert ,param-checks)
							(list `(,',meta :revert :if (:interaction :revert)))))))
		  (if ,specs
		      (if (or (eq ,name :stage)
			      (eq ,name :clipboard)
			      (eq ,name :history))
			  (,prospec-main (rest ,specs)
					 output)
			  (,prospec-main 
			   (rest ,specs)
			   (cons `(,',meta (:body ,@(if ,secondary-controls (list :sub-controls)))
					   :if (:type :vista :ct 0 :fill :fill-branch :branch ,,name
						      :extend-response :respond-branches-main :axis :y
						      :secondary-controls (:format (,,secondary-controls))
						      :contextual-menu 
						      (:format
						       ,(list
							 (mapcar (lambda (item)
								   (cond ((eq :insert-fibo-points item)
									  `(,',meta :insert-fibo-points
										    :if (:interaction :insert)
										    :format ,insert-fibo-points))
									 ((eq :insert-circle item)
									  `(,',meta :insert-circle
										    :if (:interaction :insert)
										    :format (:circle :cx 100 
												     :cy 100
												     :r 25)))
									 ((eq :insert-rect item)
									  `(,',meta :insert-rectangle
										    :if (:interaction :insert)
										    :format (:rect :x 100
												   :y 100
												   :height 35
												   :width 35)))
									 ((eq :insert-add-op item)
									  `(,',meta :insert-add-op
										    :if (:interaction :insert)
										    :format (+ 1 2)))
									 ((eq :insert-mult-op item)
									  `(,',meta :insert-mult-op
										    :if (:interaction :insert)
										    :format (* 3 4)))))
								 (getf ,stage-params :contextual-menu))))
						      ;; (:format (((,',meta :item-one :if (:interaction :insert)
						      ;; 			  :format (+ 1 2))
						      ;; 		 :item-two :item-three)))
						      ))
				 output)))
		      output)))
	      (,prospec-adj (,specs &optional output)
		(let ((,name (intern (string-upcase (caar ,specs)) "KEYWORD")))
		  (if ,specs
		      (if (or (eq ,name :clipboard)
			      (eq ,name :history))
			  (,prospec-adj (rest ,specs)
					(cons ,name output))
			  (,prospec-adj (rest ,specs)
					output))
		      output))))
       `((,',meta ((,',meta ,(reverse (,prospec-main ,branch-specs-symbol))
			    :if (:type :vista :name :branches :enclose :enclose-branches-main))
		   (,',meta ,(reverse (,prospec-adj ,branch-specs-symbol))
			    :if (:type :vista :name :branches-adjunct :breadth :brief
				       :fill :fill-branches-adjunct :enclose :enclose-branches-adjunct)))
		  :if (:type :vista))))))
  
