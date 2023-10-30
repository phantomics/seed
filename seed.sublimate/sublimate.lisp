;;;; sublimate.lisp

(in-package #:seed.sublimate)

(defmacro meta (form &rest params)
  (declare (ignore params))
  "The macro used in evaluation of meta forms. It simply strips the meta information away, leaving the first member of the form to be evaluated."
  form)

(defmacro expand-meta (form &rest params)
  (declare (ignore params))
  form)

(let ((opening-parenthesis-handler (get-macro-character #\())
      (breaking-chars (concatenate 'string '(#\  #\Tab #\Newline #\Return)))
      (char-store (make-string 5 :initial-element #\ ))
      (index 0) (to-match "META "))
  (defun priority-macro-reader-extension (stream character)
    "Extend a character reader macro, typically for the left/opening parenthesis '(', to check for the presence of certain macro names so that those macros may be expanded in the read phase, before any other macros are expanded."
    (declare (type (unsigned-byte 8) index copy-to))
    (setf index 0)
    (let ((matching t))
      (loop :for m :across to-match :while matching :for char := (read-char stream nil)
            :do (if char (progn (setf (aref char-store index) char)
                                (unless (if (= 4 index)
                                            (position char breaking-chars :test #'char=)
                                            (char= m (char-upcase char)))
                                  (setf matching nil))
                                (incf index))
                    (setf matching nil)))
      (if matching (macroexpand-1 (read (make-concatenated-stream (make-string-input-stream
                                                                   "(SEED.SUBLIMATE::EXPAND-META ")
				                                  stream)
			                nil nil t))
          (funcall opening-parenthesis-handler
	           (make-concatenated-stream (make-string-input-stream char-store 0 index)
                                             stream)
	           character)))))

(defparameter *sublimating-readtable*
  (let ((this-readtable (copy-readtable *readtable* nil)))
    (set-macro-character #\( #'priority-macro-reader-extension nil this-readtable)
    this-readtable))

(defmacro instantiate-priority-macro-reader (&body body)
  `(let ((*readtable* *sublimating-readtable*)) ,@body))

;; (let ((opening-parenthesis-handler (get-macro-character #\()))
;;   (defun priority-macro-reader-extension (stream character)
;;     "Extend a character reader macro, typically for the left/opening parenthesis '(', to check for the presence of certain macro names so that those macros may be expanded in the read phase, before any other macros are expanded."
;;     (let ((open t)
;; 	  (string (make-array 5 :element-type 'character :initial-element #\ )))
;;       (loop :for index :from 0 :to 4 :while open :for char := (read-char stream nil) :while char
;;             :do (when (char= char #\)) (setq open nil))
;; 	        (setf (aref string index) char))
;;       (if (and (or (char= #\  (aref string 4))
;; 		   (char= #\Tab (aref string 4))
;; 		   (char= #\Newline (aref string 4))
;; 		   (char= #\Return (aref string 4)))
;; 	       (string= "META" (subseq string 0 4)))
;; 	  (macroexpand-1 (read (make-concatenated-stream (make-string-input-stream "(SEED.SUBLIMATE::EXPAND-META ")
;; 						         stream)
;; 			       nil nil t))
;; 	  (funcall *opening-parenthesis-handler*
;; 	           (make-concatenated-stream (make-string-input-stream string) stream)
;; 	           character)))))
