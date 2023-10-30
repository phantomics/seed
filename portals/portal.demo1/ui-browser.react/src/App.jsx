import React from 'react'
import jQuery from 'jquery'
import ReactDOM from 'react-dom/client'
import { CContainer, CSpinner, CRow, CCol } from '@coreui/react'
import './main.scss'
import './app.css'

function transact(portal, branch, input, nextSuccess) {
    return jQuery.ajax({ url : './contact/',
                         type : 'POST',
                         dataType : 'json',
                         contentType : 'application/json; charset=utf-8',
                         async : false,
                         data : JSON.stringify({ portal : portal,
                                                 branch : branch,
                                                 input : input
                                               }),
                         success : nextSuccess,
                         error : function (data, err) {
        return console.log(11, data, err);
    }
                       });
};
var __PS_MV_REG;
if ('undefined' === typeof components) {
    var components = {  };
};
if ('undefined' === typeof EXTENDS0) {
    var EXTENDS0 = React.Component;
};
function SeedView(props) {
    var self = this;
    if ('undefined' === typeof props.data) {
        transact('PORTAL.DEMO1', 'VIEW', { interfaceSpec : ['browser', 'react'] }, function (data) {
            console.log('dt', data);
            return self.state = { data : data };
        });
    } else {
        self.state = { data : props.data };
    };
    __PS_MV_REG = [];
    return console.log('load');
};
SeedView.prototype = Object.create(React.Component.prototype);
SeedView.prototype.constructor = SeedView;
SeedView.prototype.render = function () {
    var self = this;
    var content = this.state && this.state.data && this.state.data.ct;
    var meta = this.state && this.state.data && this.state.data.mt;
    var builder29 = self[meta.builder];
    console.log('cl', self, content, meta);
    return 'undefined' === typeof builder29 ? 'abc' : builder29(self, content, meta);
};
SeedView.prototype.layoutColumnar = function (self, elements, meta) {
    return React.createElement(CContainer, {  }, React.createElement(CRow, {  }, elements.map(function (item, index) {
        var lspec = meta.specs[index];
        var className = 'undefined' !== typeof item.mt.type ? item.mt.type.join(' ') : null;
        return React.createElement(CCol, { key : 'view-column-' + index,
                                           className : 'undefined' === typeof className ? '' : className,
                                           md : lspec.width
                                         }, self.manifest(item));
    })));
};
SeedView.prototype.layoutStacked = function (self, elements, meta) {
    return React.createElement(CContainer, {  }, elements.map(function (item, index) {
        var lspec = meta.specs[index];
        return React.createElement('div', { key : 'view-tier-' + index }, self.manifest(item));
    }));
};
SeedView.prototype.manifest = function (item) {
    var component = components[item.mt.reactComponent];
    if ('undefined' === typeof component) {
        if ('ar' === item.ty && typeof item.ct === 'string') {
            var className = item.mt.classes.join(' ');
            return React.createElement('h1', { className : className }, item.ct);
        } else {
            return 'abc';
        };
    } else {
        return React.createElement(component, { data : item });
    };
};
components.SeedView = SeedView;
function MainComponent() {
    return React.createElement(SeedView, {  });
};
export default MainComponent