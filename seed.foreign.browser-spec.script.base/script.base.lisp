;;;; script.base.lisp

(in-package #:seed.foreign.browser-spec.script.base)

(defmacro cornerstone ()
  "Generate the content for the root script source file."
  `(parenscript:ps
     (let ((j-query (require "jquery/dist/jquery.min.js")))
       (setf (@ window $) j-query
	     (@ window j-query) j-query
	     (@ window -react) (require "react")
	     (@ window -react-d-o-m) (require "react-dom")
	     (@ window -react-bootstrap) (require "react-bootstrap/dist/react-bootstrap")
	     (@ window create-react-class) (require "create-react-class")
	     (@ window -grid) (require "react-bootstrap/lib/Grid")
	     (@ window -row) (require "react-bootstrap/lib/Row")
	     (@ window -col) (require "react-bootstrap/lib/Col")
	     (@ window -tooltip) (require "react-bootstrap/lib/Tooltip")
	     (@ window -popover) (require "react-bootstrap/lib/Popover")
	     (@ window -overlay) (require "react-bootstrap/lib/Overlay")
	     (@ window -overlay-trigger) (require "react-bootstrap/lib/OverlayTrigger")
	     (@ window -autosize-input) (getprop (require "react-input-autosize") "default")
	     (@ window -autosize-textarea) (require "react-textarea-autosize")
	     (@ window -select) (getprop (require "react-select") "default")
	     (@ window -react-d-n-d-html5-backend) (getprop (require "react-dnd-html5-backend") "default")
	     (@ window -drag-drop-context) (getprop (require "react-dnd") "DragDropContext")
	     (@ window -drag-source) (getprop (require "react-dnd") "DragSource")
	     (@ window -drag-source-monitor) (getprop (require "react-dnd") "DragSourceMonitor")
	     (@ window -drop-target) (getprop (require "react-dnd") "DropTarget")
	     (@ window -drop-target-monitor) (getprop (require "react-dnd") "DropTargetMonitor")
	     (@ window -code-mirror) (require "react-codemirror")
	     (@ window -slate-editor) (getprop (require "slate-react") "Editor")
	     (@ window -slate-value) (getprop (require "slate") "Value")
	     (@ window -sketch-color-picker) (getprop (require "react-color/lib/components/sketch/Sketch")
						      "default")
	     ;; TODO: keypress package has only this numbered, minified script to include.
	     ;; Fork a version of keypress with a main script file.
	     (@ window -keypress) (require "keypress.js/keypress-2.1.5.min.js")
	     (@ window three-js) (require "three")
	     (@ window -react-faux-dom) (require "react-faux-dom")
	     (@ window -voxel-space) (require "voxel-engine")
	     (@ window -voxel-space-player) (require "voxel-player")
	     (@ window d3) (require "d3"))
       (require "bootstrap/js/tooltip")
       (require "script-loader!jquery-serializejson/jquery.serializejson.js")
       t)))
