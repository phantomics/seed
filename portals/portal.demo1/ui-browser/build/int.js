window.seedData = {  };
window.seedElements = {  };
function fetchContact2(element, context, input, event) {
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
                return htmx.trigger(seedElements[item], 'reload');
            });
        };
        return data;
    }).then('function' === typeof(event) ? event : function (data) {
        console.log('aaa', data);
        return htmx.trigger(element, event.next);
    });
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
            var _js25 = types[option];
            var _js27 = _js25.length;
            for (var _js26 = 0; _js26 < _js27; _js26 += 1) {
                var item = _js25[_js26];
                htmx.trigger(item, body);
            };
            __PS_MV_REG = [];
            return;
        };
    };
};
function mcodeHandlerOnDrag(element, mode) {
    return function (dragging) {
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
                    return fetchContact2(element, mode, { path : element.parentElement.getAttribute('meta-path'), sort : [parseInt(dragging.source.element.parentElement.getAttribute('index')), parseInt(n.getAttribute('index')) + (function () {
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
        var _js28 = Object.keys(event.detail);
        var _js30 = _js28.length;
        for (var _js29 = 0; _js29 < _js30; _js29 += 1) {
            var k = _js28[_js29];
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
    var points31 = points ? points : derivePoints(ent, chart);
    var circleRadius = 5;
    ctx.moveTo(points31[0][0], points31[0][1]);
    ctx.lineTo(points31[1][0], points31[1][1]);
    ctx.closePath();
    ctx.stroke();
    if (ent.inFlux) {
        var diffs = [[points31[0][0] - points31[1][0], points31[0][1] - points31[1][1]], [points31[1][0] - points31[0][0], points31[1][1] - points31[0][1]]];
        var ri = [Math.sign(diffs[0][1]) * Math.acos(diffs[0][0] / Math.sqrt(Math.pow(diffs[0][0], 2) + Math.pow(diffs[0][1], 2))), Math.sign(diffs[1][1]) * Math.acos(diffs[1][0] / Math.sqrt(Math.pow(diffs[1][0], 2) + Math.pow(diffs[1][1], 2)))];
        ctx.strokeStyle = 'black';
        ctx.fillStyle = 'black';
        ctx.lineWidth = 0.5;
        ctx.beginPath();
        ctx.arc(points31[0][0], points31[0][1], 1, 0, Math.PI * 2, true);
        ctx.fill();
        ctx.beginPath();
        ctx.arc(points31[1][0], points31[1][1], 1, 0, Math.PI * 2, true);
        ctx.fill();
        ctx.beginPath();
        ctx.arc(points31[0][0], points31[0][1], circleRadius, -Math.PI + (ri[0] - Math.PI * 0.2), -Math.PI + (ri[0] + Math.PI * 0.2), true);
        ctx.stroke();
        ctx.beginPath();
        ctx.arc(points31[1][0], points31[1][1], circleRadius, -Math.PI + (ri[1] - Math.PI * 0.2), -Math.PI + (ri[1] + Math.PI * 0.2), true);
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
        var _js32 = ent.ratios[0];
        var _js34 = _js32.length;
        for (var _js33 = 0; _js33 < _js34; _js33 += 1) {
            var ratio = _js32[_js33];
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
        var _js35 = ent.ratios[1];
        var _js37 = _js35.length;
        for (var _js36 = 0; _js36 < _js37; _js36 += 1) {
            var ratio = _js35[_js36];
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
    return fetchContact2(null, mode, { entities : mode.entities }, function (data) {
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
            var zoomInterval38 = 0.05 * timeInterval;
            var wheelDelta39 = 0 < event.deltaY ? 1 : -1;
            return chart.updateOptions({ dateWindow : [1 === wheelDelta39 ? timeRange[0] - zoomInterval38 : timeRange[0] + zoomInterval38, timeRange[1]], valueRange : chart.yAxisRange() });
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
            var _js40 = entitiesCount - 1;
            for (var entix = 0; entix <= _js40; entix += 1) {
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
                var _js41 = mode.entities;
                var _js43 = _js41.length;
                for (var _js42 = 0; _js42 < _js43; _js42 += 1) {
                    var ent = _js41[_js42];
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
                var _js44 = mode.entities;
                var _js46 = _js44.length;
                for (var _js45 = 0; _js45 < _js46; _js45 += 1) {
                    var ent = _js44[_js45];
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
                    var movingFrom47 = mode.movingFrom;
                    tempCanvas.clearRect(0, 0, chart.canvas_.width, chart.canvas_.height);
                    var _js48 = mode.entitiesInFlux;
                    var _js50 = _js48.length;
                    for (var _js49 = 0; _js49 < _js50; _js49 += 1) {
                        var ent = _js48[_js49];
                        if (0 === ent.pointsInFlux.length) {
                            ent.layerPoints = [[ent.layerPoints[0][0] - (movingFrom47[0] - event.layerX), ent.layerPoints[0][1] - (movingFrom47[1] - event.layerY)], [ent.layerPoints[1][0] - (movingFrom47[0] - event.layerX), ent.layerPoints[1][1] - (movingFrom47[1] - event.layerY)]];
                        } else {
                            var timeInterval = chart.rawData_[1][0] - chart.rawData_[0][0];
                            var domCoords = chart.eventToDomCoords(event);
                            var dataPos = chart.toDataCoords(domCoords[0], domCoords[1]);
                            var remainder = (dataPos[0] % timeInterval + timeInterval) % timeInterval;
                            if (0 !== remainder) {
                                dataPos[0] -= remainder;
                            };
                            var columnValue = self.state.contentIndex[dataPos[0]];
                            var _js51 = ent.pointsInFlux;
                            var _js53 = _js51.length;
                            for (var _js52 = 0; _js52 < _js53; _js52 += 1) {
                                var point = _js51[_js52];
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
                var timeInterval51 = chart.rawData_[1][0] - chart.rawData_[0][0];
                var domCoords52 = chart.eventToDomCoords(event);
                var dataPos53 = chart.toDataCoords(domCoords52[0], domCoords52[1]);
                var remainder54 = (dataPos53[0] % timeInterval51 + timeInterval51) % timeInterval51;
                var ent55 = mode.activeEntity;
                if (0 !== remainder54) {
                    dataPos53[0] -= remainder54;
                };
                ent55.points[1] = [dataPos53[0], dataPos53[1]];
                tempCanvas.clearRect(0, 0, chart.canvas_.width, chart.canvas_.height);
                __PS_MV_REG = [];
                return drawMethods[ent55.type]['draw'](tempCanvas, ent55, chart);
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
                    var _js56 = sets[0];
                    var _js58 = _js56.length;
                    for (var _js57 = 0; _js57 < _js58; _js57 += 1) {
                        var point = _js56[_js57];
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
                var _js59 = sets[0].length - 1;
                for (var p = 0; p <= _js59; p += 1) {
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
                var _js60 = mode.entities;
                var _js62 = _js60.length;
                for (var _js61 = 0; _js61 < _js62; _js61 += 1) {
                    var ent = _js60[_js61];
                    if (!(mode.mousedown && ent.inFlux)) {
                        drawMethods[ent.type]['draw'](ctx, ent, mode.chart);
                    };
                };
            };
        };
    };
};