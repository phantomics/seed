import { basicSetup, EditorView } from 'codemirror'
import { EditorState, Compartment, Facet } from '@codemirror/state'
import { python } from '@codemirror/lang-python'
import { Lisp } from '@codemirror/lang-lisp'

var __PS_MV_REG;
global.python = python;
global.createCodemirror = function (target, data) {
    var language = new Compartment;
    var tabSize = new Compartment;
    var state = EditorState.create({ doc : data, extensions : [basicSetup, language.of(Lisp()), tabSize.of(EditorState.tabSize.of(8))] });
    var setf = window.bla;
    var view = new EditorView({ state : state,
                                parent : target,
                                doc : data
                              });
    __PS_MV_REG = [];
    return view;
};