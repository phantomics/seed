;;;; package.lisp

(defpackage #:portal.demo1
  (:use #:cl #:seed.admit #:arrow-macros)
  (:shadowing-import-from #:seed.contact.http #:http-contact-service-start)
  (:shadowing-import-from #:seed.sublimate #:instantiate-priority-macro-reader)
  (:shadowing-import-from #:seed.generate #:seed #:interface-format-form #:load-seed-system
                          #:system-file-to-string #:from-system-file
                          #:astr #:setf-value #:cbind #:text-wrap #:of-array-spec)
  (:shadowing-import-from #:symbol-munger #:lisp->camel-case #:camel-case->keyword)
  (:shadowing-import-from #:seed.modulate #:fx #:fx-assign #:render #:uim-web #:uim-web-stream
                          #:uic-anchor #:uic-frame #:uic-series #:uic-series-form #:uic-grid
                          #:uicc-button #:uicc-field #:uich-candle #:spec-graph-interface)
  (:shadowing-import-from #:seed.admit #:authorize)
  (:shadowing-import-from #:pla.browser.maple #:*flat-sources* #:retrieve-flat-source
                          #:implement-start-controls #:write-to-file
                          #:build-static-page #:concat-files #:build-styles #:build-script-pdnd
                          #:build-script-cmirror #:build-script-pmirror #:build-script-misc))
