;;;; package.lisp

(defpackage #:seed.modulate2
  (:use #:cl #:symbol-munger #:spinneret)
  (:export ;; core expression
           #:express-new
           #:generate
           #:render
           ;; manifestation classes
           #:manifestation
           #:mfn-atom
           #:mfn-sequence
           #:mfn-container
           ;; manifestation accessors
           #:mfn-value
           #:mfn-is
           #:mfn-as
           #:mfn-by
           #:mfn-name
           #:mfn-path
           #:mfn-members
           #:mfn-valence
           ;; IS vocabulary
           #:infer-data-character
           ;; AS vocabulary - program element roles
           #:+as-program-roles+
           ;; AS vocabulary - interface modality roles (for dx)
           #:+as-interface-roles+
           ;; BY vocabulary
           #:+by-modalities+)
  (:shadowing-import-from #:parenscript #:ps #:ps* #:ps-inline #:ps-inline*
                          #:create #:@ #:chain #:new #:getprop #:lisp)
  (:shadowing-import-from #:seed.modulate #:uim-web #:render))
