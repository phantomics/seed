;;;; panic.lisp

;;; The MIT License (MIT)
;;;
;;; Copyright (c) 2015 Michael J. Forster
;;;
;;; Permission is hereby granted, free of charge, to any person obtaining a copy
;;; of this software and associated documentation files (the "Software"), to deal
;;; in the Software without restriction, including without limitation the rights
;;; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
;;; copies of the Software, and to permit persons to whom the Software is
;;; furnished to do so, subject to the following conditions:
;;;
;;; The above copyright notice and this permission notice shall be included in all
;;; copies or substantial portions of the Software.
;;;
;;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
;;; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
;;; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
;;; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
;;; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
;;; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
;;; SOFTWARE.

(in-package #:panic)

(defun self-evaluating-form-p (form)
  "Return true if FORM is a self-evaluating object, false otherwise.

See CLHS 3.1.2.1.3 Self-Evaluating Objects."
  (and (not (symbolp form))
       (not (consp form))))

(defun jsl-form-p (form)
  "Return true if FORM is a JSL form, false otherwise.

A JSL form is an extension of a Common Lisp compound form, with the
car of the form being a keyword. See CLHS 3.1.2.1.2 Conses as Forms."
  (and (consp form)
       (or (keywordp (car form))
	   (and (consp (car form))
		(eq (caar form)
		    'ps:@)))))

(defun destructure-jsl-form (form) 
  "Return as multiple values the type (a keyword), props (a property
list), and children (a list) of the JSL form FORM."
  (let ((type (first form))
	(props nil)
	(children (rest form)))
    (do ((rest (rest form) (cddr rest)))
	((or (null (cdr rest))
	     (not (keywordp (first rest))))
	 (setf children rest))
      (push (second rest) props)
      (push (first rest) props))
(values type props children)))

(defun walk-form (form)
  "Walk the form FORM, expanding JSL forms into Parenscript function
forms for React DOM operations, and return the resulting form."
  (cond ((self-evaluating-form-p form)
         form)
        ((symbolp form)
         form)
        ((jsl-form-p form)
         (multiple-value-bind (type props children)
             (destructure-jsl-form form)
           `(ps:chain -react (create-element ,(if (consp type)
						  (mapcar #'alexandria:ensure-symbol type)
						  (let ((sym (alexandria:ensure-symbol type)))
						    (if (eql #\- (aref (write-to-string sym) 0))
                                                        sym
							(string-downcase sym))))
					     (ps:create ,@(mapcar #'(lambda (x)
								      (if (keywordp x)
									  (alexandria:ensure-symbol x)
                                                                          x))
								  props))
                                             ,@(mapcar #'walk-form children)))))
        ((consp form)
         form)
        (t
         (error "~A fell through COND expression." form))))

(ps:defpsmacro jsl (form)
  "Return the form FORM with any JSL forms expanded.

JSL is a Lispy take on JSX, the React Javascript syntax extension.  A
JSL form is a list with the first element being a keyword naming a
React element type. All but the last of the remaining elements
constitute a possibly empty list of alternating React property names
and values. The last element is a possibly empty list of the children
of the React element. See the React JSX documentation."
  (walk-form form))

(ps:defpsmacro defcomponent (name (&rest args
                                         &key (display-name (string (if (consp name)
									(first (last name))
									name)))
                                         get-initial-state
                                         get-default-props
                                         prop-types
                                         mixins
                                         statics
                                         component-will-mount
                                         component-did-mount
                                         component-will-receive-props
                                         should-component-update
                                         component-will-update
                                         component-did-update
                                         component-will-unmount
                                         &allow-other-keys)
                                  &body render-body)
  "Define a Parenscript special variable named NAME with the value
being a React component class with DISPLAY-NAME attribute NAME, with a
mandatory RENDER method having the body RENDER-BODY, and with optional
lifecycle methods GET-INITIAL-STATE, GET-DEFAULT-PROPS, PROP-TYPES,
MIXINS, STATICS, COMPONENT-WILL-MOUNT, COMPONENT-DID-MOUNT,
COMPONENT-WILL-RECEIVE-PROPS, SHOULD-COMPONENT-UPDATE,
COMPONENT-WILL-UPDATE, COMPONENT-DID-UPDATE, and
COMPONENT-WILL-UNMOUNT.

See the React Top Level API, Component API, and Component Specs and
Lifecycle documentation."
  (flet ((plist-with-symbols (plist)
           (let ((new-plist '()))
             (alexandria:doplist (k v plist new-plist)
               (setf (getf new-plist (alexandria:ensure-symbol k)) v)))))
    `(,(if (consp name) 'setf 'defvar) ,name
      (create-react-class

       ;;(ps:chain -react
	;;	 (create-class
       (ps:create 'display-name ,display-name
		  'render #'(lambda () ,@render-body)
		  ,@(when get-initial-state `('get-initial-state ,get-initial-state))
		  ,@(when get-default-props `('get-default-props ,get-default-props))
		  ,@(when prop-types `('prop-types ,prop-types))
		  ,@(when mixins `('mixins ,mixins))
		  ,@(when statics `('statics ,statics))
		  ,@(when component-will-mount `('component-will-mount ,component-will-mount))
		  ,@(when component-did-mount `('component-did-mount ,component-did-mount))
		  ,@(when component-will-receive-props `('component-will-receive-props ,component-will-receive-props))
		  ,@(when should-component-update `('should-component-update ,should-component-update))
		  ,@(when component-will-update `('component-will-update ,component-will-update))
		  ,@(when component-did-update `('component-did-update ,component-did-update))
		  ,@(when component-will-unmount `('component-will-unmount ,component-will-unmount))
		  ,@(plist-with-symbols
		     (alexandria:remove-from-plist args
						   :display-name
						   :get-initial-state
						   :get-default-props
						   :prop-types
						   :mixins
						   :statics
						   :component-will-mount
						   :component-did-mount
						   :component-will-receive-props
						   :should-component-update
						   :component-will-update
						   :component-did-update
						   :component-will-unmount)))))));)
