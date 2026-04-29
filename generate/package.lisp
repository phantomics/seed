;;;; package.lisp

(defpackage #:seed.generate
  (:use #:cl #:arrow-macros ;; #:clack #:woo #:ningle
        #:symbol-munger ;; #:jonathan
        #:com.inuoe.jzon #:trivial-package-local-nicknames #:cl-who
        #:parenscript #:paren6 #:seed.sublimate
        )
  (:export #:system #:seed #:branch #:in-system-context #:interact #:with-meta
           #:portal-contacts #:portal-endpoint #:manifest-portal-contact-web
           #:abind #:cbind #:interface-spec #:fx #:uic #:uic-set #:encode #:load-seed-system
           #:form-span #:form-as-vectors #:interface-format-form #:render-html-interface
           #:htrender
           #:psl #:astr
           #:adapt-from-alist #:adapt-from-json
           #:syspath #:file-to-string
           #:system-file-to-string #:from-system-file #:at-path
           #:build-templater #:get-template-metadata
           #:text-wrap #:setf-value #:of-array-spec
           #:spec-graph-interface #:of-graph-spec)
  (:shadowing-import-from #:symbol-munger #:lisp->camel-case #:camel-case->lisp-name)
  (:shadowing-import-from #:quickproject #:make-project)
  (:shadowing-import-from #:parse-number #:parse-number)
  (:import-from #:jonathan #:parse)
  (:shadowing-import-from #:trivia #:match #:guard)
  (:shadowing-import-from #:com.inuoe.jzon #:stringify)
  (:shadowing-import-from #:spinneret #:with-html #:with-html-string #:interpret-html-tree))

(trivial-package-local-nicknames:add-package-local-nickname :jzon :com.inuoe.jzon)
