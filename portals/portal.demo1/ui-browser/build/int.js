window.seedData = {  };
window.seedElements = {  };
function fetchContact(system, branch, input, handler) {
    __PS_MV_REG = [];
    return fetch('/contact/', { method : 'POST', headers : { 'Content-type' : 'application/json; charset=UTF-8', body : JSON.stringify({ system : system,
                                                                                                                                         branch : branch,
                                                                                                                                         input : input
                                                                                                                                       }) } }).then(function (response) {
        return response.json();
    }).then(function (data) {
        if (data.oobReload) {
            data.oobReload.forEach(function (item) {
                console.log('it', item);
                return htmx.trigger(seedElements[item], 'reload');
            });
        };
        return data;
    }).then(handler);
};
function fetchContact2(context, input, handler) {
    __PS_MV_REG = [];
    return fetch('/contact/', { method : 'POST',
                                headers : { 'Content-type' : 'application/json; charset=UTF-8' },
                                body : JSON.stringify({ system : context.system,
                                                        branch : context.branch,
                                                        input : input
                                                      })
                              }).then(function (response) {
        return response.json();
    }).then(function (data) {
        if (data.oobReload) {
            data.oobReload.forEach(function (item) {
                console.log('it', item);
                return htmx.trigger(seedElements[item], 'reload');
            });
        };
        return data;
    }).then(handler);
};
function realize(system, branch, element) {
    return function (input) {
        __PS_MV_REG = [];
        return fetch('/contact/', { method : 'POST',
                                    headers : { 'Content-type' : 'application/json; charset=UTF-8' },
                                    body : JSON.stringify({ system : system,
                                                            branch : branch,
                                                            input : input
                                                          })
                                  }).then(function (response) {
            return response.json();
        }).then(function (data) {
            return htmx.trigger(element, 'refresh');
        });
    };
};
function manifestLocality() {
    var types = {  };
    return function (action, option, body) {
        switch (action) {
        case 'register':
            if ('undefined' === typeof(types[option])) {
                types[option] = [];
            };
            __PS_MV_REG = [];
            return types[option] = types[option].concat(body);
        case 'list':
            __PS_MV_REG = [];
            return bangequals('undefined', typeof(types[option])) ? types[option] : null;
        case 'trigger':
            var _js39 = types[option];
            var _js41 = _js39.length;
            for (var _js40 = 0; _js40 < _js41; _js40 += 1) {
                var item = _js39[_js40];
                htmx.trigger(item, body);
            };
            __PS_MV_REG = [];
            return;
        };
    };
};
function mcodeHandlerOnDrag(element, mode) {
    return function (dragging) {
        console.log('ee', element, mode);
        console.log('mm', mode, dragging, dragging.source.element.parentElement.getAttribute('index'));
        console.log('drag-start', element, element.childNodes.length, element.childNodes);
        return Array.from(element.childNodes).filter(function (item) {
            return (item instanceof HTMLElement);
        }).map(function (n, itemIndex) {
            if (3 !== n.nodeType) {
                __PS_MV_REG = [];
                return dropTargetForElements({ element : n,
                                               getData : function (data) {
                    __PS_MV_REG = [];
                    return attachClosestEdge({  }, { element : n,
                                                     input : data.input,
                                                     allowedEdges : ['top', 'bottom']
                                                   });
                },
                                               onDragEnter : function (event) {
                    var closestEdge = extractClosestEdge(event.self.data);
                    if (!closestEdge) {
                        __PS_MV_REG = [];
                        return null;
                    } else {
                        var indicator = getDropIndicator(closestEdge, '8px');
                        __PS_MV_REG = [];
                        return n.insertAdjacentElement('afterend', indicator);
                    };
                },
                                               onDragLeave : function (event) {
                    return n.nextElementSibling ? n.nextElementSibling.remove() : null;
                },
                                               onDrop : function (event) {
                    var closestEdge = extractClosestEdge(event.self.data);
                    if (n.nextElementSibling) {
                        n.nextElementSibling.remove();
                    };
                    console.log('drix', element, closestEdge, event, itemIndex, 'iid', itemIndex, n, n.getAttribute('index')['XX']);
                    __PS_MV_REG = [];
                    return fetchContact2(mode, { path : element.parentElement.getAttribute('meta-path'), sort : [parseInt(dragging.source.element.parentElement.getAttribute('index')), parseInt(n.getAttribute('index')) + (function () {
                        switch (closestEdge) {
                        case 'bottom':
                            return 0;
                        case 'top':
                            return 0;
                        };
                    })()] }, function () {
                        return htmx.trigger(element, 'reload');
                    });
                }
                                             });
            };
        });
    };
};
function getDropIndicator(edge, gap) {
    var strokeSize = 2;
    var terminalSize = 8;
    var lineOffset = 'calc(-0.5 * (' + gap + ' + ' + strokeSize + 'px))';
    var orientation = (function () {
        switch (edge) {
        case 'top':
            return 'horizontal';
        case 'bottom':
            return 'horizontal';
        case 'left':
            return 'vertical';
        case 'right':
            return 'vertical';
        };
    })();
    var element = document.createElement('div');
    var offsetToAlign = (terminalSize - strokeSize) / 2;
    element.setAttribute('data-edge', edge);
    element.classList.add('drop-marker');
    __PS_MV_REG = [];
    return element;
};
function pushForm(item, formList) {
    return formList.push(item);
};
function submitForms(formList) {
    return formList.forEach(function (form) {
        return htmx.trigger(form, 'submit');
    });
};
function ejoin(base, event) {
    if (!('undefined' === typeof(event) || 'undefined' === typeof(event.detail))) {
        var _js42 = Object.keys(event.detail);
        var _js44 = _js42.length;
        for (var _js43 = 0; _js43 < _js44; _js43 += 1) {
            var k = _js42[_js43];
            if (!(k === 'elt' || 'undefined' === typeof(event.detail[k]))) {
                base[k] = event.detail[k];
            };
        };
    };
    __PS_MV_REG = [];
    return base;
};
var derivePoints = function (ent, chart) {
    __PS_MV_REG = [];
    return [!ent.layerPoints || !ent.layerPoints[0] || 'undefined' === typeof(ent.layerPoints[0]) ? chart.toDomCoords(ent.points[0][0], ent.points[0][1]) : ent.layerPoints[0], !ent.layerPoints || !ent.layerPoints[1] || 'undefined' === typeof(ent.layerPoints[1]) ? chart.toDomCoords(ent.points[1][0], ent.points[1][1]) : ent.layerPoints[1]];
};
var drawLine = function (ctx, ent, chart, points) {
    if (ent.inFlux) {
        ctx.lineWidth = 2;
    };
    ctx.beginPath();
    var points45 = points ? points : derivePoints(ent, chart);
    var circleRadius = 5;
    ctx.moveTo(points45[0][0], points45[0][1]);
    ctx.lineTo(points45[1][0], points45[1][1]);
    ctx.closePath();
    ctx.stroke();
    if (ent.inFlux) {
        var diffs = [[points45[0][0] - points45[1][0], points45[0][1] - points45[1][1]], [points45[1][0] - points45[0][0], points45[1][1] - points45[0][1]]];
        var ri = [Math.sign(diffs[0][1]) * Math.acos(diffs[0][0] / Math.sqrt(Math.pow(diffs[0][0], 2) + Math.pow(diffs[0][1], 2))), Math.sign(diffs[1][1]) * Math.acos(diffs[1][0] / Math.sqrt(Math.pow(diffs[1][0], 2) + Math.pow(diffs[1][1], 2)))];
        ctx.strokeStyle = 'black';
        ctx.fillStyle = 'black';
        ctx.lineWidth = 0.5;
        ctx.beginPath();
        ctx.arc(points45[0][0], points45[0][1], 1, 0, Math.PI * 2, true);
        ctx.fill();
        ctx.beginPath();
        ctx.arc(points45[1][0], points45[1][1], 1, 0, Math.PI * 2, true);
        ctx.fill();
        ctx.beginPath();
        ctx.arc(points45[0][0], points45[0][1], circleRadius, -Math.PI + (ri[0] - Math.PI * 0.2), -Math.PI + (ri[0] + Math.PI * 0.2), true);
        ctx.stroke();
        ctx.beginPath();
        ctx.arc(points45[1][0], points45[1][1], circleRadius, -Math.PI + (ri[1] - Math.PI * 0.2), -Math.PI + (ri[1] + Math.PI * 0.2), true);
        ctx.stroke();
    };
    ctx.strokeStyle = 'black';
    __PS_MV_REG = [];
    return ctx.lineWidth = 1;
};
var intersectLine = function (ent, chart, point, callback) {
    console.log('ch', chart, ent);
    var linePoints = [chart.toDomCoords(ent.points[0][0], ent.points[0][1]), chart.toDomCoords(ent.points[1][0], ent.points[1][1])];
    var margin = 8;
    if (!(point[0] > linePoints[0][0] + margin && point[0] > linePoints[1][0] + margin || point[0] < linePoints[0][0] - margin && point[0] < linePoints[1][0] - margin || point[1] > linePoints[0][1] + margin && point[1] > linePoints[1][1] + margin || point[1] < linePoints[0][1] - margin && point[1] < linePoints[1][1] - margin)) {
        var ratio = (linePoints[0][1] - linePoints[1][1]) / (linePoints[1][0] - linePoints[0][0]);
        var xPos = point[0] - linePoints[0][0];
        var crossY = Math.abs(xPos * ratio - linePoints[0][1]);
        __PS_MV_REG = [];
        return 8 > Math.abs(crossY - point[1]) ? callback(ent) : null;
    };
};
if ('undefined' === typeof drawMethods) {
    var drawMethods = { line : { draw : drawLine, intersect : intersectLine },
                        retraceX : { draw : function (ctx, ent, chart) {
        var points = derivePoints(ent, chart);
        drawLine(ctx, ent, chart, points);
        ctx.strokeStyle = 'blue';
        ctx.lineWidth = 1;
        var xOrigin = points[0][0] < points[1][0] ? points[0][0] : points[1][0];
        var xInterval = points[0][0] - points[1][0];
        var _js46 = ent.ratios[0];
        var _js48 = _js46.length;
        for (var _js47 = 0; _js47 < _js48; _js47 += 1) {
            var ratio = _js46[_js47];
            var xLevel = points[0][0] < points[1][0] ? xOrigin - ratio * xInterval : xOrigin + ratio * xInterval;
            ctx.beginPath();
            ctx.moveTo(xLevel, 0);
            ctx.lineTo(xLevel, ctx.canvas.height);
            ctx.closePath();
            ctx.stroke();
        };
        ctx.strokeStyle = 'black';
        __PS_MV_REG = [];
        return ctx.lineWidth = 1.5;
    }, intersect : intersectLine },
                        retraceY : { draw : function (ctx, ent, chart) {
        var points = derivePoints(ent, chart);
        drawLine(ctx, ent, chart, points);
        ctx.strokeStyle = 'red';
        ctx.lineWidth = 1;
        var xOrigin = points[0][0] < points[1][0] ? points[0][0] : points[1][0];
        var yOrigin = points[0][1] < points[1][1] ? points[0][1] : points[1][1];
        var yInterval = points[0][1] - points[1][1];
        var _js49 = ent.ratios[1];
        var _js51 = _js49.length;
        for (var _js50 = 0; _js50 < _js51; _js50 += 1) {
            var ratio = _js49[_js50];
            var yLevel = points[0][1] < points[1][1] ? yOrigin - ratio * yInterval : yOrigin + ratio * yInterval;
            ctx.beginPath();
            ctx.moveTo(xOrigin, yLevel);
            ctx.lineTo(ctx.canvas.width, yLevel);
            ctx.closePath();
            ctx.stroke();
        };
        ctx.strokeStyle = 'black';
        __PS_MV_REG = [];
        return ctx.lineWidth = 1.5;
    }, intersect : intersectLine }
                      };
};
if ('undefined' === typeof candlestickChartEntityTemplates) {
    var candlestickChartEntityTemplates = { line : {  },
                                            retraceX : { ratios : [[0, 0.382, 0.618, 1]] },
                                            retraceY : { ratios : [[], [0, 0.236, 0.382, 0.5, 0.618, 0.764, 1]] }
                                          };
};
function commitEntities(mode) {
    __PS_MV_REG = [];
    return fetchContact(mode.system, mode.branch, { entities : mode.entities }, function (data) {
        return console.log('en', data);
    });
};
function interactorMousewheel(mode) {
    return function (event, chart, context) {
        if (event.shiftKey) {
            var priceRange = chart.yAxisRange();
            var priceInterval = priceRange[0] - priceRange[1];
            var zoomInterval = 0.05 * priceInterval;
            var wheelDelta = 0 < event.deltaY ? 1 : -1;
            return chart.updateOptions({ dateWindow : chart.xAxisRange(), valueRange : [1 === wheelDelta ? priceRange[0] - zoomInterval : priceRange[0] + zoomInterval, priceRange[1]] });
        } else {
            var timeRange = chart.xAxisRange();
            var timeInterval = timeRange[1] - timeRange[0];
            var zoomInterval52 = 0.05 * timeInterval;
            var wheelDelta53 = 0 < event.deltaY ? 1 : -1;
            return chart.updateOptions({ dateWindow : [1 === wheelDelta53 ? timeRange[0] - zoomInterval52 : timeRange[0] + zoomInterval52, timeRange[1]], valueRange : chart.yAxisRange() });
        };
    };
};
function interactorMousedown(mode) {
    return function (event, g, context) {
        console.log('aaa', g);
        mode.mousedown = true;
        var canvasCoords = [event.layerX, event.layerY];
        var domCoords = g.eventToDomCoords(event);
        var entitiesCount = mode.entities.length;
        switch (mode.interaction) {
        case 'select':
            var entityClicked = false;
            var _js54 = entitiesCount - 1;
            for (var entix = 0; entix <= _js54; entix += 1) {
                self.drawMethods.line.intersect(mode.entities[entix], mode.chart, domCoords, function (ent) {
                    entityClicked = true;
                    ent.layerPoints = [g.toDomCoords(ent.points[0][0], ent.points[0][1]), g.toDomCoords(ent.points[1][0], ent.points[1][1])];
                    if (ent.inFlux) {
                        if (8 > Math.abs(ent.layerPoints[0][0] - domCoords[0]) && 8 > Math.abs(ent.layerPoints[0][1] - domCoords[1])) {
                            ent.pointsInFlux.push(0);
                        } else {
                            if (8 > Math.abs(ent.layerPoints[1][0] - domCoords[0]) && 8 > Math.abs(ent.layerPoints[1][1] - domCoords[1])) {
                                ent.pointsInFlux.push(1);
                            };
                        };
                    };
                    if (!ent.inFlux) {
                        ent.inFlux = true;
                        __PS_MV_REG = [];
                        return mode.entitiesInFlux.push(ent);
                    } else {
                        __PS_MV_REG = [];
                        return null;
                    };
                });
            };
            if (!entityClicked) {
                mode.entitiesInFlux = [];
                var _js55 = mode.entities;
                var _js57 = _js55.length;
                for (var _js56 = 0; _js56 < _js57; _js56 += 1) {
                    var ent = _js55[_js56];
                    ent.inFlux = false;
                };
            };
            mode.movingFrom = canvasCoords;
            if (0 === mode.entitiesInFlux.length) {
                context.initializeMouseDown(event, g, context);
                return window.Dygraph.startPan(event, g, context);
            } else {
                return g.drawGraph_();
            };
        case 'draw':
            var timeInterval = g.rawData_[1][0] - g.rawData_[0][0];
            var dataPos = g.toDataCoords(domCoords[0], domCoords[1]);
            var remainder = (dataPos[0] % timeInterval + timeInterval) % timeInterval;
            if (0 !== remainder) {
                dataPos[0] -= remainder;
            };
            var base = { type : mode.drawEntity,
                         inFlux : true,
                         points : [[dataPos[0], dataPos[1]], [dataPos[0], dataPos[1]]],
                         pointsInFlux : []
                       };
            var newEntity = Object.assign({  }, base, candlestickChartEntityTemplates[mode.drawEntity]);
            mode.entities.push(newEntity);
            mode.entitiesInFlux.push(newEntity);
            return mode.activeEntity = newEntity;
        };
    };
};
function interactorMouseup(mode) {
    return function (event, chart, context) {
        console.log('bbb', mode.entities);
        var self = this;
        mode.mousedown = false;
        switch (mode.interaction) {
        case 'select':
            if (context.isPanning) {
                window.Dygraph.endPan(event, chart, context);
                return chart.drawGraph_();
            } else {
                var _js58 = mode.entities;
                var _js60 = _js58.length;
                for (var _js59 = 0; _js59 < _js60; _js59 += 1) {
                    var ent = _js58[_js59];
                    console.log('ee', ent);
                    if (ent.inFlux) {
                        ent.points[0] = chart.toDataCoords(ent.layerPoints[0][0], ent.layerPoints[0][1]);
                        ent.points[1] = chart.toDataCoords(ent.layerPoints[1][0], ent.layerPoints[1][1]);
                        ent.layerPoints = null;
                        ent.pointsInFlux = [];
                    };
                };
                commitEntities(mode);
                __PS_MV_REG = [];
                return chart.drawGraph_();
            };
        case 'draw':
            mode.activeEntity = null;
            mode.interaction = 'select';
            commitEntities(mode);
            __PS_MV_REG = [];
            return chart.drawGraph_();
        };
    };
};
function interactorMousemove(mode) {
    return function (event, chart, context) {
        var self = this;
        var tempCanvas = chart.canvas_ctx_;
        if (mode.mousedown) {
            switch (mode.interaction) {
            case 'select':
                if (0 === mode.entitiesInFlux.length) {
                    return context.isPanning ? window.Dygraph.movePan(event, chart, context) : chart.drawGraph_();
                } else {
                    var movingFrom61 = mode.movingFrom;
                    tempCanvas.clearRect(0, 0, chart.canvas_.width, chart.canvas_.height);
                    var _js62 = mode.entitiesInFlux;
                    var _js64 = _js62.length;
                    for (var _js63 = 0; _js63 < _js64; _js63 += 1) {
                        var ent = _js62[_js63];
                        if (0 === ent.pointsInFlux.length) {
                            ent.layerPoints = [[ent.layerPoints[0][0] - (movingFrom61[0] - event.layerX), ent.layerPoints[0][1] - (movingFrom61[1] - event.layerY)], [ent.layerPoints[1][0] - (movingFrom61[0] - event.layerX), ent.layerPoints[1][1] - (movingFrom61[1] - event.layerY)]];
                        } else {
                            var timeInterval = chart.rawData_[1][0] - chart.rawData_[0][0];
                            var domCoords = chart.eventToDomCoords(event);
                            var dataPos = chart.toDataCoords(domCoords[0], domCoords[1]);
                            var remainder = (dataPos[0] % timeInterval + timeInterval) % timeInterval;
                            if (0 !== remainder) {
                                dataPos[0] -= remainder;
                            };
                            var columnValue = self.state.contentIndex[dataPos[0]];
                            var _js65 = ent.pointsInFlux;
                            var _js67 = _js65.length;
                            for (var _js66 = 0; _js66 < _js67; _js66 += 1) {
                                var point = _js65[_js66];
                                ent['layerPoints'][point] = [event.layerX, event.layerY];
                                timeCoord = chart.toDomYCoord(columnValue[1]);
                                if (8 > Math.abs(timeCoord - ent['layerPoints'][point][1])) {
                                    console.log('Snapped!');
                                    ent['layerPoints'][point][1] = timeCoord;
                                };
                            };
                        };
                        mode.movingFrom = [event.layerX, event.layerY];
                        drawMethods[ent.type]['draw'](tempCanvas, ent, chart);
                    };
                    __PS_MV_REG = [];
                    return;
                };
            case 'draw':
                var timeInterval65 = chart.rawData_[1][0] - chart.rawData_[0][0];
                var domCoords66 = chart.eventToDomCoords(event);
                var dataPos67 = chart.toDataCoords(domCoords66[0], domCoords66[1]);
                var remainder68 = (dataPos67[0] % timeInterval65 + timeInterval65) % timeInterval65;
                var ent69 = mode.activeEntity;
                if (0 !== remainder68) {
                    dataPos67[0] -= remainder68;
                };
                ent69.points[1] = [dataPos67[0], dataPos67[1]];
                tempCanvas.clearRect(0, 0, chart.canvas_.width, chart.canvas_.height);
                __PS_MV_REG = [];
                return drawMethods[ent69.type]['draw'](tempCanvas, ent69, chart);
            };
        };
    };
};
function getCandlePlotter(mode) {
    return function (e) {
        if (0 !== e.seriesIndex) {
            var self = this;
            var setCount = e.seriesCount;
            console.log('ss', setCount);
            if (4 !== setCount) {
                return console.log('Error: Exactly 4 prices each point must be provided for the candle chart.');
            } else {
                var prices = [];
                var sets = e.allSeriesPoints;
                var area = e.plotArea;
                var ctx = e.drawingContext;
                var candleMaxSpacing = 3;
                var barCount = (range = e.dygraph.xAxisRange(), counting = false, length = 0, ((function () {
                    var _js70 = sets[0];
                    var _js72 = _js70.length;
                    for (var _js71 = 0; _js71 < _js72; _js71 += 1) {
                        var point = _js70[_js71];
                        if (!counting && point.xval > range[0]) {
                            counting = true;
                        };
                        if (counting && point.xval > Math.floor(range[1])) {
                            counting = false;
                        };
                        if (counting) {
                            length += 1;
                        };
                    };
                })(), length));
                var viewWidth = e.dygraph.getArea().w;
                var barWidth = Math.max(1, 0.7 * (viewWidth / barCount));
                var upFillStyle = 'rgba(38,139,210,1.0)';
                var upStrokeStyle = 2 < barWidth ? 'rgba(38,139,210,1.0)' : 'rgba(38,139,210,0.6)';
                var downFillStyle = 'rgba(220,50,47,1.0)';
                var downStrokeStyle = 2 < barWidth ? 'rgba(220,50,47,1.0)' : 'rgba(220,50,47,0.6)';
                console.log('sets', sets);
                ctx.lineWidth = 0.6;
                var _js73 = sets[0].length - 1;
                for (var p = 0; p <= _js73; p += 1) {
                    var price = { open : sets[0][p]['yval'],
                                  close : sets[1][p]['yval'],
                                  high : sets[2][p]['yval'],
                                  low : sets[3][p]['yval'],
                                  openY : sets[0][p]['y'],
                                  closeY : sets[1][p]['y'],
                                  highY : sets[2][p]['y'],
                                  lowY : sets[3][p]['y']
                                };
                    var topY = area.y + area.h * price.highY;
                    var bottomY = area.y + area.h * price.lowY;
                    var centerX = area.x + area.w * sets[0][p]['x'];
                    var bodyY = null;
                    var bodyHeight = null;
                    prices.push(price);
                    ctx.beginPath();
                    ctx.moveTo(centerX, topY);
                    ctx.lineTo(centerX, bottomY);
                    ctx.closePath();
                    if (price.open > price.close) {
                        ctx.fillStyle = downFillStyle;
                        ctx.strokeStyle = downStrokeStyle;
                        bodyY = area.y + area.h * price.openY;
                    } else {
                        ctx.fillStyle = upFillStyle;
                        ctx.strokeStyle = upStrokeStyle;
                        bodyY = area.y + area.h * price.closeY;
                    };
                    ctx.stroke();
                    bodyHeight = area.h * Math.abs(price.openY - price.closeY);
                    ctx.fillRect(centerX - barWidth / 2, bodyY, barWidth, bodyHeight);
                };
                ctx.strokeStyle = 'black';
                ctx.lineWidth = 1.5;
                console.log('ents', mode.entities);
                var _js74 = mode.entities;
                var _js76 = _js74.length;
                for (var _js75 = 0; _js75 < _js76; _js75 += 1) {
                    var ent = _js74[_js75];
                    if (!(mode.mousedown && ent.inFlux)) {
                        drawMethods[ent.type]['draw'](ctx, ent, mode.chart);
                    };
                };
            };
        };
    };
};