;;;; package.lisp

(defpackage #:seed.modulate
  (:use #:cl #:symbol-munger #:spinneret #:com.inuoe.jzon) ;; #:pla.browser.common)
  (:export #:meta-template #:encode #:render #:express #:dx #:fx-assign
           ;; media
           #:uim-web
           ;; components
           #:uic-page #:uic-frame #:uic-anchor #:uic-series #:uic-grid #:uicc-button
           #:uicc-field #:uicc-text-line #:uich-candle #:spec-graph-interface
           ;; roles
           #:role-cast
           #:uir-call #:uir-call-r ;; #:uir-call-b
           #:uir-call-form
           #:uir-exec
           #:uir-form #:uir-patching #:uir-contact #:uir-contact-refreshing
           #:uir-sortable #:uir-reducable #:uir-toggle

           #:xfurnish
           #:uir-pro-form #:uir-pro-text #:uir-pro-sheet #:uir-pro-chart #:uir-pro-graph)
  (:shadowing-import-from #:com.inuoe.jzon #:stringify)
  (:shadowing-import-from #:parenscript #:ps #:ps* #:ps-inline #:ps-inline* #:defpsmacro
                          #:create #:@ #:chain #:new #:getprop #:instanceof #:lisp #:regex)
  (:shadowing-import-from #:seed.generate #:json-convert-to)
  ;; (:shadowing-import-from #:seed.modulate2 #:express-new)
  )
