;;;; app.chart.lisp

(in-package #:app.chart)

(defclass chart ()
  ((%name     :accessor chart-name
              :initform nil
              :initarg  :name)
   (%entities :accessor chart-entities
              :initform nil
              :initarg  :entities)
   (%data     :accessor chart-data
              :initform nil
              :initarg  :data)))

(defclass entity ()
  ((%name  :accessor entity-name
           :initform nil
           :initarg  :name)
   (%scale :accessor entity-scope
           :initform nil
           :initarg  :scale)
   (%style :accessor entity-style
           :initform nil
           :initarg  :style)))

(defclass style ()
  ((%name  :accessor style-name
           :initform nil
           :initarg  :name)
   (%color :accessor style-color
           :initform nil
           :initarg :color)))

(defclass entity-span (entity)
  ((%points :accessor espan-points
            :initform nil
            :initarg  :points)))

(defclass enspan-line (entity-span)
  ((%extend :accessor enspan-line-extend
            :initform nil
            :initarg  :extend)))

(defclass enspan-retrace (entity-span)
  ((%axis   :accessor enspan-retrace-axis
            :initform nil
            :initarg  :axis)
   (%ratios :accessor enspan-retrace-ratios
            :initform nil
            :initarg  :ratios)))

(defclass style-line (style)
  ((%stroke :accessor stline-stroke
            :initform nil
            :initarg  :stroke)))

(defmacro chart-view (name data &body entities)
  `(make-instance 'chart :name ,name :data ,data
                         :entities (list ,@entities)))

(defmacro chart-style (type name &body props)
  `(make-instance ',(intern (string type) "APP.CHART")
                  :name ,name ,@props))

(defgeneric plot (chart data))

(defmethod plot ((chart chart) data)
  (if (not (chart-data chart))
      (setf (chart-data chart) data)
      (let* ((old-data (chart-data chart))
             (coords-count (second (array-dimensions old-data)))
             (old-length (first (array-dimensions old-data)))
             (starting-point (* coords-count (1- old-length)))
             (last-coords) (next-coords))
        (loop :for i :below coords-count
              :do (push (row-major-aref data (+ i starting-point             )) last-coords)
                  (push (row-major-aref data (+ i starting-point coords-count)) next-coords))
        (setf last-coords (reverse last-coords)
              next-coords (reverse next-coords))

        (loop :for entity :in (chart-entities chart) :when (typep entity 'enspan-line)
              :do (let* ((line-origin (caar (espan-points entity)) )
                         (ratio (- line-origin (cadar (espan-points entity))))
                         (prev-delta (- line-origin (first last-coords)))
                         (next-delta (- line-origin (first next-coords)))
                         (prev-ratio (- (* (/ prev-delta ratio) (cadar (espan-points entity)))
                                        (second last-coords))))
                    prev-ratio
                    ))
        )))

(defmacro line (style xfrom yfrom xto yto)
  `(make-instance 'enspan-retrace :points (list ,xfrom ,yfrom ,xto ,yto)
                                  :style ,style))

;; (chart-view :main-chart 'stuff (line))
