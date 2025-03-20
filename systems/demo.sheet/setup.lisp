;;; setup.lisp

(in-package #:demo.sheet)

(april-create-workspace sheet-space)

(meta-template customers-title
  (:fx . :uicc-field) (:type :text :pair :named :block))

(meta-template customers-image (:title . "Image")
  (:options "none" "man-relaxed" "man-irritated" "girl-relaxed" "girl-irritated")
  (:fx . :uicc-select) (:name . :persona-image) (:type :select :dropdown))

(meta-template customers-dialog
  (:fx . :uicc-field) (:type :text :area :pair :named :block))
