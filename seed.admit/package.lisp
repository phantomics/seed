;;;; package.lisp

(defpackage #:seed.admit
  (:use #:cl)
  (:shadowing-import-from #:hermetic #:setup #:login)
  (:shadowing-import-from #:uuid #:make-v4-uuid))
