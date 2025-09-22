(defpackage #:seed.branch.abcd
  (:use #:cl)
  (:shadowing-import-from #:seed.generate #:seed #:branch
                          #:interface-format-form #:load-seed-system
                          #:syspath #:file-to-string
                          #:system-file-to-string #:adapt-from-alist #:adapt-from-json
                          #:from-system-file #:build-templater #:get-template-metadata
                          #:astr #:setf-value #:abind #:cbind #:text-wrap #:of-array-spec)
  (:shadowing-import-from #:seed.modulate #:dx #:render #:uim-web #:uim-web-stream
                          #:uic-anchor #:uic-frame #:uic-series #:uic-grid
                          #:uicc-button #:uicc-field #:uicc-select #:uich-candle #:spec-graph-interface
                          #:role-cast #:uir-call #:uir-call-c #:uir-call-b #:uir-call-form
                          #:uir-actuatable #:uir-sortable #:uir-reducable #:uir-toggle)
  (:shadowing-import-from #:pla.browser.maple #:*flat-sources* #:retrieve-flat-source
                          #:implement-start-controls #:write-to-file
                          #:build-static-page #:concat-files #:build-styles #:build-script-pdnd
                          #:build-script-cmirror #:build-script-pmirror #:build-script-misc)
  (:shadowing-import-from #:seed.access #:authorize))

(in-package :seed.branch.abcd)

(defparameter *system* :abcd)

(seed :seed.branch.abcd
  (:linking . :abcd)
  (:access :systems systems :staccess (state . of-state)
           :to-grow grow :to-branch branch3 :of-system of-system :to-join join))

(defun buttonize (item index)
  (declare (ignore index))
  (make-instance 'uicc-button :base item :type '(:local)))

(defun buttonize-calling (item index)
  (declare (ignore index))
  (make-instance 'uicc-button :base item :type '(:local) :call '(:.fetch (:action :.base))))

(branch :summary
  (lambda (state input)
    (declare (ignore state input))
    '((:create :create) (:nav :analyses) nil
      (:chart :chart-candle) (:chentity :entities-view))))

(branch :view
  (adapt-from-json :path :session)
  (lambda (state input)
    (destructuring-bind (&key session &allow-other-keys) input
      ;; (print (list :bp package (funcall context :branch-point)))
      (let ((context (first session))
            (summary (grow nil :summary))
            (branch-point (or (of-state :portal.demo1 :branch-point) 0))
            (start-point 0) (interval-found) (search-complete))
        
        (loop :for s :in summary :for sx :from 0 :until search-complete 
              :do (unless s (if interval-found (setf search-complete t)
                                (setf start-point (1+ sx))))
                  (when (= sx branch-point) (setf interval-found t)))

        (dx (uic-series :layout (:horizontal :even) :type (:workspace :even))
            (loop :for l :in (nthcdr start-point summary) :while l
                  :collect (dx (uic-series :layout (:vertical :of 3 1 1 1)
                                           :join   (list :abcd (first l))
                                           :type   (:column)
                                           :mode   (grow nil (first l)
                                                         context (list :identity (second l))))
                               (dx (uic-series :type (:ui :header))
                                   (second l)
                                   (grow nil (first l)
                                         context (list :uimod :header-controls)))
                               (dx (uic-frame :name (second l) :type (:body)
                                              :access :abcd)
                                   (first l))
                               (dx (uic-series :type (:ui :footer))
                                   (list (grow nil (first l)
                                               context (list :uimod :footer-controls)))))))))))

(defun manifest-file-listing (path &optional is-creating)
  (append (list (dx (uic-series :layout (:groups :rows '(2))
                                :type (:series :enum :table-interstitial :enum)
                                :call t)
                    (dx (uicc-field :name :system-name :type (:string)) "")
                    (dx (uicc-button :call (:@ :form-input))
                        "create")))
          (loop :for ix :from 0 :for dir :in (uiop:subdirectories path)
                :append (let ((props (from-system-file *system* (format nil "~a/chart.lisp" dir)
                                                       :properties)))
                          (destructuring-bind (&key name description) (rest props)
                            (and props (list (dx (uic-series :type (:series))
                                                 (list (dx (uicc-button :call (:.fetch (:point ix)
                                                                                       (:next :refresh)))
                                                           name)
                                                       description)))))))))

;; (defun manifest-template-interface (template-list template-point)
;;   (loop :for item :in template-list :for ix :from 0
;;         :append (destructuring-bind (tname &rest tpath) item
;;                   (multiple-value-bind (tname tdescription) (get-template-metadata tpath)
;;                     (cons (dx ((uic-series :type (:series)))
;;                               (list (dx ((uicc-button :call (:.fetch (:point ix) (:next :refresh))))
;;                                         (first item))
;;                                     tdescription))
;;                           (and template-point (= ix template-point)
;;                                (list (dx ((uic-series :layout (:groups :rows '(2))
;;                                                       :type (:series :enum :table-interstitial :enum)
;;                                                       :call t))
;;                                          (dx ((uicc-field :name :system-name :type (:string))) "")
;;                                          (dx ((uicc-button :call (:@ :form-input)))
;;                                              "create")))))))))

(defun point-from-template (form &optional index)
  (let ((x-start (second (nth 3 (second form))))
        (y-start (second (nth 4 (second form))))
        (x-end   (second (nth 5 (second form))))
        (y-end   (second (nth 6 (second form)))))
    (list :type "line" :points (list (list x-start y-start) (list x-end y-end))
          :name (format nil "obj-~a" (or index 0)) :points-in-flux nil :in-flux :true :ratios nil)))

(branch :create
  (adapt-from-json :point)
  (lambda (state input)
    (destructuring-bind (&key uimod &allow-other-keys) input
      (cond (uimod (values nil t))
            (t "This is a financial chart analysis tool.")))))

(defun init-chart-entities (state)
  (when (and state (of-state :- :chart-point))
    (unless (of-state :- :chart-entities)
      (let ((chart-path (namestring (nth (of-state :- :chart-point)
                                         (of-state :- :chart-paths)))))
        (of-state :- :chart-entities (from-system-file *system* (format nil "~a/chart.lisp" chart-path)
                                                       :chart-entities))))))

(branch :nav
  (adapt-from-json :point :action)
  (lambda (state input)
    (destructuring-bind (&key identity action uimod &allow-other-keys) input
      (cond (identity (values nil))
            ((eq uimod :header-controls)
             (dx (uic-series :type (:ui :controls) :map #'buttonize-calling)
                 (list :create)))
            (action (case (intern (string-upcase action) "KEYWORD")
                      (:create (print (list :aa action)))))
            (state (when (getf input :point)
                       (of-state :- :chart-point (getf input :point))
                       (of-state :- :chart-point nil))
                     (let ((template-point (of-state :- :template-point)))
                       (destructuring-bind (&key system-name &allow-other-keys) input
                         ;; (print (list :ccc input))
                         (render (of-state nil :medium)
                                 (dx (uic-series :type (:ui :list-table))
                                     (manifest-file-listing (asdf:system-relative-pathname
                                                             *system* "./analyses/")))))))))))

(branch :chart
  (adapt-from-json :entities :action :mode ;; next line: entities properties
                             :name :type :in-flux :points :points-in-flux :ratios)
  (lambda (state input)
    (unless (or (not state) (of-state :- :chart-paths)) ;; load list of analyses
      (of-state :- :chart-paths (uiop:subdirectories (asdf:system-relative-pathname *system* "./analyses/"))))

    (init-chart-entities state)

    (unless (or (not state) (of-state :- :chart-point))
      (of-state :- :chart-point 0))
    
    (destructuring-bind (&key identity uimod action entities mode &allow-other-keys) input

      (unless (or (not state) (of-state :- :entity-data)) ;; load existing entity data from file
        (of-state :- :entity-data (loop :for chent :in (cdddr (second (of-state :- :chart-entities)))
                                        :for ix :from 0 :collect (point-from-template chent ix))))

      ;; (print (list :ac action entities))
      
      (cond (identity :chart) ;; TODO: change ifmod-head stuff to reference a :controls super-property
            ((eq uimod :header-controls) (dx (uic-series :type (:ui :controls)
                                                         :map #'buttonize :role (toggle))
                                             (list :select :draw :retrace-x :retrace-y)))
            ((eq uimod :footer-controls) (dx (uic-series :type (:ui :controls) :map #'buttonize)
                                             (list :save :zoom-actual)))
            (entities
             (let ((collected))
               ;; (print (list :ent entities))
               (unless (of-state :- :line-templater)
                 (of-state :- :line-templater
                          (build-templater (from-system-file *system* "sheet.lisp"
                                                             :chart-entity-template-line)
                                           :type :format :x-start :y-start :x-end :y-end)))
               
               (when (listp (first entities))
                 (dolist (espec entities)
                   (destructuring-bind (&key name type in-flux points points-in-flux ratios) espec
                     ;; (print (list :es espec points))
                     (destructuring-bind (x-start y-start x-end y-end) (reduce #'append points)
                       ;; (print (list :in2 entities name type points))
                       (let ((index)
                             (item (list :points points :name name :type type :points-in-flux nil
                                         :in-flux :true :ratios ratios)))
                         (loop :for i :from 0 :for ent :in (of-state :- :entity-data)
                               :do (if (string= name (getf ent :name))
                                       (setf index i)
                                       (setf (getf ent :in-flux) :false)))
                         ;; (print (list :ent index (of-state :- :entity-data)))
                         (let ((edata (of-state :- :entity-data)))
                           (if index (setf (nth index edata) item)
                               (progn (push item edata)
                                      (push (funcall (of-state :- :line-templater)
                                                     :x-start x-start :x-end x-end ;; :format format
                                                     :y-start y-start :y-end y-end :type type)
                                            collected)))
                           (of-state :- :entity-data edata)))))))
               ;; (print (list :ce chart-entities))
               (let ((entities (of-state :- :chart-entities)))
                 (setf (second entities) (append (second (of-state :- :chart-entities))
                                                 (reverse collected)))
                 (of-state :- :chart-entities entities)
                 (of-state :- :entity-data))))
            (action
             (let ((chart-entities (of-state :- :chart-point (getf input :point)))
                   (chart-path (namestring (nth (of-state :- :chart-point)
                                                (of-state :- :chart-paths)))))
               
               ;; (print (list :st2 (nth (of-state :- :chart-point)
               ;;                       (of-state :- :chart-paths))))
               ;; (print (list :ce chart-entities (package-name *package*)))
               (case (intern (string-upcase (rest input)) "KEYWORD")
                 (:save (let ((output))
                          (setf output (format nil "(progn~%~{~a~%~})" chart-entities))
                          (setf (from-system-file *system* (format nil "~a/chart.lisp" chart-path)
                                                  :chart-entities :as-string t)
                                output))))))
            (t (case (intern (string-upcase mode) "KEYWORD")
                 (:chart-data
                  ;; (print (list :cc (of-state :- :chart-point)))
                  ;; (if (and state (funcall state :chart-point))
                  (let ((chart-path (namestring (nth (of-state :- :chart-point)
                                                     (of-state :- :chart-paths)))))
               
                    ;; (print (list :st3 (nth (of-state :- :chart-point)
                    ;;                        (of-state :- :chart-paths))))
                    ;; (system-file-to-string *system* data-path)
                    (file-to-string (second (third (second (from-system-file
                                                            *system* (format nil "~a/chart.lisp" chart-path)
                                                            :chart-entities)))))))
                 (t (render (funcall state nil :medium)
                            (dx (uich-candle :type (:green-red))
                                :abcd :chart)))))))))

(branch :chentity
  (adapt-from-json :path :sort :remove :action :mode)
  (lambda (state input)
    (destructuring-bind (&key path sort remove &allow-other-keys) input
      (or (and state (let ((entities (of-state :- :chart-entities)))
                       (symbol-macrolet ((elist (cdddr (second entities))))
                         (and path (cond (sort (destructuring-bind (index move-to) sort
                                                 (let ((moved (nth index elist)))
                                                   ;; (print (list :en index move-to elist :mm moved))
                                                   (if (zerop index) (pop elist)
                                                       (rplacd (nthcdr (1- index) elist)
                                                               (rest (nthcdr index elist))))
                                                   ;; (print (list :en2 index move-to elist :mov moved))
                                                   (if (zerop move-to) (setf elist (cons moved elist))
                                                       (rplacd (nthcdr (1- move-to) elist)
                                                               (cons moved (nthcdr move-to elist))))))
                                               (of-state :- :chart-entities entities)
                                               (print :complete))
                                         (remove (if (zerop remove) (pop elist)
                                                     (rplacd (nthcdr (1- remove) elist)
                                                             (rest (nthcdr remove elist))))
                                                 (of-state :- :chart-entities entities)
                                                 (values :complete t)))))))
          input)))
  (lambda (state input)
    (destructuring-bind (&key identity uimod action &allow-other-keys) input
      (cond (identity :meta-code-form)
            ((eq uimod :header-controls) (dx (uic-series :type (:ui :controls)
                                                         :map #'buttonize-calling)
                                             (list :save)))
            ((eq uimod :footer-controls) (dx (uic-series :type (:ui :controls)
                                                         :map #'buttonize-calling)
                                             (list :save)))
            ;; (ifmod-head (dx ((:each uicc-button :type (:local) :call (:.fetch (:action :.base)))
            ;;                  (uic-series :type (:ui :controls)))
            ;;                 (list :save)))
            ;; (ifmod-foot (dx ((:each uicc-button :type (:local) :call (:.fetch (:action :.base)))
            ;;                  (uic-series :type (:ui :controls)))
            ;;                 (list :save)))
            (action (let ((chart-path (namestring (nth (of-state :- :chart-point)
                                                       (of-state :- :chart-paths)))))
                      ;; (print (list :ce chart-entities))
                      (case (intern (string-upcase action) "KEYWORD")
                        (:save (let ((output))
                                 ;; (setf output (format nil "(progn~%~{~a~%~})" chart-entities))
                                 (setf output (and state (of-state :- :chart-entities))
                                       (from-system-file *system* (format nil "~a/chart.lisp" chart-path)
                                                         :chart-entities)
                                       (of-state :- :chart-entities))
                                 output)))))
            (t (init-chart-entities state)
               ;; (print (list :ccc state))
               (when state
                 ;; (print (list :con (funcall state :medium)))
                 ;; (print (list :nnn chart-entities))
                 (render (funcall state nil :medium)
                         (dx (uic-frame :type (:meta-code))
                             (seed.modulate::express (of-state :- :chart-entities))))))))))

