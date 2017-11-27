;;;; model.sheet.lisp

(in-package #:seed.model.sheet)

(defun list-to-2d-array (list)
  (make-array (list (length list)
                    (length (first list)))
              :initial-contents list))

(defun array-map (function &rest arrays)
  "maps the function over the arrays.
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

(defun numeric-string-p (string)
  (handler-case (progn (parse-number:parse-number string) t)
    ;; parse succeeded, discard it and return true (t)
    (parse-number::invalid-number ()
      nil)
    ;; TODO: the above invalid-number condition should work instead of the condition below - why not?
    (condition () nil)))

(defun prepare-cell (cell-data)
  (if (or (null cell-data)
	  (eq :inp (cadar cell-data)))
      cell-data (prepare-cell (rest cell-data))))

(defun interpret-cell (cell)
  (if (and (getf cell :data-inp)
	   (eq :unknown (getf cell :type)))
      (if (numeric-string-p (getf cell :data-inp))
	  (setf (getf cell :data-inp)
		(parse-number (getf cell :data-inp))
		(getf cell :type)
		:number)
	  (setf (getf cell :type)
		:string)))
  (if (getf cell :data-inp-ovr)
      (progn (if (numeric-string-p (getf cell :data-inp-ovr))
		 (setf (getf cell :data-inp) 
		       (parse-number (getf cell :data-inp-ovr))
		       (getf cell :type)
		       :number)
		 (setf (getf cell :data-inp) 
		       (getf cell :data-inp-ovr)
		       (getf cell :type)
		       :string))
	     (remf cell :data-inp-ovr)))
  cell)

(defun preprocess-cell (cell)
  (let ((interpreted (interpret-cell cell)))
    (if (getf interpreted :data-com)
	(remf interpreted :data-com))
    interpreted))

(defun postprocess-cell (cell)
  (if (getf cell :data-com)
      (let ((com-value (first (getf cell :data-com))))
	(setf (getf cell :type)
	      (if (numberp com-value)
		  :number
		  (if (stringp com-value)
		      :string
		      (if (functionp com-value)
			  (progn (setf (getf cell :args-count)
				       (length (arglist com-value)))
				 :function)
			  (if (symbolp com-value)
			      :symbol)))))
	(setf (getf cell :data-com)
	      (mapcar (lambda (item)
			(cond ((functionp item) 
			       "function")
			      ((symbolp item)
			       (string-downcase item))
			      (t item)))
		      (getf cell :data-com)))))
  cell)

(defun translate-cell-coordinates (coord-string &optional original-length coords-out)
  (if (symbolp coord-string)
      (translate-cell-coordinates (string-upcase coord-string))
      (if (< 0 (length coord-string))
	  (let* ((original-length (if original-length original-length (length coord-string)))
		 (current-char (char-upcase (char coord-string 0))))
	    (labels ((char-to-colnum (char number)
		       (let ((char-index-offset 65)) ;; index of the character 'A'
			 (+ (* number 26)
			    (- (char-int (character (string-upcase char)))
			       char-index-offset))))
		     (find-next-char (str &optional index)
		       (let ((index (if index index 0)))
			 (if (or (= 0 (length str))
				 (not (numeric-string-p (subseq str 0 1))))
			     index (find-next-char (subseq str 1) 
						   (1+ index))))))
	      (translate-cell-coordinates (subseq coord-string (max 1 (find-next-char coord-string)))
					  original-length
					  (if (or (not coords-out) 
						  (not (numeric-string-p (subseq coord-string 0 1))))
					      (cons (char-to-colnum current-char
								    (if (not coords-out) 0
									(1+ (first coords-out))))
						    (rest coords-out))
					      (cons (1- (parse-number coord-string))
						    coords-out)))))
	  coords-out)))

(defun classify-operation (op)
  (if (and op (listp op))
      (if (symbolp (first op))
	  (let ((item (string-upcase (first op))))
	    (cond ((equal "VAL-NUMBER" item) :number)
		  ((equal "VAL-STRING" item) :string)
		  (t (classify-operation (rest op)))))
	  (if (listp (first op))
	      (let ((sub-list (classify-operation (first op))))
		(if sub-list sub-list (classify-operation (rest op))))
	      (classify-operation (rest op))))))

(defmacro in-table (table-id &body body)
  `(let ((working-table (array-map #'preprocess-cell ,table-id)))
     ,@body
     (setq ,table-id (array-map #'postprocess-cell working-table))))

(defmacro cell (coords-or-string &optional operation) 
  (let* ((coords (if (stringp coords-or-string)
		     (translate-cell-coordinates coords-or-string)
		     coords-or-string))
	 (cell-ref `(aref working-table ,(first coords) ,(second coords))))
    (labels ((get-cell-value-or (&optional default)
	       `(if (getf ,cell-ref :data-com) (first (getf ,cell-ref :data-com))
		    (if (getf ,cell-ref :data-inp) (getf ,cell-ref :data-inp) ,default))))
      (if (null operation)
	  (get-cell-value-or nil)
	  `(progn (setf (getf ,cell-ref :data-com)
			(cons (let (,@(cond ((eq :number (classify-operation operation))
					     `((,(intern "VAL-NUMBER" (package-name *package*))
						 ,(get-cell-value-or 0))))
					    ((eq :string (classify-operation operation))
					     `((,(intern "VAL-STRING" (package-name *package*))
						 ,(get-cell-value-or "")))))
				    (,(intern "CELL-TYPE" (package-name *package*))
				     (getf ,cell-ref :type)))
				(declare (ignorable ,(intern "CELL-TYPE" (package-name *package*))))
				(macrolet ((,(intern "TO-CELL" (package-name *package*))
					       (vector1 vector2)
					     `(cell (,(+ vector1 ,(first coords))
						      ,(+ vector2 ,(second coords)))))
					   (,(intern "CELL-UP" (package-name *package*))
					       (&optional distance)
					     `(,(quote ,(intern "TO-CELL" (package-name *package*)))
						,(if distance (- distance) -1) 0))
					   (,(intern "CELL-DOWN" (package-name *package*))
					       (&optional distance)
					     `(,(quote ,(intern "TO-CELL" (package-name *package*)))
						,(if distance distance 1) 0))
					   (,(intern "CELL-LEFT" (package-name *package*))
					       (&optional distance)
					     `(,(quote ,(intern "TO-CELL" (package-name *package*)))
						0 ,(if distance (- distance) -1)))
					   (,(intern "CELL-RIGHT" (package-name *package*))
					       (&optional distance)
					     `(,(quote ,(intern "TO-CELL" (package-name *package*)))
						0 ,(if distance distance 1))))
				  ,operation))
			      (getf ,cell-ref :data-com)))
		  ,cell-ref)))))

(defmacro cells (coords1 coords2 &optional operation)
  `(let* ((coords (list (list ,@(if (stringp coords1)
				    (translate-cell-coordinates coords1)
				    coords1))
			(list ,@(if (stringp coords2)
				    (translate-cell-coordinates coords2)
				    coords2))))
	 (start-col (cadar coords))
	 (start-row (caar coords))
	 (cols-dim (- (cadadr coords)
		      (cadar coords)))
	 (rows-dim (- (caadr coords)
		      (caar coords))))
     (labels ((proc-cells-row (table row col limit width output-table index)
		(progn (setf (aref output-table
				   (second limit)
				   (first limit))
			     (cell (row col)
				   ,@(if (null operation)
					 nil (list operation))))
		       (if (and (= rows-dim (first limit))
				(= cols-dim (second limit)))
			   output-table
			   (proc-cells-row table (if (= cols-dim (second limit))
						     (1+ row) row)
					   (if (= cols-dim (second limit))
					       start-col (1+ col))
					   (list (if (= cols-dim (second limit))
						     (1+ (first limit))
						     (first limit))
						 (if (= cols-dim (second limit))
						     0 (1+ (second limit))))
					   width output-table
					   (1+ index))))))
       (proc-cells-row working-table start-row start-col (list 0 0) rows-dim
		       (make-array (list (1+ cols-dim) (1+ rows-dim)) :initial-element nil)
		       0))))

(defmacro row (index &optional operation)
  `(let* ((dims (array-dimensions working-table))
	  (col-max (1- (second dims)))
	  (ix (1- ,index)))
     (cells (ix 0) (ix col-max)
	    ,@(if operation (list operation)))))

(defmacro col (index &optional operation)
  `(let* ((dims (array-dimensions working-table))
	  (row-max (1- (first dims)))
	  (ix ,(if (stringp index)
		   (first (translate-cell-coordinates index))
		   index)))
     (cells (0 ix) (row-max ix)
	    ,@(if operation (list operation)))))

;; (defun cell-scan (dims start-point end-point)
;;   (let ((row-dim (first dims))
;; 	(col-dim (second dims))
;; 	(row-start (first start-point))
;; 	(col-start (second start-point))
;; 	(row-end (first end-point))
;; 	(col-end (second end-point)))
;;     (labels ((add-entry (point acc)
;; 	       (let ((row (first point))
;; 		     (col (second point)))
;; 		 (add-entry (list (if (= 0
;; 					 col)
;; 				      (- 1 row)
;; 				      row)
;; 				  (if (= 0 
;; 					 col)
;; 				      (col-dim)
;; 				      (- 1 col)))
;; 			    (cons (if ()))))
