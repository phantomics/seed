;;;; seed.media.base2.lisp

(in-package #:seed.media.base2)

;; (define-medium-input codec (input)
;;   (seed.modulate:decode input))

;; (:import-from :swank-backend #:arglist)

(define-medium codec (data)
  (:input (print (list :dt2 data))
	  (seed.modulate:decode data))
  (:output (print (list :dt data))
	  (multiple-value-bind (output meta-form)
	      (seed.modulate:encode (sprout-name sprout) data)
	    (set-branch-meta branch :glyphs (getf meta-form :glyphs))
	    output)))

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

(define-medium put-image (data reagent)
  (setf (branch-image branch) (if reagent reagent data)))

(define-medium set-type (type data)
  (setf (getf seed.generate::params :type) type)
  (print (list :pr type data seed.generate::params))
  data)


(define-medium set-param (key value data)
  (setf (getf seed.generate::params key) value)
  data)

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
