;;;; graph.garden-path.lisp

(in-package #:seed.app-model.graph.garden-path)

(defmacro graph-garden-path (function-name &rest nodes)
  "Build the function for traversal of a path given the specification of the nodes in the path."
  (let ((node-ids (mapcar (lambda (node) (getf node :id))
			  nodes))
	(nodes-sym (gensym)) (state (gensym)) (content (gensym)))
    (labels ((build-conditions (node)
	       ;; manifest the conditions that pertain to this link; for option nodes, conditions are evaluated
	       ;; to determine whether the node is presented, while for action and switch nodes the conditions
	       ;; for each link are evaluated in turn and the first link whose condition evaluates to true is
	       ;; followed, or the last link is followed in case it has a condition that evaluates to false
	       (let ((last-link-index (1- (length (getf node :links)))))
		 `(cond ,@(mapcar (lambda (link-data link-index)
				    (let ((nix (position (getf link-data :to)
							 node-ids))
					  (link link-data))
				      (cond ((or (eq :switch (getf node :type))
						 (eq :action (getf node :type)))
					     `(,(if (= link-index last-link-index)
						    t (getf link :if))
						(funcall (aref nodes ,nix)
							 state content)))
					    ((eq :option (getf node :type))
					     `(,(if (= link-index last-link-index)
						    t `(= input ,link-index))
						(funcall (aref nodes ,nix)
							 state content))))))
				  (getf node :links)
				  (loop for i from 0 to last-link-index collect i)))))
	     (import-designated-symbols (form)
	       ;; import 'state symbols into the current package so the evaluation of code works properly
	       (mapcar (lambda (element) (cond ((listp element)
						(import-designated-symbols element))
					       ((not (symbolp element))
						element)
					       ((string= "STATE" (string-upcase element))
						'state)
					       (t element)))
		       form))
	     (format-node (node)
	       ;; generate the top-level format for each node
	       `(lambda (state &optional content)
		  (let ((content ,(if (getf node :items)
				      `(append content (quote (,(getf node :items))))
				      `content)))
		    ,@(import-designated-symbols (getf node :do))
		    ,(cond ((eq :portal (getf node :type))
			    `(funcall (function ,(getf node :to)) state))
			   ((eq :switch (getf node :type))
			    (build-conditions node))
			   (t `(values content state
				       (lambda (state input) ,(build-conditions node)))))))))
      `(let ((,nodes-sym (vector ,@(mapcar #'format-node nodes))))
	 (defun ,function-name (state) (funcall (aref ,nodes-sym 0) state))))))

(defun generate-blank-node (type meta)
  "Generate a blank node for use in a garden path, starting with a UUID key so the node can be uniquely identified for logging purposes."
  (let* ((id (let ((str (make-string-output-stream)))
	       (uuid:format-as-urn str (uuid:make-v1-uuid))
	       (intern (string-upcase (third (split-sequence #\: (get-output-stream-string str))))
		       "KEYWORD")))
	 (base (list :id id :type type :meta meta)))
    (values (append base (if (eq :portal type)
			     (list :to nil)
			     (list :items nil :do nil :links nil)))
	    id)))

(defun generate-blank-link (meta)
  "Generate a blank link to connect garden path nodes."
  (list :id (let ((str (make-string-output-stream)))
	      (uuid:format-as-urn str (uuid:make-v1-uuid))
	      (intern (string-upcase (third (split-sequence #\: (get-output-stream-string str))))
		      "KEYWORD"))
	:meta meta :items nil :if nil))

(defun add-blank-node (list type meta)
  "Add a blank node to the specified graph node list with the specified type and metadata."
  (multiple-value-bind (output-item output-id)
      (generate-blank-node type meta)
    (values (append list (list output-item))
	    output-id)))

(defun add-blank-link (list node-id meta)
  "Add a blank link to the node with the specified id in graph node list with the provided metadata."
  (loop for item in list
     do (if (eq node-id (getf item :id))
	    (setf (getf item :links)
		  (append (getf item :links)
			  (list (generate-blank-link meta))))))
  list)

(defun remove-graph-element (list node-id &optional link-id)
  "Remove the node or link from the specified graph node list. The presence of the link-id argument means a link will be removed, otherwise the node with the specified id will be removed."
  (loop for node in list when (or link-id (not (eq node-id (getf node :id))))
     collect (if (and link-id (eq node-id (getf node :id)))
		 (let ((new-node (copy-tree node)))
		   (progn (setf (getf new-node :links)
				(loop for link in (getf new-node :links)
				   when (not (eq link-id (getf link :id)))
				   collect link))
			  new-node))
		 node)))

(defun preprocess-nodes (input)
  "Prepare a set of nodes for expression as JSON."
  (let ((nodes (copy-tree input)))
    (loop for node in nodes
       do (setf (getf node :id)
		(string-upcase (getf node :id)))
	 (if (getf node :links)
	     (loop for link in (getf node :links)
		do (setf (getf link :id)
			 (string-upcase (getf link :id)))
		  (if (getf link :to)
		      (setf (getf link :to)
			    (string-upcase (getf link :to)))))))
    nodes))

(defun postprocess-nodes (input)
  "Prepare a structure converted back from JSON for use within the system."
  (let ((nodes (copy-tree input)))
    (loop for node in nodes
       do (setf (getf node :id)
		(intern (getf node :id) "KEYWORD"))
	 (if (getf node :links)
	     (loop for link in (getf node :links)
		do (setf (getf link :id)
			 (intern (getf link :id) "KEYWORD"))
		  (if (getf link :to)
		      (setf (getf link :to)
			    (intern (getf link :to) "KEYWORD"))))))
    nodes))
