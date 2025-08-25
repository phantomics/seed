;; sheet.lisp
;; Seed-interfaced file - do not edit manually

(in-package #:abcd)
(defvar *profile* nil)
(defvar *input* nil)

(defvar *chart-styles* nil)

:analysis-invocation
(defun load-analyses (&optional index)
  (dolist (dir (uiop:subdirectories (asdf:system-relative-pathname :abcd "./analyses/")))
    (load (pathname (format nil "~a/chart.lisp" dir)))))

(load-analyses)

:chart-styles
(progn (proclaim '(special *base-line-style*))
       (setf (symbol-value '*base-line-style*)
             (chart-style :style-line :base-line :color '(:red :green :green)
               :stroke '(:solid :dots))))

:chart-entity-template-line
(fx (span (fx :type    (:fx :uicc-select) (:type :select) (:options "line" "retraceX" "retraceY"))
          (fx (nth 0 '(:none :left :right :both)) (:fx :uicc-button)
              (:type) (:role (uir-toggle :symap '(:| ∘─∘ | :|─∘─∘ | :| ∘─∘─| :|─∘─∘─|))))
          (fx :x-start (:fx :uicc-field)  (:type :numeric :integer))
          (fx :y-start (:fx :uicc-field)  (:type :numeric :float))
          (fx :x-end   (:fx :uicc-field)  (:type :numeric :integer))
          (fx :y-end   (:fx :uicc-field)  (:type :numeric :float)))
    (:fx :uic-series :layout (:groups :rows (-2 4)))
    (:role (uir-call-form :options (list 'line 'retrace)) (uir-reducable)))
