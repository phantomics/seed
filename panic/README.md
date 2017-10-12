#panic

_Panic, because everyone else is using React already._

Panic is a wrapper library for React in Common Lisp (Parenscript). The
current version is compatible with React 0.11.2.

Panic is written in portable Common Lisp, depending only upon
Alexandria and Parenscript. Panic is being developed using SBCL on OS
X and should work on other implementations and platforms.

### Installation

Panic is not yet available via quicklisp. For now, clone the
repository, tell ASDF where to find the system definition, and load
the system with quicklisp:

```lisp
(ql:quickload "panic")
```

### Example

```lisp
(ps:ps
  (panic:defcomponent todo-list ()
    (flet ((create-item (item-text) (panic:jsl (:li item-text))))
      (panic:jsl
       (:ul (ps:chain this props items (map #'create-item))))))

  (panic:defcomponent todo-app
      (:get-initial-state
       #'(lambda () (ps:create :items (array) :text ""))
       :on-change
       #'(lambda (e)
           (ps:chain
            this
            (set-state (ps:create :text (ps:@ e target value)))))
       :handle-submit
       #'(lambda (e)
           (ps:chain e (prevent-default))
           (let ((next-items
                  (ps:chain
                   this
                   state
                   items
                   (concat (array (ps:@ this state text)))))
                 (next-text ""))
             (ps:chain
              this
              (set-state (ps:create :items next-items
                                    :text next-text))))))
    (panic:jsl
     (:div
      (:h3 "TODO")
      (todo-list (ps:create :items (ps:@ this state items)))
      (:form :on-submit (ps:@ this handle-submit)
             (:input :on-change (ps:@ this on-change)
                     :value (ps:@ this state text))
             (:button (+ "Add #"
                         (1+ (ps:@ this state items length))))))))

  (ps:chain
   -react
   (render-component (todo-app nil)
                     (ps:chain
                      document
                      (get-element-by-id "mount-node")))))
```

### License

Panic is distributed under the MIT license. See LICENSE.
