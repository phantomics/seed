;;;; seed.media.base2.lisp

(in-package #:seed.media.base2)

(define-medium codec (data)
  (:input ;;(print (list :dt2 data))
	  (seed.modulate:decode data))
  (:output ;;(print (list :dt data))
	  (multiple-value-bind (output meta-form)
	      (seed.modulate:encode (sprout-name sprout) data)
	    (set-branch-meta branch :glyphs (getf meta-form :glyphs))
	    output)))

;; TODO: should be loaded from seed.generate
;; (defun load-exp-from-file (package-name file-path)
;;   "Load a form from a file at the given relative path."
;;   (with-open-file (data (asdf:system-relative-pathname package-name file-path))
;;     (when data (loop for line = (read data nil)
;; 		  while line collect line))))

(define-medium get-file (source)
  (load-exp-from-file (sprout-name sprout)
		      (if (symbolp source)
			  (concatenate 'string (string-downcase (if (eq :-self source)
								    (branch-name branch)
								    source))
				       ".lisp")
			  (if (stringp source)
			      source))))

(define-medium get-file-text (source)
  (load-string-from-file (sprout-name sprout)
			 (if (symbolp source)
			     (concatenate 'string (string-downcase (if (eq :-self source)
								       (branch-name branch)
								       source))
					  ".lisp")
			      (if (stringp source)
				  source))))

(define-medium get-image (&optional source)
  (branch-image (if source (find-branch-by-name source sprout)
		    branch)))

(define-medium put-image (data)
  (setf (branch-image branch) data))

(define-medium set-type (&rest type-list)
  (setf (getf seed.generate::params :type) type-list)
  (print (list :pr type-list seed.generate::params)))


(define-medium set-param (key value data)
  (setf (getf seed.generate::params key) value)
  data)

(define-medium is-image ()
  (not (null (branch-image branch))))

(define-medium get-value (source)
  (let ((val-sym (intern (string-upcase (if (eq :-self source)
					    (branch-name branch)
					    source))
			 (string-upcase (sprout-name sprout)))))
    (if (boundp val-sym) (eval val-sym))))

;; transfer current input or output to another branch, forking its path
(define-medium fork-to (input branch-to)
  (setf (getf seed.generate::params :origin-branch)
	(branch-name branch))
  (funcall (branch-input (find-branch-by-name branch-to sprout))
	   input params (find-branch-by-name branch-to sprout)
	   sprout (lambda (dat par) (declare (ignorable dat par))))
  input)

(define-medium form (data)
  (:input (if (get-param :from-clipboard)
	      (multiple-value-bind (output-form form-point)
		  (follow-path (get-param :point-to)
			       (branch-image branch)
			       (lambda (point) 
				 (declare (ignore point))
				 (let* ((cb-input (get-param :clipboard-input))
					(cb-data (getf cb-input :data))
					(type-settings (find-form-in-spec 'set-type 
									  (branch-spec (find-branch-by-name
											(getf cb-input :origin)
											sprout)))))
				   (cond ((and (eq :matrix (cadar type-settings))
					       (eq :spreadsheet (caddar type-settings)))
					  ;; handle pasting spreadsheet values into forms
					  (if (getf cb-data :data-com)
					      (first (getf cb-data :data-com))
					      (if (getf cb-data :data-inp) (getf cb-data :data-inp))))
					 (t cb-data)))))
		(declare (ignore form-point))
		output-form)
	      data))
  (:output (if (get-param :from-clipboard)
	       (multiple-value-bind (output-form from-point)
		   (follow-path (get-param :point-to) 
				(branch-image branch)
				(lambda (point) point))
		 (declare (ignore output-form))
		 from-point)
	       data)))

;; assign system's name as package name in Lisp file to be output
(define-medium code-package (data)
  (:input (cons (list 'in-package (make-symbol (string-upcase (sprout-name sprout)))) data))
  (:output (rest data)))

(define-medium clipboard (source)
  (:input (let* ((vector (get-param :vector))
		 (cb-point-to (if (not (of-branch-meta branch :point-to))
				  (set-branch-meta branch :point-to 0)
				  (of-branch-meta branch :point-to)))
		 (branch-key (intern (string-upcase (get-param :branch))
				     "KEYWORD"))
		 (associated-branch (find-branch-by-name branch-key sprout))
		 (new-params seed.generate::params))
	    (setf (getf new-params :from-clipboard) (branch-name branch))
	    (if (= 0 (first vector))
		;; if the horizontal motion is zero, change the point according to the vertical motion
		(progn (set-branch-meta branch :point-to
					(min (max 0 (1- (length source)))
					     (max 0 (- cb-point-to (second vector)))))
		       source)
		(if (< 0 (first vector))
		    ;; if the horizontal motion is positive, enter the other branch's form at point
		    (funcall (branch-output associated-branch)
			     nil new-params associated-branch
			     sprout (lambda (data-output pr)
				      (declare (ignorable pr))
				      (cons (list :time (get-param :time)
						  :origin branch-key
						  :data data-output)
					    source)))
		    ;; if the horizontal motion is negative, replace the other branch's form at point
		    ;; with the clipboard item at point
		    (progn (setf (getf new-params :clipboard-input) (nth cb-point-to source)
				 ;; nullify vector so history recording works properly
				 (getf new-params :vector) nil)
			   (funcall (branch-input associated-branch)
				    nil new-params associated-branch
				    sprout (lambda (data-output pr)
					     (declare (ignore data-output pr))
					     source)))))))
  (:output (let ((items (mapcar (lambda (item) (getf item :time))
				source))) ;; was data
	     (if items (list items)))))

;; records input to system's history branch / fetches items from history branch for output
(define-medium history (source)
  (:input (if (not (get-param :from-history))
	      ;; don't do anything if the input came from a history movement - this prevents an infinite loop
	      (if (get-param :vector)
		  (let* ((points (of-branch-meta branch :points))
			 (branch-key (intern (string-upcase (get-param :recall-branch))
					     "KEYWORD"))
			 (history-index (setf (getf points branch-key)
					      (min (max 0 (1- (length (getf source branch-key))))
						   (max 0 (+ (first (get-param :vector))
							     (if (getf points branch-key)
								 (getf points branch-key)
								 0)))))))
		    (set-branch-meta branch :points points)
		    ;; (set-param :from-history t)
		    (setf (getf seed.generate::params :from-history) t)
		    (funcall (branch-input (find-branch-by-name branch-key sprout))
			     (getf (nth history-index (getf source branch-key)) :data)
			     seed.generate::params (find-branch-by-name branch-key sprout)
			     sprout (lambda (dt pr) (declare (ignorable dt pr))))
		    source)
		  (progn (setf (getf source (getf seed.generate::params :origin-branch))
			       (cons (list :time (get-param :time)
					   :data source) ;; was data
				     (getf source (get-param :origin-branch))))
			 source))
	      source))
  (:output (let ((branch-index 0))
	     (labels ((process-each (input &optional output)
			(if input
			    (let ((this-index branch-index))
			      (setq branch-index (1+ branch-index))
			      (process-each (cddr input)
					    (append (mapcar (lambda (item index)
							      (list 'meta
								    (getf item :time)
								    :branch-reference (first input)
								    :branch-index this-index
								    :point-offset
								    (let ((this-point
									   (getf (of-branch-meta branch :points)
										 (first input))))
								      (abs (- index 
									      (if this-point this-point 0))))))
							    (second input)
							    (loop for n from 0 to (1- (length (second input)))
							       collect n))
						    output)))
			    output)))
	       (list (sort (process-each source) ;; was data
			   (lambda (ifirst isecond) (> (second ifirst) (second isecond)))))))))

;; ;; records input to system's history branch / fetches items from history branch for output
;; (history (follows reagent)
;; 	  `((if (not (get-param :from-history))
;; 		;; don't do anything if the input came from a history movement - this prevents an infinite loop
;; 		(if (get-param :vector)
;; 		    (let* ((points (of-branch-meta branch :points))
;; 			   (branch-key (intern (string-upcase (get-param :recall-branch))
;; 					       "KEYWORD"))
;; 			   (history-index (setf (getf points branch-key)
;; 						(min (max 0 (1- (length (getf reagent branch-key))))
;; 						     (max 0 (+ (first (get-param :vector))
;; 							       (if (getf points branch-key)
;; 								   (getf points branch-key)
;; 								   0)))))))
;; 		      (set-branch-meta branch :points points)
;; 		      (set-param :from-history t)
;; 		      (funcall (branch-input (find-branch-by-name branch-key sprout))
;; 			       (getf (nth history-index (getf reagent branch-key)) :data)
;; 			       params (find-branch-by-name branch-key sprout)
;; 			       sprout (lambda (dt pr) (declare (ignorable dt pr))))
;; 		      reagent)
;; 		    (progn (setf (getf reagent (getf params :origin-branch))
;; 				 (cons (list :time (get-param :time)
;; 					     :data data)
;; 				       (getf reagent (get-param :origin-branch))))
;; 			   reagent))
;; 		reagent))
;; 	  `((let ((branch-index 0))
;; 	      (labels ((process-each (input &optional output)
;; 			 (if input
;; 			     (let ((this-index branch-index))
;; 			       (setq branch-index (1+ branch-index))
;; 			       (process-each (cddr input)
;; 					     (append (mapcar (lambda (item index)
;; 							       (list 'meta
;; 								     (getf item :time)
;; 								     :branch-reference (first input)
;; 								     :branch-index this-index
;; 								     :point-offset
;; 								     (let ((this-point
;; 									    (getf (of-branch-meta branch :points)
;; 										  (first input))))
;; 								       (abs (- index 
;; 									       (if this-point this-point 0))))))
;; 							     (second input)
;; 							     (loop for n from 0 to (1- (length (second input)))
;; 								collect n))
;; 						     output)))
;; 			     output)))
;; 		(list (sort (process-each data)
;; 			    (lambda (ifirst isecond) (> (second ifirst) (second isecond)))))))))

;; (clipboard (follows reagent)
;; 	    `((let* ((vector (get-param :vector))
;; 		     (cb-point-to (if (not (of-branch-meta branch :point-to))
;; 				      (set-branch-meta branch :point-to 0)
;; 				      (of-branch-meta branch :point-to)))
;; 		     (branch-key (intern (string-upcase (get-param :branch))
;; 					 "KEYWORD"))
;; 		     (associated-branch (find-branch-by-name branch-key sprout))
;; 		     (new-params params))
;; 		(setf (getf new-params :from-clipboard) (branch-name branch))
;; 		(if (= 0 (first vector))
;; 		    ;; if the horizontal motion is zero, change the point according to the vertical motion
;; 		    (progn (set-branch-meta branch :point-to
;; 					    (min (max 0 (1- (length reagent)))
;; 						 (max 0 (- cb-point-to (second vector)))))
;; 			   reagent)
;; 		    (if (< 0 (first vector))
;; 			;; if the horizontal motion is positive, enter the other branch's form at point
;; 			(funcall (branch-output associated-branch)
;; 				 nil new-params associated-branch
;; 				 sprout (lambda (data-output pr)
;; 					  (declare (ignorable pr))
;; 					  (cons (list :time (get-param :time)
;; 						      :origin branch-key
;; 						      :data data-output)
;; 						reagent)))
;; 			;; if the horizontal motion is negative, replace the other branch's form at point
;; 			;; with the clipboard item at point
;; 			(progn (setf (getf new-params :clipboard-input) (nth cb-point-to reagent)
;;                      	             ;; nullify vector so history recording works properly
;; 				     (getf new-params :vector) nil)
;; 			       (funcall (branch-input associated-branch)
;; 					nil new-params associated-branch
;; 					sprout (lambda (data-output pr)
;; 						 (declare (ignore data-output pr))
;; 						 reagent)))))))
;; 	    `((let ((items (mapcar (lambda (item) (getf item :time))
;; 				   data)))
;; 		(if items (list items)))))

 ;; (get-value (follows source)
 ;; 	    `((let ((val-sym (intern (string-upcase ,(if (eq :-self source)
 ;; 							 `(branch-name branch)
 ;; 							 `(quote ,source)))
 ;; 				     (string-upcase (sprout-name sprout)))))
 ;; 		(if (boundp val-sym) (eval val-sym)))))

;; (set-media
;;  media-template-standard
;;  (with :branch-symbol branch :sprout-symbol sprout :params-symbol params)
;;  (codec (input)
;;   ((value :element array :times :any))
;;   (let ((value (output-value workspace value properties)))
;;     value)
;;   (codec (follows)
;; 	 `((seed.modulate:decode data))
;; 	 `((multiple-value-bind (output meta-form)
;; 	       (seed.modulate:encode (sprout-name sprout) data)
;; 	     ;;(print (list :out output meta-form))
;; 					;(set-branch-meta branch :depth (getf meta-form :depth))
;; 					;(set-branch-meta branch :glyphs (gethash :glyphs meta-form))
;; 	     (set-branch-meta branch :glyphs (getf meta-form :glyphs))
;; 	     output)))))

;; (input params branch sprout callback)

;; (defgeneric codec (input params branch sprout key &optional value))
;; (defmethod set-branch-meta ((branch branch) key &optional value)
;;   "Assign a value to an element of branch metadata."
;;   (setf (getf (branch-meta branch) key) value))

;; (defgeneric of-sprout-meta (sprout key))
;; (defmethod of-sprout-meta ((sprout sprout) key)
;;   "Return a piece of sprout metadata with the given key."
;;   (getf (sprout-meta sprout) key))
