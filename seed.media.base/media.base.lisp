;;;; media.base.lisp

(in-package #:seed.generate)

(use-package 'seed.model.sheet)

(specify-media
 media-spec-base
 ;; read data from a file
 (get-file (source)
	   `(load-exp-from-file (sprout-name sprout)
				,(if (symbolp source)
				     `(concatenate 'string (string-downcase ,(if (eq :-self source)
										 `(branch-name branch)
										 `(quote ,source)))
						   ".lisp")
				     (if (stringp source)
					 source))))
 
 ;; read text from a file
 (get-file-text (source)
		`(load-string-from-file (sprout-name sprout)
					,(if (symbolp source)
					     `(concatenate 'string
							   (string-downcase ,(if (eq :-self source)
										 `(branch-name branch)
										 `(quote ,source)))
							   ".lisp")
					     (if (stringp source)
						 source))))

 ;; write data to a file
 (put-file (follows reagent file-name)
	   `((file-output (exp-string reagent "")
			  (asdf:system-relative-pathname 
			   (sprout-name sprout)
			   ;; (concatenate 'string (string-downcase ,(if (eq :-self file-name)
			   ;; 					      `(branch-name branch)
			   ;; 					      `(quote ,file-name)))
			   ;; 		".lisp")
			   ,(if (symbolp file-name)
				`(concatenate 'string
					      (string-downcase ,(if (eq :-self file-name)
								    `(branch-name branch)
								    `(quote ,file-name)))
					      ".lisp")
				(if (stringp file-name)
				    file-name))))))

 ;; get a branch image
 (get-image (&optional source)
	    `(branch-image branch))

 ;; record a branch image
 (put-image (follows reagent)
	    `((setf (branch-image branch) ,(if reagent 'reagent 'data))))

 ;; set the branch image to nil
 (nullify-image (follows)
		`((setf (branch-image branch) nil)))

 ;; get a referenced value from a system
 (get-value (follows source)
	    `((let ((val-sym (intern (string-upcase ,(if (eq :-self source)
							 `(branch-name branch)
							 `(quote ,source)))
				     (string-upcase (sprout-name sprout)))))
		(if (boundp val-sym) (eval val-sym)))))

 ;; get the list of systems in contact with a portal
 (get-portal-contacts (follows)
		      `((mapcar #'sprout-name (portal-contacts sprout))))

 ;; assign a value to the datum, overwriting whatever value existed previously
 (set-data (follows reagent)
	   (list reagent))

 ;; set a property of the branch's metadata
 (set-meta (follows reagent value)
	   `((set-branch-meta branch ,(intern (string-upcase reagent) "KEYWORD")
			      ,value)
	     data))

 ;; set the "type" parameter of a branch
 (set-type (follows &rest params)
	   `((set-param :type (quote ,params))
	     data))

 ;; set a branch's time parameter to the current time
 (set-time (follows)
	   `((set-param :time (get-universal-time))
	     data))

 ;; designate a branch as stable or not
 (set-stable (follows or-not)
	     `((set-branch-meta branch :stable ,(if (eq :not or-not) nil t))
	       data))

 ;; designate the set branch
 (set-active-system-by-selection (follows reagent)
				 `((let ((dat ,(if reagent 'reagent 'data))
					 (value nil))
				     (loop for item in (cadar dat)
					when (eq :select (getf (getf (cddr item) :if) :type))
					do (setq value (intern (string-upcase (second item))
							       "KEYWORD")))
				     (setf (getf (sprout-meta sprout) :active-system)
					   (symbol-jstring-process value)
					   (getf (branch-meta branch) :active-system)
					   (string-downcase value)))))

 ;; passthrough form used to specify stage display parameters
 (display-params (follows &rest params)
		 `(data))
 
 ;; fetch a branch parameter; functions as a check whether the parameter is nil or not
 (is-param (key true-or-not)
	   `(get-param ,key))

 ;; fetch a piece of branch metadata; functions as a check whether said element is nil or not
 (is-meta (key true-or-not)
	  `(of-branch-meta branch ,key))

 ;; check whether or not a branch is designated as stable
 (is-stable (true-or-not)
	    `(getf (branch-meta branch) :stable))

 ;; transfer current input or output to another branch, forking its path
 (fork-to (follows branch-to)
	  `((set-param :origin-branch (branch-name branch))
	    (funcall (branch-input (find-branch-by-name ,branch-to sprout))
		     data params (find-branch-by-name ,branch-to sprout)
		     sprout (lambda (dat par) (declare (ignorable dat par))))
	    data))
 
 ;; transfer current input to a different portal
 (to-portal (follows reagent)
	    `(()))

 ;; transmit data to a remote portal TODO: this is just a stub
 (remote (follows params)
	 (let ((par (cons 'list params)))
	   `((drakma:http-request (getf ,par :host)
				  :method :post :content-type "application/x-lisp; charset=utf-8"
				  :content
				  (write-to-string (list (intern (string-upcase (getf ,par :name)))
							 (intern "GROW")
							 (intern (string-upcase (getf ,par :branch)))
							 data))))))

 ;; route the input or output to one of two paths depending whether given conditions are true
 (if-condition (condition &rest options)
	       ;; return the paths, returning the 'dat symbol in the stead of an absent second path
	       (lambda (paths) (if (second paths)
				   ;; TODO: eliminate use of 'dat here
				   paths (list (first paths) 'dat))))

 ;; fetch a branch's image; functions as a check whether said image exists
 (is-image (true-or-not)
	   `(branch-image branch))

 ;; performs a series of actions in another branch
 (in-branch (follows branch-name &rest to-do)
	    `((let ((other-branch (find-branch-by-name ,branch-name sprout)))
		(if other-branch (funcall (lambda (input params branch)
					    (declare (ignorable input params branch))
					    ,@to-do)
					  data params other-branch)))))

 ;; sets list of contingencies that may be checked to control routing
 (contingencies (follows &rest names)
		`((set-branch-meta branch :contingencies (list ,@names))
		  data))

 ;; evaluates conditions in other branches with the specified contingencies
 ;; and chooses IO route according to truth/falsehood of the tests
 (is-contingent (contingencies media true-or-not)
		`(funcall (lambda (results)
			    ,(cond ((eq :all-of (first contingencies))
				    `(not (member nil results)))
				   (t `(member t results))))
			  (mapcar (lambda (branch-name)
				    ;(print (list :bbr branch-name true-or-not))
				    (let ((other-branch (find-branch-by-name branch-name sprout)))
				      ;; run media functions in each contingent branch
				      (funcall (lambda (input params branch)
						 (declare (ignorable input params branch))
						 ,media)
					       data params other-branch)))
				  ;; the current branch is not tested when testing contingent branches
				  (remove (branch-name branch)
					  (remove-duplicates
					   (loop for cname in (list ,@(rest contingencies))
					      append (loop for br in (sprout-branches sprout)
							when (not (not (member cname (getf (branch-meta br)
											   :contingencies))))
							collect (branch-name br))))))))

 ;; checks whether a datum is a form formatted for frontend display
 (is-display-format (true-or-not)
		    `(seed.modulate:display-format-predicate data))

 ;; assign system's name as package name in Lisp file to be output
 (code-package (follows)
	       `((cons (list 'in-package (make-symbol (string-upcase (sprout-name sprout)))) data))
	       `((rest data)))

 ;; contextualize a list of input
 (table-specs (follows reagent)
	      `((mapcar (lambda (item)
			  (if (string= "IN-TABLE" (string-upcase (first item)))
			      (append (list (first item) (second item)) data)
			      item))
			reagent))
	      `((funcall (lambda (in)
			   (labels ((process (i)
				      (if i (let ((point (first i)))
					      (if (string= "IN-TABLE" (string-upcase (first point)))
						  (cddr point)
						  (process (rest i)))))))
			     (process in)))
			 reagent)))

 ;; converts data between display (JSON) and internal (Lisp) formats
 (codec (follows)
	`((seed.modulate:decode data))
	`((multiple-value-bind (output meta-form)
	      (seed.modulate:encode (sprout-name sprout) data)
	    ;;(print (list :out output meta-form))
	    ;(set-branch-meta branch :depth (getf meta-form :depth))
	    ;(set-branch-meta branch :glyphs (gethash :glyphs meta-form))
	    (set-branch-meta branch :glyphs (getf meta-form :glyphs))
	    output)))

 ;; passthrough form meant to wrap stage parameters for use by stage definitions that analyze the branch spec
 (stage-params (follows &rest params)
	       `(data))

 ;; format data for use as a common form - in most cases, it actually does nothing since the data
 ;; is formatted like that to start with
 (form (follows)
       `((if (get-param :from-clipboard)
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
       `((if (get-param :from-clipboard)
	     (multiple-value-bind (output-form from-point)
		 (follow-path (get-param :point-to) 
			      (branch-image branch)
			      (lambda (point) point))
	       (declare (ignore output-form))
	       from-point)
	     data)))

 ;; convert between arrays of spreadsheet data for processing and lists of spreadsheet data for conversion to
 ;; frontend JSON display format
 (sheet (follows)
	`((if (get-param :from-clipboard)
	      (let* ((cb-input (get-param :clipboard-input))
		     (cb-data (getf cb-input :data)))
		(setf (apply #'aref (cons (branch-image branch) (reverse (get-param :point))))
		      (let ((type-settings (find-form-in-spec 'set-type (branch-spec (find-branch-by-name 
										      (getf cb-input :origin)
										      sprout)))))
			(cond ((and (eq :matrix (cadar type-settings))
				    (eq :spreadsheet (caddar type-settings)))
			       ;; spreadsheet values are simply passed through, of course...
			       (if (getf cb-data :data-inp)
				   (list :type (getf cb-data :type)
					 :data-inp (getf cb-data :data-inp))
				   (list :type (getf cb-data :type)
					 :data-inp (first (getf cb-data :data-com)))))
			      ((eq :form (cadar type-settings))
			       (list :type (cond ((stringp cb-data) :string)
						 ((numberp cb-data) :number)
						 ((listp cb-data) :list)
						 ((symbolp cb-data) :symbol)
						 (t :number))
				     :data-inp cb-data))
			      (t cb-data))))
		(branch-image branch))
	      (array-map #'seed.model.sheet:interpret-cell
			 (array-map #'postprocess-structure (list-to-array data 2)))))
	`((if (get-param :from-clipboard)
	      (apply #'aref (cons data (reverse (get-param :point))))
	      (array-to-list (array-map #'preprocess-structure data)))))

 ;; format/unformat the matrix content of a spreadsheet for processing
 (dyn-assign (follows reagent symbol)
	     `((funcall (lambda (content)
			  (let ((def-pos (position ,symbol content
						   :test (lambda (to-match item)
							   (and (eql 'defvar (first item))
								(eq to-match (intern (string (second item))
										     "KEYWORD")))))))
			    (setf (nth (1+ def-pos) content)
				  `(setq ,(second (nth def-pos content))
					 ,data))
			    content))
			reagent)))

 ;; records items from input to system's clipboard branch / fetches items from clipboard for output
 (clipboard (follows reagent)
	    `((let* ((vector (get-param :vector))
		     (cb-point-to (if (not (of-branch-meta branch :point-to))
				      (set-branch-meta branch :point-to 0)
				      (of-branch-meta branch :point-to)))
		     (branch-key (intern (string-upcase (get-param :branch))
					 "KEYWORD"))
		     (associated-branch (find-branch-by-name branch-key sprout))
		     (new-params params))
		(setf (getf new-params :from-clipboard) (branch-name branch))
		(if (= 0 (first vector))
		    ;; if the horizontal motion is zero, change the point according to the vertical motion
		    (progn (set-branch-meta branch :point-to
					    (min (max 0 (1- (length reagent)))
						 (max 0 (- cb-point-to (second vector)))))
			   reagent)
		    (if (< 0 (first vector))
			;; if the horizontal motion is positive, enter the other branch's form at point
			(funcall (branch-output associated-branch)
				 nil new-params associated-branch
				 sprout (lambda (data-output pr)
					  (declare (ignorable pr))
					  (cons (list :time (get-param :time)
						      :origin branch-key
						      :data data-output)
						reagent)))
			;; if the horizontal motion is negative, replace the other branch's form at point
			;; with the clipboard item at point
			(progn (setf (getf new-params :clipboard-input) (nth cb-point-to reagent)
                      	             ;; nullify vector so history recording works properly
				     (getf new-params :vector) nil)
			       (funcall (branch-input associated-branch)
					nil new-params associated-branch
					sprout (lambda (data-output pr)
						 (declare (ignore data-output pr))
						 reagent)))))))
	    `((let ((items (mapcar (lambda (item) (getf item :time))
				   data)))
		(if items (list items)))))

 ;; records input to system's history branch / fetches items from history branch for output
 (history (follows reagent)
	  `((if (not (get-param :from-history))
		;; don't do anything if the input came from a history movement - this prevents an infinite loop
		(if (get-param :vector)
		    (let* ((points (of-branch-meta branch :points))
			   (branch-key (intern (string-upcase (get-param :recall-branch))
					       "KEYWORD"))
			   (history-index (setf (getf points branch-key)
						(min (max 0 (1- (length (getf reagent branch-key))))
						     (max 0 (+ (first (get-param :vector))
							       (if (getf points branch-key)
								   (getf points branch-key)
								   0)))))))
		      (set-branch-meta branch :points points)
		      (set-param :from-history t)
		      (funcall (branch-input (find-branch-by-name branch-key sprout))
			       (getf (nth history-index (getf reagent branch-key)) :data)
			       params (find-branch-by-name branch-key sprout)
			       sprout (lambda (dt pr) (declare (ignorable dt pr))))
		      reagent)
		    (progn (setf (getf reagent (getf params :origin-branch))
				 (cons (list :time (get-param :time)
					     :data data)
				       (getf reagent (get-param :origin-branch))))
			   reagent))
		reagent))
	  `((let ((branch-index 0))
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
		(list (sort (process-each data)
			    (lambda (ifirst isecond) (> (second ifirst) (second isecond)))))))))
 )
