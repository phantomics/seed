;;;; seed.lisp

(in-package #:portal.demo1)

(seed :portal.demo1
  (:access :to-grow grow :systems systems
           :ctaccess (*contacts* . make-contacts) :staccess (state . of-state)))

(defvar *contacts* (list :demo.sheet :abcd))

(defvar *seed-templates* (list (cons :template.chart (asdf:system-relative-pathname
                                                      :portal.demo1 "../../templates/template.charts/"))))

(defvar *portal* :portal.demo1)

(make-contacts)

(branch :view
  (adapt-from-json :key :point)
  (adapt-from-alist :system :branch :key :point)
  (lambda (state input)
    (destructuring-bind (&key key point &allow-other-keys) input
      ;; (print (list :po point))
      (when (and key (string= "demo" (string-downcase key)))
        (of-state nil :user :hello))

      (when (stringp point)
        (if (loop :for i :across point :always (digit-char-p i))
            (when (and state point)
              ;; when a point is selected, assign it
              (of-state (of-state nil :system-point) :view-point (read-from-string point)))

            (when (and state point)
              (if (string= "BASE" (string-upcase point))
                  (of-state nil :system-point nil)
                  ;; when a system is selected, assign it - case of new selector controls
                  (let ((epsym (intern (string-upcase point) "KEYWORD")))
                    (of-state nil :system-point epsym)
                    (instantiate-priority-macro-reader (asdf:load-system epsym)
                      (load-seed-system epsym)))))))

      (when (integerp point)
        (of-state (of-state nil :system-point) :view-point point))

      ;; (print (list :opo point))

      (let ((medium (make-instance 'uim-web :portal (intern (package-name *package*) "KEYWORD"))))

        (of-state nil :medium medium)

        ;; (print (list :cccc (package-name *package*)))
        (render medium (authorize (of-state nil :user)
                         (dx (uic-series :type '(:ui :grid-layout :linear :main :split :left-sidebar)
                                         :map (lambda (item index)
                                                (case index
                                                  (0 (push :sidebar (seed.modulate::uic-type item)))
                                                  (1 (push :main    (seed.modulate::uic-type item))))
                                                item))
                             (dx (uic-series :type '(:ui :column  :portal-summary))
                                 (dx (uic-series :type '(:ui :list))
                                     (list :portal.demo1
                                           (dx (uicc-select :options (cons :base *contacts*)
                                                            :call (:.fetch (:point :.base) (:next :refresh)))
                                               (of-state nil :system-point))))
                                 (and (of-state nil :system-point)
                                      (dx (uic-series :type  '(:ui :partitioned :navigation)
                                                      :point (of-state (of-state nil :system-point)
                                                                       :view-point)
                                                      :role  ((call-c :a (list :point :@index)
                                                                      :p (list :next :refresh))))
                                          (mapcar #'second (grow (of-state nil :system-point)
                                                                 :summary))))
                                 (dx (uic-series :type '(:ui :list))
                                     (list (dx (uicc-field :name "key" :role ((actuatable :label "⍐")))
                                               ""))))
                             (if (of-state nil :system-point)
                                 (grow (of-state nil :system-point) :view state)
                                 (grow nil :base state)))

                         (dx (uic-series :type (:ui :main :placard))
                             (list (dx (uic-series :type (:ui :column :short) :call t) ;; should this be :cast?
                                       (list "please input your key"
                                             (dx (uicc-field :name "key") "")
                                             (dx (uicc-button) "enter")))))))))))

(defun manifest-template-interface (template-list template-point)
  (loop :for item :in template-list :for ix :from 0
        :append (destructuring-bind (tname &rest tpath) item
                  (multiple-value-bind (tname tdescription) (get-template-metadata tpath)
                    (cons (dx (uic-series :type (:series))
                              (list (dx (uicc-button :call (:.fetch (:point ix) (:next :refresh)))
                                        (first item))
                                    tdescription))
                          (and template-point (= ix template-point)
                               (list (dx (uic-series :layout (:groups :rows '(2))
                                                     :type (:series :enum :table-interstitial :enum)
                                                     :call t)
                                         (dx (uicc-field :name :system-name :type (:string)) "")
                                         (dx (uicc-button :call (:@ :form-input))
                                             "create")))))))))

(branch :base
  (adapt-from-json :point :system-name)
  (lambda (state input)
    (when (getf input :point)
      (of-state :- :template-point (getf input :point)))
    ;; (print (list :iii input (of-state :template-point)))
    (let ((template-point (of-state :- :template-point)))
      (destructuring-bind (&key system-name &allow-other-keys) input
        (when system-name ;; a new system is being created from a template
          (print (list :tl template-point (package-name *package*)))
          (destructuring-bind (tname &rest tpath) (nth template-point *seed-templates*)
            ;; (print (list :create system-name))
            (make-project (asdf:system-relative-pathname
                           :portal.demo1 (format nil "../../systems/~a" (string-downcase system-name)))
                          :template-directory (asdf:system-relative-pathname
                                               :portal.demo1 (concatenate 'string "../" tpath))
                          :name (string-downcase system-name))))
        (dx (uic-series :layout (:horizontal :even) :type (:workspace :even))
            (list (dx (uic-series :layout (:vertical :of 3 1 1 1)
                                  :type   (:column))
                      (dx (uic-series :type (:ui :header))
                          :welcome
                          (list "welcome"))
                      "Welcome to the Seed demo portal."
                      (dx (uic-series :type (:ui :footer))))
                  (dx (uic-series :layout (:vertical :of 3 1 1 1)
                                  :type   (:column)
                                  :join   (list :portal.demo1 :base)
                                  ;; :mode   (grow :demo.sheet (first l)
                                  ;;               state (list :state (second l)))
                                  )
                      (dx (uic-series :type (:ui :header))
                          :templates
                          (list "aaa"))
                      (dx (uic-series :type (:ui :list-table)
                                      :call (:.fetch (:point :@base) (:next :refresh)))
                          (manifest-template-interface *seed-templates* (of-state :- :template-point)))
                      (dx (uic-series :type (:ui :footer))
                          ;; (list "bbb")
                          ))))))))

(branch :systems
  (adapt-from-alist :system :branch)
  (lambda (state input)
    (if input (let ((epsym (intern input "KEYWORD")))
                (of-state :-root- :system-point (intern input "KEYWORD"))
                (instantiate-priority-macro-reader (asdf:load-system epsym)
                  (load-seed-system epsym)))
        (-<> (with-meta *contacts*
               :type (:form))
          (encode <>)))))

;; (emote::write-palette-image (emote::linear-pal-transform (april:april-c "⌽[1]" *)
;;                              #(61 116 182)
;;                              10 ;; :ldeltas (april "24×2○○0.12×⍳4")
;;                              :lfactors (april "⎕←1+0.8×2○○0.08×⍳10"))
;;                             "/tmp/palOut.png")

;; (emote::write-palette-image (emote::linear-pal-transform
;;                              #(61 116 182)
;;                              8 ;; :ldeltas (april "24×2○○0.12×⍳4")
;;                              :lfactors (april "⎕←1+1.4×0.5×2○○0.1×1+⍳8"))
;;                             "/tmp/palOut.png")

;; (emote::write-palette-image (emote::linear-pal-transform
;;                              #(92 99 132)
;;                              8 ;; :ldeltas (april "24×2○○0.12×⍳4")
;;                              :lfactors (april "⎕←1+2×0.5×2○○0.1×0+⍳8"))
;;                             "/tmp/palOut.png" 100)

;; (emote::write-palette-image (emote::linear-pal-transform
;;                              #(#xc3 #xc7 #xd2)
;;                              10 :lfactors (april:april "⎕←1+3×0.26×1○○0.1×4+⍳10"))
;;                             "/tmp/palOut.png" 100)

;; (emote::write-palette-image (emote::linear-pal-transform
;;                              #(#x72 #x76 #x8a)
;;                              10 :lfactors (april:april "⎕←1+3×0.26×1○○0.1×4+⍳10"))
;;                             "/tmp/palOut.png" 100)

