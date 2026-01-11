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

(defclass entity-set (entity)
  ((%items  :accessor eset-items
            :initform nil
            :initarg  :items)
   (%source :accessor eset-source
            :initform nil
            :initarg  :source)))

(defclass set-source () ())

(defclass set-source-file (set-source)
  ((%path :accessor set-source-file-path
          :initform nil
          :initarg  :path)))

(defclass set-source-file-csv (set-source-file) ())

(defclass entity-span (entity)
  ((%points :accessor espan-points
            :initform nil
            :initarg  :points)
   (%weight :accessor enspan-weight
            :initform nil
            :initarg  :weight)))

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
            :initarg  :stroke)
   (%extend :accessor stline-extend
            :initform nil
            :initarg  :extend)))

(defmacro chart-view (name data &body entities)
  (let ((namekey (intern (string name) "KEYWORD")))
    (proclaim (list 'special name))
    `(setf (symbol-value ',name)
           (make-instance 'chart :name ,namekey :data ,data :entities (list ,@entities)))))

(defmacro chart-style (type name &body props)
  `(make-instance ',(intern (string type) "APP.CHART")
                  :name ,name ,@props))

(defgeneric list-entities (set))

(defmethod list-entities ((chart chart))
  (let ((output))
    (dolist (entity (chart-entities chart))
      (if (typep entity 'entity-set)
          (setf output (append (list-entities entity) output))
          (push entity output)))
    (reverse output)))

(defmethod list-entities ((set entity-set))
  (let ((output))
    (dolist (entity (eset-items set))
      (if (typep entity 'entity-set)
          (setf output (append (list-entities entity) output))
          (push entity output)))
    output))

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
                    prev-ratio)))))

(defmacro eset (source &rest items)
  `(make-instance 'entity-set :source ,source :items (list ,@items)))

(defmacro essource (type path)
  (let ((class-sym (intern (format nil "SET-SOURCE-~a" type) "APP.CHART")))
    `(make-instance ',class-sym :path ,path)))

(defmacro span (style format xfrom yfrom xto yto &optional weight)
  `(make-instance 'enspan-retrace :points (list ,xfrom ,yfrom ,xto ,yto)
                                  :style ,style :weight ,weight))

