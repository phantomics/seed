;;;; demo-image.lisp

(in-package #:demo-image)

(raster-process-layers
 (load :path "sample.jpg")
 (apl :exp "1+input")
 (out :path "sample2.jpg"))
