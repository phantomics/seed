;;;; test/test-branch.lisp
;;;;
;;;; Tests for the branch context: each branch's function, as channel-fns
;;;; builds it, binds *branch-context* to its system and branch while it runs.

(in-package #:seed.generate.test)

(in-suite branch-context)

(defun context-reader ()
  "A branch function form that returns the branch context it runs in."
  '(lambda (state input)
     (declare (ignore state input))
     seed.generate:*branch-context*))

(defun build-branch-function (system branch fns)
  "Compile the branch function channel-fns builds from FNS for SYSTEM and
   BRANCH."
  (eval (seed.generate::channel-fns system branch fns)))

(def-test branch-context-unbound-outside ()
  "Outside any branch's function, there is no branch context."
  (is (null seed.generate:*branch-context*)))

(def-test branch-context-bound-by-single-function ()
  "A branch made of a single function binds its system and branch while it
   runs."
  (is (equal '(:system :demo.access :branch :cms)
             (funcall (build-branch-function :demo.access :cms (list (context-reader)))
                      nil nil))))

(def-test branch-context-bound-by-pipeline ()
  "A branch made of a pipeline of functions binds its context for every stage."
  (let ((pass-through '(lambda (state input)
                         (declare (ignore state))
                         input)))
    (is (equal '(:system :demo.access :branch :cms)
               (funcall (build-branch-function :demo.access :cms
                                               (list pass-through (context-reader)))
                        nil nil)))))

(def-test branch-context-restored-after-call ()
  "The binding lasts only for the branch's call."
  (funcall (build-branch-function :demo.access :cms (list (context-reader))) nil nil)
  (is (null seed.generate:*branch-context*)))

(def-test branch-context-nested-calls ()
  "A branch called from another binds its own context for its call, and the
   caller's context is restored when it returns."
  (let* ((inner (build-branch-function :demo.access :catalog (list (context-reader))))
         (outer (build-branch-function
                 :demo.access :cms
                 (list `(lambda (state input)
                          (declare (ignore input))
                          (list (funcall ,inner state nil)
                                seed.generate:*branch-context*))))))
    (destructuring-bind (inner-context outer-context) (funcall outer nil nil)
      (is (equal '(:system :demo.access :branch :catalog) inner-context))
      (is (equal '(:system :demo.access :branch :cms) outer-context)))))

(def-test branch-context-keeps-values ()
  "Binding the context does not change what the branch returns, including
   multiple values."
  (multiple-value-bind (a b)
      (funcall (build-branch-function :demo.access :cms
                                      (list '(lambda (state input)
                                               (declare (ignore state input))
                                               (values 1 2))))
               nil nil)
    (is (eql 1 a))
    (is (eql 2 b))))
