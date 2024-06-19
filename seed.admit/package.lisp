;;;; package.lisp

(defpackage #:seed.admit
  (:export #:read-keys #:authorize)
  (:use #:cl)
  (:shadowing-import-from #:hermetic #:setup #:login)
  (:shadowing-import-from #:uuid #:make-v4-uuid))
