;;;; package.lisp

(defpackage #:portal.demo1
  (:use #:cl ;; #:seed ;; #:clarion ;; #:spinneret
        #:seed.admit
        #:cl-who
        #:arrow-macros 
        #:parenscript #:paren6 #:lass #:symbol-munger)
  ;; (:shadowing-import-from #:trivia #:match #:guard)
  ;; (:shadowing-import-from #:seed.admit #:auth-setup #:authorize)
  (:shadowing-import-from #:seed.contact.http #:http-contact-service-start)
  (:shadowing-import-from #:seed.generate #:json-convert-to #:json-convert-from #:portal-endpoint
                          ;; #:htrender
                          #:uic #:in-system-context #:render-html-interface
                          #:uispec #:encode #:render-web #:interface-format-form
                          #:load-seed-system #:render-nav-menu #:from-system-file
                          ;; #:spec-graph-interface
                          #:setf-value #:text-wrap #:of-array-spec
                          #:seed #:xform
                          ;; #:fx #:render #:uim-web #:uic-anchor #:uic-access
                          ;; #:uic-series #:uic-series-form #:uic-grid
                          ;; #:uicc-button #:uicc-text #:uicc-text-line #:uicc-text-area
                          )
  (:shadowing-import-from #:seed.modulate #:fx #:render #:uim-web #:uim-web-stream #:uic-anchor
                          #:uic-access #:uic-series #:uic-series-form #:uic-grid #:uicc-button
                          #:uicc-text #:uicc-text-line #:uicc-text-area #:spec-graph-interface)
  (:shadowing-import-from #:seed.admit #:authorize)
  ;; (:shadowing-import-from #:spinneret #:with-html #:with-html-string #:interpret-html-tree)
  )
