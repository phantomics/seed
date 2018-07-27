;;;; seed.app-model.feed.base.lisp

(in-package #:seed.app-model.feed.base)

(defmacro feed-manifest (&rest items)
  (let ((content (gensym)))
    `(let ((,content (make-hash-table :test #'eq)))
       (setf ,@(loop for item in items collect
		    `((gethash ,(getf item :id) ,content)
		      ,item)))
       (lambda (params)
	 (cond ((getf params :id)
		(gethash (getf params :id) ,content)))))))
#|
(feed-manifest
 (:id :aa :title "First Post" :date "01-01-2018"))

|#

;; (id (let ((str (make-string-output-stream)))
;; 	(uuid:format-as-urn str (uuid:make-v1-uuid))
;; 	(intern (string-upcase (third (split-sequence #\: (get-output-stream-string str))))
;; 		"KEYWORD")))
