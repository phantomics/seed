;;;; package.lisp

(defpackage #:seed.generate
  (:use #:cl #:arrow-macros ;; #:clack #:woo #:ningle
        #:symbol-munger ;; #:jonathan
        #:com.inuoe.jzon #:trivial-package-local-nicknames #:cl-who
        #:parenscript #:paren6 #:seed.sublimate
        )
  (:export ;; #:seed-instance
           #:system #:seed #:branch #:in-system-context #:interact #:with-meta
           #:portal-contacts #:portal-endpoint #:manifest-portal-contact-web #:of-system
           #:cbind #:interface-spec #:meta #:uic #:uic-set #:encode #:load-seed-system #:form-span
           #:form-as-vectors #:interface-format-form #:render-html-interface
           #:htrender ;; #:render-console
           #:meta-revise #:psl #:astr
           #:system-file-to-string #:from-system-file #:text-wrap #:setf-value #:of-array-spec
           #:spec-graph-interface #:of-graph-spec)
  (:shadowing-import-from #:parse-number #:parse-number)
  (:shadowing-import-from #:trivia #:match #:guard)
  (:shadowing-import-from #:com.inuoe.jzon #:stringify)
  (:shadowing-import-from #:spinneret #:with-html #:with-html-string #:interpret-html-tree))

(trivial-package-local-nicknames:add-package-local-nickname :jzon :com.inuoe.jzon)
