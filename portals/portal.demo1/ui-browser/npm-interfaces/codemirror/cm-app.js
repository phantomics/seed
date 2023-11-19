import { minimalSetup, EditorView } from 'codemirror'
import { highlightActiveLine, lineNumbers, highlightActiveLineGutter } from '@codemirror/view'
import { Extension, EditorState, Compartment, Facet } from '@codemirror/state'
import { closeBrackets, closeBracketsKeymap } from '@codemirror/autocomplete'
import { bracketMatching, foldGutter } from '@codemirror/language'
import { python } from '@codemirror/lang-python'
import { Lisp } from '@codemirror/lang-lisp'

var __PS_MV_REG;
if ('undefined' === typeof lispSetup) {
    var lispSetup = (function () {
        __PS_MV_REG = [];
        return [bracketMatching(), closeBrackets(), lineNumbers(), highlightActiveLine(), highlightActiveLineGutter(), foldGutter()];
    })();
};
global.python = python;
global.createCodemirror = function (target, data) {
    var language = new Compartment;
    var tabSize = new Compartment;
    var state = EditorState.create({ doc : data, extensions : [minimalSetup, lispSetup, language.of(Lisp()), tabSize.of(EditorState.tabSize.of(4))] });
    var view = new EditorView({ state : state,
                                parent : target,
                                doc : data
                              });
    __PS_MV_REG = [];
    return view;
};