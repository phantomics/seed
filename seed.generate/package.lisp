;;;; package.lisp

(defpackage #:seed.generate
  (:use #:cl #:arrow-macros #:clack #:woo #:ningle #:symbol-munger ;; #:jonathan
        #:com.inuoe.jzon #:trivial-package-local-nicknames #:cl-who
        #:parenscript #:paren6 #:seed.sublimate
        )
  (:export #:seed-instance #:system #:seed #:in-system-context #:interact #:with-meta
           #:portal-contacts #:portal-endpoint #:manifest-portal-contact-web #:of-system
           #:interface-spec #:meta #:uic #:uic-set #:encode #:load-seed-system #:form-span
           #:form-as-vectors #:interface-format-form #:render-html-interface #:render-nav-menu
           #:htrender #:render-console #:meta-revise #:psl
           #:from-system-file #:text-wrap #:setf-value #:of-array-spec #:of-graph-spec)
  (:shadowing-import-from #:parse-number #:parse-number)
  (:shadowing-import-from #:trivia #:match #:guard)
  (:shadowing-import-from #:spinneret #:with-html #:with-html-string #:interpret-html-tree))

(trivial-package-local-nicknames:add-package-local-nickname :jzon :com.inuoe.jzon)
