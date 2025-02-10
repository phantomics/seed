;;;; pla.browser.common.lisp

(in-package #:pla.browser.common)

(defmacro write-to-file (stream package path &body clauses)
  `(with-open-file (,stream (asdf:system-relative-pathname (intern (package-name ,package) "KEYWORD")
                                                           ,path)
			    :direction :output :if-exists :supersede :if-does-not-exist :create)
     ,@clauses))

(defun concat-files (out-stream package &rest in-paths)
  (loop :for path :in in-paths
        :do (with-open-file (input (asdf:system-relative-pathname
                                    (intern (string (package-name package)) "KEYWORD")
                                    path)
                                   :direction :input)
              (loop :for char := (read-char input nil :eof) :until (eq :eof char)
                    :do (write-char char out-stream))
              (princ #\Newline out-stream)))
    :complete)

(defun retrieve-flat-source (symbol package sources path)
  (if (listp symbol)
      (loop :for item :in symbol :collect (retrieve-flat-source item package sources path))
      (destructuring-bind (name address &optional file-path) (assoc symbol sources)
        (let ((complete-path (format nil "~a/~a" path (or file-path
                                                          (first (last (cl-ppcre:split "[/]" address)))))))
          (if (probe-file complete-path)
              complete-path
              (let ((bytes (dex:get address)))
                (with-open-file (out (asdf:system-relative-pathname
                                      (intern (package-name package) "KEYWORD")
                                      complete-path)
                                     :direction :output :if-exists :supersede :if-does-not-exist :create)
                  (write-sequence bytes out))
                complete-path))))))
