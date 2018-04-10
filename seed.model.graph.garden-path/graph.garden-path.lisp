;;;; graph.garden-path.lisp

(in-package #:seed.model.graph.garden-path)

(defmacro graph-garden-path (function-name &rest nodes)
  "Build the function for traversal of a path given the specification of the nodes in the path."
  (let ((node-ids (mapcar #'first nodes)))
    (flet ((build-conditions (node)
	     (let ((last-link-index (1- (length (getf node :links)))))
	       `(cond ,@(mapcar (lambda (link-data link-index)
				  (let ((nix (position (first link-data)
						       node-ids))
					(link (rest link-data)))
				    (cond ((eq :switch (getf node :type))
					   `(,(if (= link-index last-link-index)
						  t (getf link :if))
					      (funcall (aref nodes ,nix)
						       state content)))
					  ((eq :option (getf node :type))
					   `(,(if (= link-index last-link-index)
						  t `(= input ,link-index))
					     (funcall (aref nodes ,nix)
						      state content)))
					  ((eq :action (getf node :type))
					   `(,(if (= link-index last-link-index)
						  t (getf link :if))
					      (funcall (aref nodes ,nix)
						       state content))))))
				(getf node :links)
				(loop for i from 0 to last-link-index collect i))))))
    `(let ((nodes nil))
       (setq nodes (vector ,@(mapcar (lambda (node)
				       `(lambda (state &optional content)
					  (let ((content ,(if (getf node :items)
							      `(append content (quote (,(getf node :items))))
							      `content)))
					    ,@(getf node :do)
					    ,(cond ((eq :portal (getf node :type))
						    `(funcall (function ,(getf node :to)) state))
						   ((eq :switch (getf node :type))
						    (build-conditions node))
						   (t `(values content state
							       (lambda (state input) ,(build-conditions node))))))))
				     (mapcar #'rest nodes))))
       (defun ,function-name (state) (funcall (aref nodes 0) state))))))

(defun generate-blank-node (type)
  "Generate a blank node for use in a garden path, starting with a UUID key so the node can be uniquely identified for logging purposes."
  (let ((base (list (let ((str (make-string-output-stream)))
		      (uuid:format-as-urn str (uuid:make-v1-uuid))
		      (intern (string-upcase (third (split-sequence #\: (get-output-stream-string str))))
			      "KEYWORD"))
		    :type type)))
    (append base (if (eq :portal type)
		     (list :to nil)
		     (list :items nil :do nil :links nil)))))

(defun generate-blank-link ()
  "Generate a blank link to connect garden path nodes."
  (list nil :items nil :if nil))



