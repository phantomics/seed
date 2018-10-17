;;;; demo-image.asd

(asdf:defsystem #:demo-image
  :description "Sample Seed system implementing a raster image editor."
  :author "Andrew Sengul"
  :license "GPL-3.0"
  :serial t
  :depends-on (:seed.app-model.raster-layers.base)
  :components ((:file "package")
               (:file "main")
	       (:file "utils")))

