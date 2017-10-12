;;;; seed.express.glyphs.base.asd

(asdf:defsystem #:seed.express.glyphs.base
  :description "The standard set of glyphs representing Common Lisp symbols and datatypes."
  :author "Andrew Sengul"
  :license "GPL-3.0"
  :serial t
  :components
  ((:file "package")
   (:file "glyphs.base")))
