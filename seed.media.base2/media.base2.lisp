;;;; seed.media.base2.lisp

(in-package #:seed.media.base2)

(define-symbol-macro bparams (getf seed.generate::params :meta))
;; (define-symbol-macro bparams1 seed.generate::params)

;; (seed.generate::branch-params seed.generate::branch)
(define-medium codec (data)
  (:input (print (list :dt2 bparams (branch-name branch)))
	  (seed.modulate:decode data))
  (:output (print (list :dt bparams (branch-name branch)))
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

;; (seed.media.base2::codec (first (portal-contacts portal.demo1::*portal*)) (fifth (sprout-branches (first (portal-contacts portal.demo1::*portal*)))) par2 (seed.media.base2::set-time nil nil par2 '((55))))

;; (defun q (i orig) (print (list :ii i)))
;; (defun g (h) (incf (getf h :b) 3))

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

;; set the branch image to nil
(define-medium nullify-image (input &optional branch-id)
  (setf (branch-image (if (not branch-id)
			  branch (find-branch-by-name branch-id sprout)))
	nil)
  input)

(define-medium set-type (&rest type-list)
  (setf (getf bparams :type) type-list)
  ;; (print (list :pr type-list bparams))
  )


(define-medium set-param (key value data)
  (setf (getf bparams key) value)
  data)

(define-medium is-param (key)
  (getf bparams key))

(define-medium is-image ()
  (print (list :eoeo (branch-name branch)
	       (not (null (branch-image branch)))))
  (not (null (branch-image branch))))

;; set a branch's time parameter to the current time
(define-medium set-time (data)
  (setf (getf bparams :time) (get-universal-time))
  (print (list :time-data bparams1))
  data)

;; designate a branch as stable or not
(define-medium set-stable (input &optional or-not)
  (set-branch-meta branch :stable (not (eq :not or-not)))
  input)

(define-medium get-value (source)
  (let ((val-sym (intern (string-upcase (if (eq :-self source)
					    (branch-name branch)
					    source))
			 (string-upcase (sprout-name sprout)))))
    (if (boundp val-sym) (eval val-sym))))

(define-medium set-data (data)
  (print (list :set-data bparams))
  data)

;; transfer current input or output to another branch, forking its path
(define-medium fork-to (input branch-to)
  (setf (getf bparams :origin-branch)
  	(branch-name branch))
  ;; (print (list :fork-to bparams branch-to (branch-input (find-branch-by-name branch-to sprout))))
  (funcall (branch-input (find-branch-by-name branch-to sprout))
	   input (append (list :direction :in) bparams)
	   (find-branch-by-name branch-to sprout)
	   sprout (lambda (dat par) (declare (ignorable dat par))))
  input)

(define-medium form (data)
  (:input (print (list :bb bparams))
	  (if (getf bparams :from-clipboard)
	      (multiple-value-bind (output-form form-point)
		  (follow-path (getf bparams :point-to)
			       (branch-image branch)
			       (lambda (point) 
				 (declare (ignore point))
				 (print (list :params-all seed.generate::params))
				 (let* ((cb-input (getf bparams :clipboard-input))
					(cb-data (getf cb-input :data))
					(type-settings (getf bparams :type)))
				   (cond ((and (eq :matrix (first type-settings))
					       (eq :spreadsheet (second type-settings)))
					  ;; handle pasting spreadsheet values into forms
					  (if (getf cb-data :data-com)
					      (first (getf cb-data :data-com))
					      (if (getf cb-data :data-inp) (getf cb-data :data-inp))))
					 (t cb-data)))))
		(declare (ignore form-point))
		(print (list :from-clipboard bparams output-form))
		output-form)
	      (progn (print (list :data-in data))
		     data)))
  (:output (print (list :bb2 bparams))
	   (if (getf bparams :from-clipboard)
	       (multiple-value-bind (output-form from-point)
		   (follow-path (getf bparams :point-to) 
				(branch-image branch)
				(lambda (point) point))
		 (declare (ignore output-form))
		 (print (list :from-clipboard2 bparams))
		 from-point)
	       data)))

;; assign system's name as package name in Lisp file to be output
(define-medium code-package (data)
  (:input (cons (list 'in-package (make-symbol (string-upcase (sprout-name sprout)))) data))
  (:output (rest data)))

(define-medium clipboard (&optional source input)
  (:input (let* ((vector (getf bparams :vector))
		 (cb-point-to (if (not (of-branch-meta branch :point-to))
				  (set-branch-meta branch :point-to 0)
				  (of-branch-meta branch :point-to)))
		 (branch-key (intern (string-upcase (getf bparams :branch))
				     "KEYWORD"))
		 (associated-branch (find-branch-by-name branch-key sprout))
		 (new-params seed.generate::params))
	    (print (list :cbparams bparams branch-key associated-branch))
	    (setf (getf (getf new-params :meta)
			:from-clipboard)
		  (branch-name branch))
	    (if (= 0 (first vector))
		;; if the horizontal motion is zero, change the point according to the vertical motion
		(progn (set-branch-meta branch :point-to (min (max 0 (1- (length source)))
							      (max 0 (- cb-point-to (second vector)))))
		       source)
		(if (< 0 (first vector))
		    ;; if the horizontal motion is positive, enter the other branch's form at point
		    (funcall (branch-output associated-branch)
			     nil new-params associated-branch
			     sprout (lambda (data-output pr)
				      (declare (ignorable pr))
				      (print (list :ddd new-params data-output))
				      (cons (list :time (getf bparams :time)
						  :origin branch-key :data data-output)
					    source)))
		    ;; if the horizontal motion is negative, replace the other branch's form at point
		    ;; with the clipboard item at point
		    (progn (setf (getf (getf new-params :meta)
				       :clipboard-input)
				 (nth cb-point-to source)
				 ;; nullify vector so history recording works properly
				 (getf new-params :vector) nil)
			   (print (list 6060 new-params associated-branch))
			   (funcall (branch-input associated-branch)
				    nil new-params associated-branch
				    sprout (lambda (data-output pr)
					     (declare (ignore data-output pr))
					     source)))))))
  (:output (let ((items (mapcar (lambda (item) (getf item :time))
	   			(branch-image branch))))
	     (print (list :sso (branch-name branch) (branch-image branch)))
	     (if items (list items)))))

;; records input to system's history branch / fetches items from history branch for output
(define-medium history (source &optional input)
  (:input (if (not (getf bparams :from-history))
	      ;; don't do anything if the input came from a history movement - this prevents an infinite loop
	      (if (and (getf bparams :vector)
		       (not (getf bparams :from-clipboard)))
		  (let* ((points (of-branch-meta branch :points))
			 (branch-key (intern (string-upcase (getf bparams :recall-branch))
					     "KEYWORD"))
			 (history-index (setf (getf points branch-key)
					      (min (max 0 (1- (length (getf source branch-key))))
						   (max 0 (+ (first (getf bparams :vector))
							     (if (getf points branch-key)
								 (getf points branch-key)
								 0)))))))
		    (set-branch-meta branch :points points)
		    ;; (set-param :from-history t)
		    (setf (getf bparams :from-history) t)
		    (print (list :history-1 bparams source input
				 branch-key history-index (getf source branch-key)
				 (nth history-index (getf source branch-key))))
		    (funcall (branch-input (find-branch-by-name branch-key sprout))
			     (getf (nth history-index (getf source branch-key)) :data)
			     bparams (find-branch-by-name branch-key sprout)
			     sprout (lambda (dt pr) (declare (ignorable dt pr))))
		    source)
		  (progn (setf (getf source (getf bparams :origin-branch))
			       (cons (list :time (getf bparams :time)
 					   :data input)
				     (getf source (getf bparams :origin-branch))))
			 source))
	      source))
  (:output (let ((branch-index 0))
	     (labels ((process-each (input &optional output)
			(if input
			    (let ((this-index branch-index))
			      (setq branch-index (1+ branch-index))
			      (process-each (cddr input)
					    (append (mapcar (lambda (item index)
							      (list 'meta (getf item :time)
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
