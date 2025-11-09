;;;; package.lisp

(defpackage #:seed.modulate
  (:use #:cl #:symbol-munger #:spinneret #:com.inuoe.jzon) ;; #:pla.browser.common)
  (:export #:meta-template #:encode #:render #:dx #:fx-assign
           ;; media
           #:uim-web
           ;; components
           #:uic-frame #:uic-anchor #:uic-series #:uic-grid #:uicc-button
           #:uicc-field #:uicc-text-line #:uich-candle #:spec-graph-interface
           ;; roles
           #:role-cast
           #:uir-call #:uir-call-c #:uir-call-b #:uir-call-form
           #:uir-form #:uir-contact #:uir-contact-refreshing
           #:uir-sortable #:uir-reducable #:uir-toggle

           #:xfurnish
           #:uir-pro-form #:uir-pro-chart)
  (:shadowing-import-from #:com.inuoe.jzon #:stringify)
  (:shadowing-import-from #:parenscript #:ps #:ps* #:ps-inline #:ps-inline* #:defpsmacro
                          #:create #:@ #:chain #:new #:getprop #:instanceof #:lisp #:regex)
  (:shadowing-import-from #:seed.generate #:json-convert-to))
