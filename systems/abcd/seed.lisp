(defpackage #:seed.branch.abcd
  (:use #:cl)
  (:shadowing-import-from #:seed.generate #:seed #:fx #:branch
                          #:interface-format-form #:load-seed-system
                          #:syspath #:file-to-string
                          #:system-file-to-string #:adapt-from-alist #:adapt-from-json
                          #:from-system-file #:at-path #:at-fx-path #:build-templater #:get-template-metadata
                          #:astr #:setf-value #:abind #:cbind #:text-wrap #:of-array-spec)
  (:shadowing-import-from #:seed.modulate #:dx #:render #:uim-web #:uim-web-stream
                          #:uic-anchor #:uic-page #:uic-frame #:uic-series #:uic-grid
                          #:uicc-button #:uicc-field #:uicc-select #:uich-candle #:spec-graph-interface
                          #:role-cast
                          #:uir-call #:uir-call-refreshing ;; #:uir-call-b
                          #:uir-form #:uir-call-form
                          #:uir-exec
                          #:uir-patching #:uir-form ;; #:uir-contact
                          #:uir-contact-refreshing
                          #:uir-actuatable #:uir-sortable #:uir-reducable #:uir-toggle

                          #:aspect #:amake #:uia-name #:uia-based-pane-series #:uia-primal-dual-bank-pane

                          #:xfurnish
                          #:uir-pro-form #:uir-pro-chart)
  (:shadowing-import-from #:pla.browser.maple #:*flat-sources* #:retrieve-flat-source
                          #:implement-start-controls #:write-to-file
                          #:build-static-page #:concat-files #:build-styles #:build-script-pdnd
                          #:build-script-cmirror #:build-script-pmirror #:build-script-misc)
  (:shadowing-import-from #:seed.sublimate #:instantiate-priority-macro-reader)
  (:shadowing-import-from #:app.chart #:list-entities #:eset #:essource #:span)
  (:shadowing-import-from #:seed.access #:authorize)
  (:shadowing-import-from #:cl-csv #:read-csv))

(in-package :seed.branch.abcd)

(defparameter *system* :abcd)

(seed :seed.branch.abcd
  (:linking . :abcd)
  (:access :systems systems :to-grow grow :staccess (state of-state state-accessor)))

(defun buttonize (item index)
  (declare (ignore index))
  (make-instance 'uicc-button :base item :type '(:local)))

;; (defun buttonize-calling (item index)
;;   (declare (ignore index))
;;   (make-instance 'uicc-button :base item :type '(:local)
;;                               :role (list (make-instance 'uir-contact :base-key :action))))

(defun buttonize-calling (item index)
  (declare (ignore index))
  (make-instance 'uicc-button :base item :type '(:local)
                              :role (list (make-instance 'uir-call-refreshing :n :action))))

(branch :summary
  (lambda (state input)
    (declare (ignore state input))
    (symbol-macrolet ((header-controls (grow *system* name nil (list :uimod :header-controls)))
                      (footer-controls (grow *system* name nil (list :uimod :footer-controls))))
      (list (aspect pane-series (:name :start :role (patching))
              ;; (let ((name :create)   (title :welcome))
              (dx (uic-page :type (:column))
                  '(:div :class "column-inner" (:h2 "Welcome")
                    (:p "This is a financial analysis chart tool.")))
              ;; (aspect dual-bank-pane :name name :title title
              ;;   :system *system* :controls (list header-controls footer-controls))
              ;; )
              (let ((name :nav)      (title :browse))
                (aspect dual-bank-pane :name name :title title :role (pro-form)
                  :system *system* :controls (list header-controls footer-controls))))
            (aspect pane-series (:name :chart :role (patching))
              (let ((name :chart)    (title :chart-candle))
                (aspect dual-bank-pane :name name :title title :role (pro-chart)
                  :system *system* :controls (list header-controls footer-controls)))
              (let ((name :chentity) (title :entities-view))
                (aspect dual-bank-pane :name name :title title :role (pro-form)
                  :system *system* :controls (list header-controls footer-controls))))))))

(branch :view
  (adapt-from-json :path :session)
  (lambda (state input)
    (destructuring-bind (&key session &allow-other-keys) input
      (let ((summary (grow *system* :summary))
            (branch-point (or (of-state :- :view-point) 0)))
        (amake (nth branch-point summary))))))

(defun point-from-template (form &optional index)
  (let ((x-start (second (nth 3 (second form))))
        (y-start (second (nth 4 (second form))))
        (x-end   (second (nth 5 (second form))))
        (y-end   (second (nth 6 (second form)))))
    (list :type "line" :points (list (list x-start y-start) (list x-end y-end))
          :name (format nil "obj-~a" (or index 0))
          :points-in-flux nil :in-flux nil :ratios nil)))

(branch :create
  (adapt-from-json :point)
  (lambda (state input)
    (destructuring-bind (&key uimod &allow-other-keys) input
      (cond (uimod (values nil t))
            (t "This is a financial chart analysis tool.")))))

(defun init-chart-entities (state &optional refresh)
  (when (and state (of-state :- :chart-point))
    (when (and (or refresh (not (of-state :- :chart-entities)))
               (nth (of-state :- :chart-point)
                    (of-state :- :chart-paths)))
      (let ((chart-path (namestring (nth (of-state :- :chart-point)
                                         (of-state :- :chart-paths)))))
        
        (instantiate-priority-macro-reader (load (format nil "~a/chart.lisp" chart-path)))
        (of-state :- :chart-entities (from-system-file *system* (format nil "~a/chart.lisp" chart-path)
                                                       :chart-entities))))))

(defun manifest-file-listing (is-creating path)
  (append (and is-creating
               (list (dx (uic-series :layout (:groups :rows '(2 2))
                                     :type (:series :table-interstitial)
                                     :role ((form)(call)))
                         (dx (uicc-field :name :system-name :type (:string)) "")
                         (dx (uicc-button :role ((call :n :form-input)))
                             "create")
                         "Testing."
                         (dx (uicc-button :role ((call :n :form-input)))
                             "cancel"))))
          (loop :for ix :from 0 :for dir :in (uiop:subdirectories path)
                :append (let ((props (from-system-file *system* (format nil "~a/chart.lisp" dir)
                                                       :properties)))
                          (destructuring-bind (&key name description) (rest props)
                            (and props (list (dx (uic-series :type (:series))
                                                 (list (dx (uicc-button :role ((contact-refreshing
                                                                                :a (list :point ix))))
                                                           name)
                                                       description)))))))))

(branch :nav
  (adapt-from-json :point :action :system-name :form-input)
  (adapt-from-alist :system :branch :face)
  (lambda (state input)
    (destructuring-bind (&key identity action system-name uimod point form-input &allow-other-keys) input
      (cond (identity (values nil))
            ((eq uimod :header-controls)
             (dx (uic-series :type (:ui :controls) :map #'buttonize-calling)
                 (list :create)))
            (form-input
             (case (intern (string-upcase form-input) "KEYWORD")
               (:create (print (list :bbb 10)))
               (:cancel (of-state :- :creation-in-progress nil))))
            (action
             (case (intern (string-upcase action) "KEYWORD")
               (:create (of-state :- :creation-in-progress (not (of-state :- :creation-in-progress))))))
            (state (when point
                     (of-state :- :chart-point point)
                     (init-chart-entities state t))
                   (let ((template-point (of-state :- :template-point)))
                     (destructuring-bind (&key system-name &allow-other-keys) input
                       (render (of-state nil :medium)
                               (dx (uic-series :type (:ui :list-table))
                                   (manifest-file-listing (of-state :- :creation-in-progress)
                                                          (asdf:system-relative-pathname
                                                           *system* "./analyses/")))))))))))

(branch :chart
  (adapt-from-json :entities :action :mode ;; next line: entities properties
                             :name :type :in-flux :points :points-in-flux :ratios)
  (adapt-from-alist :system :branch :face)
  (lambda (state input)
    (unless (or (not state) (of-state :- :chart-paths)) ;; load list of analyses
      (of-state :- :chart-paths (uiop:subdirectories (asdf:system-relative-pathname *system* "./analyses/"))))

    (init-chart-entities state)

    (when (and state (not (of-state :- :chart-point))) ;; assign chart-point to 0 if not present
      ;; (print (list :iii (of-state :- :chart-point) (of-state :- :chart-paths)))
      ;; (let ((chart-path (namestring (nth (of-state :- :chart-point)
      ;;                                    (of-state :- :chart-paths)))))
      ;;   (instantiate-priority-macro-reader (load chart-path)))
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
             (let ((collected)
                   (ex-lines ;; (loop :for ix :from 0 :for line :in (read-csv #P"/tmp/USDJPY.cl.csv")
                     ;;       :collect (destructuring-bind (x-start y-start x-end y-end weight)
                     ;;                    (mapcar #'read-from-string line)
                     ;;                  (list :type "line" :points (list (list x-start y-start)
                     ;;                                                   (list x-end   y-end))
                     ;;                        :name (format nil "obx-~a" ix)
                     ;;                        :weight weight :points-in-flux nil
                     ;;                        :in-flux nil :ratios nil)))
                     ))

               ;; (print (list :aa action (and (find-package "ABCD")
               ;;                              (find-symbol "CHART-TEST-USDJPY" "ABCD")
               ;;                              (boundp (find-symbol "CHART-TEST-USDJPY" "ABCD"))
               ;;                              (list-entities (symbol-value (find-symbol "CHART-TEST-USDJPY"
               ;;                                                                        "ABCD"))))))
                              
               (when (and (find-package "ABCD")
                          (find-symbol "CHART-TEST-USDJPY" "ABCD")
                          (boundp (find-symbol "CHART-TEST-USDJPY" "ABCD")))
                 (loop :for ix :from 0
                       :for line :in (list-entities (symbol-value (find-symbol "CHART-TEST-USDJPY" "ABCD")))
                       :do (push (destructuring-bind (x-start y-start x-end y-end)
                                     (app.chart::espan-points line)
                                   (list :type "line" :points (list (list x-start y-start)
                                                                    (list x-end   y-end))
                                         :name (format nil "obx-~a" ix)
                                         :weight 1 :points-in-flux nil
                                         :in-flux nil :ratios nil))
                                 ex-lines)))
               
               (unless (of-state :- :line-templater)
                 (of-state :- :line-templater
                           (build-templater (from-system-file *system* "sheet.lisp"
                                                              :chart-entity-template-line)
                                            :type :x-start :y-start :x-end :y-end :weight)))
               ;; (print (list :ent entities (of-state :- :chart-entities) (of-state :- :entity-data)))
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
                         (let ((edata (of-state :- :entity-data)))
                           (if index (setf (nth index edata) item)
                               (progn (push item edata)
                                      (push (funcall (of-state :- :line-templater)
                                                     :x-start x-start :x-end x-end
                                                     :y-start y-start :y-end y-end :type type)
                                            collected)))
                           (of-state :- :entity-data edata)))))))
               (let ((entities (of-state :- :chart-entities)))
                 (setf (second entities) (append (second (of-state :- :chart-entities))
                                                 (reverse collected)))
                 (of-state :- :chart-entities entities)
                 (of-state :- :entity-data)
                 ;; (print ex-lines)
                 ex-lines)))
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
                  (let* ((chart-path (namestring (nth (of-state :- :chart-point)
                                                      (of-state :- :chart-paths))))
                         (data (second (third (second (from-system-file
                                                       *system* (format nil "~a/chart.lisp" chart-path)
                                                       :chart-entities))))))
                    (file-to-string data)
                    (cl-ppcre::regex-replace-all ",[^,]+\\n" (file-to-string data)
                                                 (coerce (list #\Newline) 'string))))
                 (t (render (funcall state nil :medium)
                            (dx (uich-candle :type (:green-red :abc :def-ghi))
                                *system* :chart)))))))))

(defmacro fx-path-access (state input accessor)
  (let ((form (gensym)) (dtype-spec (gensym)))
    `(lambda (,state ,input)
       (destructuring-bind (&key data path &allow-other-keys) ,input
         (when (and ,state data path)
           (at-fx-path (rest path)
                       (lambda (,form)
                         (let ((,dtype-spec (rest (assoc :type (cddr ,form)))))
                           (setf (second ,form)
                                 (case (first ,dtype-spec)
                                   (:numeric (read-from-string data))
                                   (t data)))))
                       ,accessor))
         ,input))))

(defmacro form-sort (state input accessor)
  (let ((index (gensym)) (move-to (gensym)) (elist (gensym)))
    `(lambda (,state ,input)
       (destructuring-bind (&key data path sort remove &allow-other-keys) ,input
         (or (and ,state (let ((,elist (second ,accessor)))
                           (and path (cond (sort (destructuring-bind (,index ,move-to) sort
                                                   (let ((moved (nth (1+ ,index) ,elist)))
                                                     (if (zerop ,index) (pop ,elist)
                                                         (rplacd (nthcdr index ,elist)
                                                                 (rest (nthcdr (1+ ,index) ,elist))))
                                                     (if (zerop ,move-to) (setf ,elist (cons moved ,elist))
                                                         (rplacd (nthcdr ,move-to ,elist)
                                                                 (cons moved (nthcdr (1+ ,move-to)
                                                                                     ,elist))))))
                                                 ,accessor
                                                 (list :complete 0))
                                           (remove (if (zerop remove) (pop ,elist)
                                                       (rplacd (nthcdr (1- remove) ,elist)
                                                               (rest (nthcdr remove ,elist))))
                                                   ,accessor
                                                   (values (list :complete 0)
                                                           t))))))
             ,input)))))

(branch :chentity
  (adapt-from-json :data :path :sort :remove :action :mode)
  (adapt-from-alist :system :branch :face)
  (fx-path-access state input (of-state :- :chart-entities))
  (lambda (state input)
    (destructuring-bind (&key action path &allow-other-keys) input
      (let ((asym (intern (string-upcase (symbol-munger::camel-case->lisp-name action)) "KEYWORD")))
        (flet ((exprs-to-linespecs (path)
                 (loop :for ix :from 0 :for line :in (read-csv path)
                       :collect (destructuring-bind (x-start y-start x-end y-end weight)
                                    (mapcar #'read-from-string line)
                                  ;; (list :type "line" :points (list (list x-start y-start)
                                  ;;                                  (list x-end   y-end))
                                  ;;       :name (format nil "obx-~a" ix)
                                  ;;       :weight weight :points-in-flux nil :in-flux nil :ratios nil)
                                  (funcall (of-state :- :line-templater)
                                           :x-start x-start :x-end x-end :weight 1
                                           :y-start y-start :y-end y-end :type "line")
                                  
                                  ;; (print `(fx
                                  ;;   (span
                                  ;;    (fx "line" (:fx :uicc-select) (:type :select)
                                  ;;        (:options "line" "retraceX" "retraceY"))
                                  ;;    (fx (nth 0 '(:none :left :right :both)) (:fx :uicc-button) (:type)
                                  ;;        (:role (uir-toggle :symap '(:| ∘─∘ | :|─∘─∘ | :| ∘─∘─| :─∘─∘─))))
                                  ;;    (fx ,x-start (:fx :uicc-field) (:type :numeric :integer))
                                  ;;    (fx ,y-start (:fx :uicc-field) (:type :numeric :float))
                                  ;;    (fx ,x-end   (:fx :uicc-field) (:type :numeric :integer))
                                  ;;    (fx ,y-end   (:fx :uicc-field) (:type :numeric :float))
                                  ;;    (fx ,weight  (:fx :uicc-field)  (:type :numeric :float))
                                  ;;    )
                                  ;;   (:fx :uic-series :layout (:groups :rows (-2 4 2)))
                                  ;;   (:role uir-call-form (uir-reducable))))

                                  ))))
          ;; (print (list :aa action asym path (and (find-package "ABCD")
          ;;                                        (find-symbol "CHART-TEST-USDJPY" "ABCD")
          ;;                                        (boundp (find-symbol "CHART-TEST-USDJPY" "ABCD"))
          ;;                                        (list-entities (symbol-value (find-symbol "CHART-TEST-USDJPY"
          ;;                                                                                  "ABCD"))))))
          (case asym
            (:populate (at-fx-path (rest path)
                                   (lambda (form)
                                     ;; (print (list :ff form))
                                     ;; (at-fx-path '(1)
                                     ;;             (lambda (item)
                                     ;;               (let ((specs (exprs-to-linespecs
                                     ;;                             (pathname (second (third (second item))))))
                                     ;;                     (form-root (loop :for i :below 3
                                     ;;                                      :for el :in (second item)
                                     ;;                                      :collect el)))
                                                     
                                     ;;                 (print (list :ee (second (third (second item)))
                                     ;;                              (second item)
                                     ;;                              specs
                                     ;;                              item))
                                     ;;                 (print (list :item item))
                                     ;;                 ;; (setf (second item) (append form-root specs))
                                     ;;                 ;; (setf (cdr item) (cons (second item) specs))
                                     ;;                 item))
                                     ;;             form)
                                     ;; (print (list :tt (second form) (second (cadadr form))))
                                     ;; (let ((specs (exprs-to-linespecs
                                     ;;               (pathname (second (third (second (cadadr form))))))))
                                       ;; (print (list :ooo item))
                                     (setf (cdadr form)
                                           (cons (cadadr form)
                                                 (exprs-to-linespecs
                                                  (pathname (second (third (second (cadadr form))))))))
                                     )
                                   (of-state :- :chart-entities))
             (print (list :sst (of-state :- :chart-entities)))))))
      input))
  (lambda (state input)
    (destructuring-bind (&key data path sort remove action &allow-other-keys) input
      ;; (print (list :inp input remove action))
      (or (and state (let ((entities (of-state :- :chart-entities)))
                       (let ((elist (second entities)))
                         (and path (cond (sort (destructuring-bind (index move-to) sort
                                                 (let ((moved (nth (1+ index) elist)))
                                                   (if (zerop index) (pop elist)
                                                       (rplacd (nthcdr index elist)
                                                               (rest (nthcdr (1+ index) elist))))
                                                   (if (zerop move-to) (setf elist (cons moved elist))
                                                       (rplacd (nthcdr move-to elist)
                                                               (cons moved (nthcdr (1+ move-to)
                                                                                   elist))))))
                                               (of-state :- :chart-entities entities)
                                               (list :complete 0))
                                         (action
                                          (case action
                                            ("remove" (print :abcde))))
                                         (remove (print (list :xx elist path remove))
                                                 (if (zerop remove) (pop elist)
                                                     (rplacd (nthcdr (1- remove) elist)
                                                             (rest (nthcdr remove elist))))
                                                 (print (list :lll elist))
                                                 (of-state :- :chart-entities entities)
                                                 (values (list :complete 0)
                                                         t)))))))
          input)))
  (lambda (state input)
    (destructuring-bind (&key identity uimod action &allow-other-keys) input
      (cond (identity :meta-code-form)
            ((eq uimod :header-controls) (dx (uic-series :type (:ui :controls)
                                                         :map #'buttonize-calling)
                                             (list :add-span :add-set :save)))
            ((eq uimod :footer-controls) (dx (uic-series :type (:ui :controls)
                                                         :map #'buttonize-calling)
                                             (list :save)))
            (action (let ((chart-path (namestring (nth (of-state :- :chart-point)
                                                       (of-state :- :chart-paths)))))
                      (case (intern (string-upcase action) "KEYWORD")
                        (:save (let ((output))
                                 ;; (setf output (format nil "(progn~%~{~a~%~})" chart-entities))
                                 (setf output (and state (of-state :- :chart-entities))
                                       (from-system-file *system* (format nil "~a/chart.lisp" chart-path)
                                                         :chart-entities)
                                       (of-state :- :chart-entities))
                                 (instantiate-priority-macro-reader
                                   (load (format nil "~a/chart.lisp" chart-path)))
                                 output))
                        (:add-span
                         ;; (of-state :- :line-templater
                         ;;           (funcall (build-templater (from-system-file *system* "sheet.lisp"
                         ;;                                                       :chart-entity-template-line)
                         ;;                                     :type :format)))
                         (setf (cdddr (second (of-state :- :chart-entities)))
                               (cons (apply (of-state :- :line-templater)
                                            (list :type "line" :x-start 0 :y-start 0
                                                  :x-end 0 :y-end 0 :weight 1))
                                     (cdddr (second (of-state :- :chart-entities))))))
                         ;; (print (list :ce (of-state :- :chart-entities))))
                        (:add-set
                         (of-state :- :set-templater
                                   (funcall (build-templater (from-system-file *system* "sheet.lisp"
                                                                               :chart-entity-template-set)
                                                             :type :format)))
                         (setf (cdddr (second (of-state :- :chart-entities)))
                               (cons (of-state :- :set-templater)
                                     (cdddr (second (of-state :- :chart-entities)))))))))
            (t (init-chart-entities state)
               (when state
                 (render (funcall state nil :medium)
                         (dx (uic-frame :type (:meta-code))
                             (seed.modulate::express (of-state :- :chart-entities))))))))))

