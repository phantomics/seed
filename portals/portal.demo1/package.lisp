;;;; package.lisp

(defpackage #:portal.demo1
  (:use #:cl #:seed.admit #:arrow-macros)
  (:shadowing-import-from #:seed.contact.http #:http-contact-service-start)
  (:shadowing-import-from #:seed.generate #:seed #:interface-format-form #:load-seed-system
                          #:from-system-file #:setf-value #:text-wrap #:of-array-spec)
  (:shadowing-import-from #:symbol-munger #:lisp->camel-case #:camel-case->keyword)
  (:shadowing-import-from #:seed.modulate #:fx #:render #:uim-web #:uim-web-stream #:uic-anchor
                          #:uic-access #:uic-series #:uic-series-form #:uic-grid #:uicc-button
                          #:uicc-text #:uicc-text-line #:uicc-text-area #:uich-candle
                          #:spec-graph-interface)
  (:shadowing-import-from #:seed.admit #:authorize)
  (:shadowing-import-from #:pla.browser.maple #:implement-start-controls #:write-to-file
                          #:build-static-page #:concat-files #:provide-browser-script
                          #:build-styles #:build-script-cmirror #:build-script-misc))
