;;;; seed.app-model.raster-layers.base.asd

(asdf:defsystem #:seed.app-model.raster-layers.base
  :description "Seed application model for a layer-based raster image editor, using the opticl library for image processing."
  :author "Andrew Sengul"
  :license "GPL-3.0"
  :serial t
  :depends-on (:opticl)
  :components ((:file "package")
               (:file "raster-layers.base")))

