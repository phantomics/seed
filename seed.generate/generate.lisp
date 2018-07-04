;;;; generate.lisp

(in-package #:seed.generate)

(defun list-dimensions (list depth)
  "Get the dimensions of a list."
  (loop repeat depth collect (length list)
     do (setf list (car list))))

(defun find-form-in-spec (head-name limbs &optional results)
  (if limbs (if (listp (first limbs))
		(if (string= (string-upcase head-name)
			     (string-upcase (caar limbs)))
		    (find-form-in-spec head-name (rest limbs)
				       (cons (first limbs) results))
		    (find-form-in-spec head-name (rest limbs)
				       (append (find-form-in-spec head-name (first limbs))
					       results)))
		(find-form-in-spec head-name (rest limbs)
				   results))
      results))

(defun follow-path (path form action)
  (if path (let ((remainder (nthcdr (first path) form)))
	     (multiple-value-bind (output-form point-output operated)
		 (follow-path (rest path)
			      (first remainder)
			      action)
	       (values (append (subseq form 0 (first path))
			       (cons (if operated point-output output-form)
				     (rest remainder)))
		       point-output)))
      (values form (funcall action form) t)))

(defun list-to-array (list depth)
  "Convert list to array."
  (make-array (list-dimensions list depth)
              :initial-contents list))

(defun array-to-list (array)
  "Convert array to list."
  (let* ((dimensions (array-dimensions array))
         (depth (1- (length dimensions)))
         (indices (make-list (1+ depth) :initial-element 0)))
    (labels ((recurse (n)
               (loop for j below (nth n dimensions)
		  do (setf (nth n indices) j)
		  collect (if (= n depth)
			      (apply #'aref array indices)
			      (recurse (1+ n))))))
      (recurse 0))))

(defun array-map (function &rest arrays)
  "Maps the function over the arrays.
   Assumes that all arrays are of the same dimensions.
   Returns a new result array of the same dimension."
  (flet ((make-displaced-array (array)
           (make-array (reduce #'* (array-dimensions array))
                       :displaced-to array)))
    (let* ((displaced-arrays (mapcar #'make-displaced-array arrays))
           (result-array (make-array (array-dimensions (first arrays))))
           (displaced-result-array (make-displaced-array result-array)))
      (declare (dynamic-extent displaced-arrays displaced-result-array))
      (apply #'map-into displaced-result-array function displaced-arrays)
      result-array)))

(defun exp-string (list output)
  "Convert the given form to a string."
  (if list (if (stringp list)
	       list (exp-string (rest list)
				(concatenate 'string output (write-to-string (first list))
					     (list #\newline))))
      output))

(defun file-output (data file-path)
  "Write given form to text and save to a file with the given path."
  (with-open-file (stream file-path :direction :output :if-exists :supersede :if-does-not-exist :create)
    (format stream (if (stringp data) data
		       (write-to-string data)))))

(defun load-exp-from-file (package-name file-path)
  "Load a form from a file at the given relative path."
  (with-open-file (data (asdf:system-relative-pathname package-name file-path))
    (when data (loop for line = (read data nil)
		  while line collect line))))

(defun load-string-from-file (package-name file-path)
  "Load a string from a file at the given relative path."
  (with-open-file (data (asdf:system-relative-pathname package-name file-path))
    (apply #'concatenate (cons 'string (when data (loop for line = (read-line data nil)
						     while line collect line))))))

;; The generic class for Seed systems. Wraps an ASDF system, implementing the branch-based input/output model.
(defclass sprout ()
  ((name :accessor sprout-name
	 :initarg :name)
   (meta :accessor sprout-meta
	 :initform nil
	 :initarg :meta)
   (system :accessor sprout-system
	   :initform (list :description "Generic sprout description.")
	   :initarg :system)
   (package :accessor sprout-package
	    :initform (list (list :export)
			    (list :use :common-lisp))
	    :initarg :package)
   (formats :accessor sprout-formats
	    :initform nil
	    :initarg :formats)
   (branches :accessor sprout-branches
	     :initform nil
	     :initarg :branches)))

;; A subclass for portals - sprouts that have contact with other sprouts. Portals are the basic building block
;; of Seed's system interface graph, with the minimum coherent Seed system consisting of a single portal
;; manifesting the user interface.
(defclass portal (sprout)
  ((contacts :accessor portal-contacts
	     :initform nil
	     :initarg :contacts)))

;; A class representing a conduit for data flowing to and from a system. Along with having methods for input and
;; output, branches often have a persistent state called an image that can be addressed by input and output.
(defclass branch ()
  ((name :accessor branch-name
	 :initarg :name)
   (image :accessor branch-image
	  :initform nil
	  :initarg :image)
   (meta :accessor branch-meta
	 :initform (list :stable t)
	 :initarg :meta)
   (spec :accessor branch-spec
	 :initform nil
	 :initarg :spec)
   (input :accessor branch-input
	  :initform nil
	  :initarg :in)
   (output :accessor branch-output
	   :initform nil
	   :initarg :out)))

(defgeneric find-branch-by-name (branch-name sprout))
(defmethod find-branch-by-name (branch-name (sprout sprout))
  "Return a branch with the specified name in the given sprout."
  (labels ((find-branch (b branches)
	     (if branches (if (eq b (branch-name (first branches)))
			      (first branches)
			      (find-branch b (rest branches))))))
    (find-branch branch-name (sprout-branches sprout))))

(defgeneric of-branch-meta (branch key))
(defmethod of-branch-meta ((branch branch) key)
  "Return a piece of branch metadata with the given key."
  (getf (branch-meta branch) key))

(defgeneric set-branch-meta (branch key &optional value))
(defmethod set-branch-meta ((branch branch) key &optional value)
  "Assign a value to an element of branch metadata."
  (setf (getf (branch-meta branch) key) value))

(defgeneric of-sprout-meta (sprout key))
(defmethod of-sprout-meta ((sprout sprout) key)
  "Return a piece of sprout metadata with the given key."
  (getf (sprout-meta sprout) key))

(defgeneric set-sprout-meta (sprout key &optional value))
(defmethod set-sprout-meta ((sprout sprout) key &optional value)
  "Assign a value to an element of sprout metadata."
  (setf (getf (sprout-meta sprout) key) value))

(defgeneric get-sprout-branch-specs (sprout))
(defmethod get-sprout-branch-specs ((sprout sprout))
  (mapcar #'branch-spec (sprout-branches sprout)))

(defgeneric describe-as-sprout (sprout))
(defmethod describe-as-sprout ((sprout sprout))
  "Generate a form describing a sprout."
  `(sprout ,(make-symbol (string-upcase (sprout-name sprout)))
	   :system ,(sprout-system sprout)
	   :package ,(sprout-package sprout)
	   :branches ,(mapcar #'branch-spec (sprout-branches sprout))))

(defgeneric describe-as-package (sprout))
(defmethod describe-as-package ((sprout sprout))
  "Generate a package definition for a sprout."
  (append (list 'defpackage (make-symbol (string-upcase (sprout-name sprout))))
	  (sprout-package sprout)))

(defgeneric describe-as-asdf-system (sprout))
(defmethod describe-as-asdf-system ((sprout sprout))
  "Generate an ASDF system definition for a sprout."
  (labels ((find-file-outputs (branch limbs &optional results)
	     (if limbs (if (listp (first limbs))
			   (if (string= "PUT-FILE" (string-upcase (caar limbs)))
			       (find-file-outputs branch (rest limbs)
						  (if (eq :-self (first (last (first limbs))))
						      (cons (string-downcase branch)
							    results)
						      (cons (string-downcase (first (last (first limbs))))
							    results)))
			       (find-file-outputs branch (rest limbs)
						  (append (find-file-outputs branch (first limbs))
							  results)))
			   (find-file-outputs branch (rest limbs)
					      results))
		 results))
	   (get-filenames-by-branch (branches &optional results)
	     (if branches
		 (get-filenames-by-branch (rest branches)
					  (append (mapcar (lambda (result) (list :file result))
							  (find-file-outputs (caar branches)
									     (cdar branches)))
						  results))
		 results)))
    `(asdf:defsystem ,(make-symbol (string-upcase (sprout-name sprout)))
       ,(append (sprout-system sprout)
		(list :components (get-filenames-by-branch (mapcar #'branch-spec (sprout-branches sprout))))))))

(defgeneric get-portal-contacts (portal))
(defmethod get-portal-contacts ((portal portal))
  "Return the list of systems contacted by a portal."
  (mapcar #'sprout-name (portal-contacts portal)))

(defgeneric find-portal-contact-by-sprout-name (portal sprout-name))
(defmethod find-portal-contact-by-sprout-name ((portal portal) sprout-name)
  "Return a contact from a given portal whose system has the given name."
  (labels ((try-contact (id contacts)
	     (if contacts (if (eq id (sprout-name (first contacts)))
			      (first contacts)
			      (try-contact id (rest contacts))))))
    (try-contact sprout-name (portal-contacts portal))))

(defgeneric get-portal-contact-branch-specs (portal contact-name))
(defmethod get-portal-contact-branch-specs ((portal portal) contact-name)
  "Return a contact from a given portal whose system has the given name."
  (print (list :eeg portal contact-name))
  (get-sprout-branch-specs (find-portal-contact-by-sprout-name portal contact-name)))

#| 
TODO: macros that don't exist in the media list act as do-nothing passthroughs regardless of their behavior.
example:

(defmacro aport (a) 1)

(sprout :portal.demo1
        :system (:description "This is a test portal.")
        :package ((:use :cl))
        :contacts (:demo-sheet :demo-drawing)
        :branches ((systems (in (put-image (aport (get-image)))
                                (put-file (get-image) :-self))
                            (out (set-type :form) (put-image (build-stage)) (codec)))))

inclusion of aport macro here just acts as passthrough
|#

(defmacro till (&rest media)
  "Manifest the possible convolutions of the input/output channels that branches may implement."
  (flet ((macro-media-builder (medium)
	   (let ((name (first medium)) (args (second medium))
		 (io-by-medium `(if (eq :in io) ,(third medium)
				    ,(if (fourth medium) (fourth medium) (third medium)))))
	     (macrolet ((prepend-args (&rest arg-list)
			  `(append (quote ,(cons 'io arg-list)) args)))
	       (cons name
		     ;; this conditional must cover a wide range of argument list taxonomies
		     (cond ((and (eq 'follows (first args))
				 (position 'reagent args))
			    `(,(prepend-args &optional)
			       (declare (ignorable follows reagent))
			       `(let ((dat (funcall (lambda (data ,@(if reagent (list 'reagent)))
						      (declare (ignorable data ,@(if reagent (list 'reagent))))
						      ,@,io-by-medium)
						    dat ,@(if reagent (list reagent)))))
				  (declare (ignorable dat))
				  ,(if follows follows 'dat))))
			   ;; reagent functions transform data; note that the 'reagent' argument is evaluated
			   ;; since it is passed to the funcall

			   ((and (eq 'follows (first args))
				 (eq 'source (second args)))
			    `(,(prepend-args &optional)
			       (declare (ignorable follows source))
			       `(let ((dat (funcall (lambda (data) (declare (ignorable data))
							    ,@,io-by-medium)
						    dat)))
				  (declare (ignorable dat))
				  ,(if follows follows 'dat))))
			   ;; source functions retrieve data from some source

			   ((eq 'follows (first args))
			    `(,(prepend-args &optional)
			       ; all arguments after follows are ignorable
			       (declare (ignorable ,@(append (list 'follows)
							     (remove '&rest (rest args)))))
			       `(let ((dat (funcall (lambda (data) (declare (ignorable data))
			   				    ,@,io-by-medium) dat)))
			   	  (declare (ignorable dat))
			   	  ,(if follows follows 'dat))))

			   ;; ((eq 'follows (first args))
			   ;;  `(,(prepend-args &optional)
			   ;;     (let ((dat (gensym)))
			   ;; 	 (declare (ignorable follows))
			   ;; 	 `(let ((,dat (funcall (lambda (data) (declare (ignorable data))
			   ;; 				       ,@,io-by-medium)
			   ;; 			       ,dat)))
			   ;; 	    (declare (ignorable ,dat))
			   ;; 	    ,(if follows follows dat)))))

			   ;; regular functions may do something to the data and are then followed by another
			   ((or (eq 'source (first args))
			   	; the source may be optional or not
			   	(and (eq '&optional (first args))
			   	     (eq 'source (second args))))
			    `(,(prepend-args unused)
			       (declare (ignorable unused source))
			       `(,@,io-by-medium)))
			   ;; terminal source functions retrieve data from some source, with nothing following

			   ((eq 'condition (first args))
			    `(,(prepend-args follows)
			       `(let ((dat (if ,condition ,@(funcall ,io-by-medium options))))
				  (declare (ignorable dat))
				  ,(if follows follows 'dat))))
			   ;; condition functions do something based on conditions

			   ((eq 'true-or-not (first (last args)))
			    `(,(prepend-args unused &optional)
			       (declare (ignorable unused true-or-not))
			       (funcall (if (eq :not true-or-not)
					    (lambda (body) (list 'not body))
					    (lambda (body) body))
					`(funcall (lambda (data) (declare (ignorable data))
							  (not (not ,,io-by-medium))) dat))))
			   ;; boolean functions return true or false based on some condition; if there is
			   ;; an argument such as hash key the true-or-not variable comes afterward

			   (t (list args (third medium)))))))))
  `(defmacro ,(intern "SPROUT" (package-name *package*))
       ;; declare this sprout macro internal to the package where the till macro is invoked
       (name &key (system nil) (meta nil) (package nil) (formats nil) (branches nil) (contacts nil))
     ;; generate list of nested macros from linear pipeline spec
     (labels ((medium-spec (direction params)
		;; perhaps medium-spec should be sublimated into a more general 
		;; template for the foundation of a branch spec
		`(lambda (input params branch sprout callback)
		   (declare (ignorable input params branch sprout))
		   ;; input to function is either the user's input, in input mode,
		   ;; or the branch image in output mode
		   (funcall callback (flet ((get-param (key) (getf params key))
					    (set-param (key value) (setf (getf params key) value)))
				       (let ((dat ,(if (eq :in (intern (string-upcase direction) "KEYWORD"))
						       'input `(branch-image branch))))
					 (declare (ignorable dat))
					 ,(media-gen direction params)))
			    params)))
	      (media-gen (direction params)
		(let* ((operation (first params))
		       (media-registry ,(list 'quote (mapcar (lambda (m) (intern (string-upcase (first m))
										 "KEYWORD"))
							     media)))
		       (is-operation-registered (member (intern (string-upcase (first operation)) "KEYWORD")
							media-registry))
		       ;; reverse the direction used for this medium if :reverse is the final param
		       (this-direction (if (eq :reverse (first (last operation)))
					   (if (eq :in direction) :out :in)
					   direction))
		       ;; if that final :reverse param is there, remove it now that its purpose is served
		       (operation (if (eq :reverse (first (last operation)))
				      (butlast operation) operation)))
		  (if operation
		      (append (if is-operation-registered
				  (list (intern (string-upcase (first operation)) "SEED.GENERATE")
					(intern (string-upcase this-direction) "KEYWORD"))
				  (list (first operation)))
			      (if is-operation-registered
				  (list (if (rest params) (media-gen direction (rest params)))))
			      (mapcar (lambda (item)
					(if (listp item)
					    (let ((is-registered-macro (member (intern (string-upcase (first item))
										       "KEYWORD")
									       media-registry)))
					      (if (loop for i in item when (listp i) collect i)
					          ;; the list is processed as a macro with media arguments
						  ;; if the head is registered as a macro, otherwise the head
						  ;; is discarded and the subsequent items are processed
						  (media-gen direction
							     (if (member (intern (string-upcase (first item))
										 "KEYWORD")
									 media-registry)
								 (list item)
								 (rest item)))
						  (if is-registered-macro
						      (media-gen direction (list item))
						      item)))
					    item))
				      (rest operation))))))
	      (build-branch (params &optional output)
		(if params
		    (let* ((item (first params))
			   (name (intern (string-upcase (first item)) "KEYWORD")))
		      (build-branch (rest params)
				    ;; TODO: the conditional may need to be expanded if other modes are implemented
				    (append output (cons name (list (cond ((or (eq :in name)
									       (eq :out name))
									   (medium-spec name (rest item)))))))))
		    output)))
       ;; the media macros are specified here - their arguments form the taxonomy for the code which wraps them
       `(macrolet ,(quote ,(mapcar #'macro-media-builder media))
          ;; create a sprout instance with the branches set up, including the input and output media
	  (germinate contacts
		     (make-instance (quote ,(if contacts 'portal 'sprout))
				    :name ,name :system (quote ,system) :meta (quote ,meta)
				    :package (quote ,package) :formats (quote ,formats)
				    ,@(if contacts
					  (list :contacts
						`(mapcar (lambda (contact)
							   ;; TODO: the below assumes a flat structure for the
							   ;; system file storage, improve the logic
							   (if (string= "SPROUT" (string-upcase (type-of contact)))
							       ;; if the item provided is an actual sprout object,
							       ;; simply pass it through, otherwise generate
					                       ;; the sprout as defined by its system's .seed file
							       contact
							       (if (handler-case (progn (asdf:find-system ,name) t)
								     (condition () nil))
							           ;; don't load the .seed file if the contact is
							           ;; not defined as an ASDF system
								   (let ((name-string (string-downcase contact)))
								     (eval (first (load-exp-from-file
										   ,name (format nil "../~a/~a.seed"
												 name-string 
												 name-string))))))))
							 (list ,@contacts))))
				    :branches (list ,@(mapcar (lambda (branch)
								`(make-instance 'branch
										:name ,(intern (string-upcase
												(first branch))
											       "KEYWORD")
										:spec (quote ,branch)
										,@(build-branch (rest branch))))
							      branches)))))))))

(defmacro media (&rest media)
  "Top-level wrapper for the nested media specification functions, which turns the list of media specs into arguments to the till macro. The order of the media specs is reversed so that the arguments to manifestMedia are intuitively ordered with the foundational spec first, modified by the specs coming after it."
  (cons 'till (loop for media-spec in (reverse media) 
		 append (macroexpand (list media-spec)))))

(defmacro specify-media (name &rest params)
  "Define (part of) a growth pattern specification to be used with the till macro."
  `(defmacro ,name ()
     `(,@',params)))

(defgeneric for-branches-that (sprout origin-branch predicate action &optional branches-left))
(defmethod for-branches-that ((sprout sprout) (origin-branch branch) predicate action &optional branches-left)
  "Perform an action on branches that match a given predicate."
  (let* ((branches-left (if branches-left branches-left (sprout-branches sprout)))
	 (this-branch (first branches-left)))
    (if branches-left
	(progn (if (funcall predicate origin-branch this-branch)
		   (funcall action origin-branch this-branch))
	       (if (rest branches-left)
		   (for-branches-that sprout predicate action (rest branches-left)))))))

(defmacro germinate (is-portal portal-def)
  "Create a new sprout, which may or may not be a portal, with a set of definition parameters."
  (let ((port (gensym)) (sprout (gensym)) (callback (gensym)) (branch (gensym)) (data (gensym)) (params (gensym))
	(portal-package-id (gensym)) (sprid (gensym)) (brname (gensym)) (list (gensym))
	(data-out (gensym)) (params-out (gensym)))
    (if is-portal
	`(let ((,port ,portal-def))
	   ;; assign portal object to *portal* and the grow method to the 'grow symbol
	   (setf (symbol-function (quote ,(intern "GROW" (package-name *package*))))
		 (lambda (,portal-package-id &optional ,sprid ,brname ,data ,params)
		   ;; if this (grow) function is called with only the portal package argument, meaning
		   ;; that most likely it is being invoked upon a Seed interface page load, clear the
		   ;; active system so that the user is presented with the introductory screen.
		   ;; This behavior works for the time being but it may eventually prove undesirable,
		   ;; so later provisions may be made for someone reloading a Seed interface to pick up
		   ;; immediately where they left off.
		   ;;(print (list :data ,portal-package-id ,sprid ,brname ,data ,params))
		   (if (not ,sprid)
		       (setf (getf (sprout-meta ,port) :active-system)
			     nil))
		   (let ((,sprout (if ,sprid (find-portal-contact-by-sprout-name ,port ,sprid) ,port))
			 (,params (postprocess-structure ,params)))
		     ;; if a sprout id and branch-name exist, input is being sent, so mediate
		     ;; through the branch's input function
		     ;;(print (list :exx ,sprout ,port ,sprid (find-branch-by-name ,brname ,sprout)))
		     (funcall (if ;; (and ,sprid ,brname)
			          ;; TODO: is changing sprid for sprout workable?
				  (and ,sprout ,brname)
				  (lambda (,callback)
				    (let ((,branch (find-branch-by-name ,brname ,sprout)))
				      ;; (print (list ,brname ,sprout ,branch))
				      ;; (print (list 909 ,portal-package-id ,sprid ,brname ,data ,params
				      ;; 		   (mapcar #'branch-name (sprout-branches ,sprout))))
				      (labels ((assign-meta-from-list (,list)
						 (if ,list (progn (setf (getf (branch-meta ,branch) (first ,list))
									(second ,list))
								  (assign-meta-from-list (cddr ,list))))))
					(assign-meta-from-list (getf ,params :meta)))
				      (funcall (branch-input ,branch)
					       ,data ,params ,branch ,sprout
					       (lambda (,data-out ,params-out)
						 (declare (ignorable ,data-out ,params-out))
						 (funcall ,callback)))))
				  (lambda (,callback) (funcall ,callback)))
			      (lambda ()
				(if ,params (labels ((assign-meta-from-list (,list)
						       (if ,list (progn (setf (getf (sprout-meta ,sprout) 
										    (first ,list))
									      (second ,list))
									(assign-meta-from-list (cddr ,list))))))
					      (assign-meta-from-list ,params)))
				;; invoke the special priority macro system
				;; meta tags will be evaluated before macro expansion
				;; the first step to doing this is to load the meta form
				;; (setf (getf (sprout-meta ,sprout) :active-system)
				;;       "demo-drawing")
				(if (instantiate-priority-macro-reader
				      (asdf:load-system (if ,sprid ,sprid ,portal-package-id)))
				      ;; load the system if it doesn't exist yet
				    (mapcar (lambda (,branch)
					      (setf (getf ,params :to-display) t)
					      ;; in any case, output is needed as well, so mediate appropriately
					      (funcall (branch-output ,branch)
						       ,data ,params ,branch ,sprout
						       (lambda (,data-out ,params-out)
					                 ;; format the id and type list for JSON conversion
        					         ;; with string-downcase
							 (list :|id| (string-downcase (branch-name ,branch))
							       :|type| (mapcar #'string-downcase
									       (getf ,params-out :type))
							       :|data| ,data-out
							       :|meta| (preprocess-structure
									(branch-meta ,branch))))))
					    (sprout-branches ,sprout))))))))
	   (setf (symbol-function (quote ,(intern "LOAD-SEED-SYSTEM" (package-name *package*))))
	   	 (lambda (symbol)
	   	   (instantiate-priority-macro-reader
	   	     (asdf:load-system symbol))))
	   (if (of-sprout-meta ,port :symbol)
	       (set (intern (string-upcase (of-sprout-meta ,port :symbol)))
		    ,port)
	       (setq ,(intern "*PORTAL*" (package-name *package*)) 
		     ,port)))
	portal-def)))

(defmacro portal ()
  "Instantiate a new portal."
  `(progn (defvar ,(intern "*PORTAL*" (package-name *package*)))
	  ;; declare *portal* variable
	  (load (asdf:system-relative-pathname
		 (intern (package-name *package*))
		 (concatenate 'string (string-downcase (package-name *package*)) ".seed")))))
