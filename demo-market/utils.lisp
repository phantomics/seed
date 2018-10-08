;; utils.lisp

(in-package #:demo-market)

(defvar chart-data)

(defvar *forex-time-modulation* (list (list :offset 144000 :period 604800 :gap 176400)))

(defvar chart-entities)

(defun load-exp-from-file (package-name file-path)
  "Load a form from a file at the given relative path."
  (with-open-file (data (asdf:system-relative-pathname package-name file-path))
    (when data (loop for line = (read data nil)
		  while line collect line))))

(defun generate-data-string (data-array &optional array-length count output)
  (let ((array-length (if array-length array-length (length data-array)))
	(count (if count count 0))
	(output (if output output "")))
    (if (> count (1- array-length))
	output (let* ((datum (aref data-array count))
		      (time-string (if (/= 0 count)
				       (modulate-time (timestamp-to-unix
						       (universal-to-timestamp (parse-date-time (aref datum 0))))
						      *forex-time-modulation*)
				       (aref datum 0))))
		 (generate-data-string data-array array-length (1+ count)
				       (format nil "~a~a,~a,~a,~a,~a,~a,~a,~a,~a~%" output time-string
					       (aref datum 1)
					       (aref datum 4)
					       (aref datum 2)
					       (aref datum 3)
					       (aref datum 5)
					       (aref datum 8)
					       (aref datum 6)
					       (aref datum 7)))))))

;; (- 1535907600 1535731200)
;; 1535108400,1.51620,1.51670,1.51359,1.51385,1.51612,1.51662,1.51354,1.51375
;; 1535104800
;; (- 1535302800 1535126400)
;; offset 144000
;; week 604800

#|
1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17

1 1 1 0 0 0 1 1 1 1  1  0  0  0  1  1  1

1 2 3       4 5 6 7  8           9  10 11
|#

(defun modulate-time (time mods)
  (loop for mod in mods
     do (multiple-value-bind (dividend remainder)
	    (floor (- time (getf mod :offset))
		   (getf mod :period))
	  (setq time (- time (* (+ dividend (signum remainder))
				(getf mod :gap))))))
  time)

(defun demodulate-time (time mods)
  (loop for mod in (reverse mods)
     do (multiple-value-bind (dividend remainder)
	    (floor (- time (getf mod :offset))
		   (- (getf mod :period)
		      (getf mod :gap)))
	  (setq time (+ remainder (getf mod :offset)
			(* dividend (getf mod :period))
			(* (signum remainder)
			   (getf mod :gap))))))
  time)

(setq chart-entities (list (list :type "line"
				 :start (list 1087455600 1.52)
				 :end (list 1087650000 1.48))))

(setq chart-data (list :mods *forex-time-modulation*
		       :content (generate-data-string (first (load-exp-from-file :demo-market "./data.sexp")))
		       :entities chart-entities))

