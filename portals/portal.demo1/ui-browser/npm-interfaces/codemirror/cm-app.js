import { basicSetup, EditorView } from 'codemirror'
import { EditorState, Compartment, Facet } from '@codemirror/state'
import { indentService } from '@codemirror/language'

var __PS_MV_REG;
global.createCodemirror = function (target, data) {
    if ('undefined' === typeof lispIndentExtension) {
        var lispIndentExtension = indentService.of(function (context, pos) {
            return console.log(context.lineAt(pos, -1));
        });
    };
    var tabSize = new Compartment;
    var state = EditorState.create({ doc : data, extensions : [basicSetup, lispIndentExtension, tabSize.of(EditorState.tabSize.of(8))] });
    var view = new EditorView({ state : state,
                                parent : target,
                                doc : data
                              });
    __PS_MV_REG = [];
    return view;
};