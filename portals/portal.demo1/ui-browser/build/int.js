window.seedData = {  };
window.seedElements = {  };
function fetchContact(system, branch, input, handler) {
    __PS_MV_REG = [];
    return fetch('/contact/', { method : 'POST',
                                body : JSON.stringify({ system : system,
                                                        branch : branch,
                                                        input : input
                                                      }),
                                headers : { 'Content-type' : 'application/json; charset=UTF-8' }
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
function fetchContact2(context, element, input) {
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
        return htmx.trigger(element, 'refresh');
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
            var _js1641 = types[option];
            var _js1643 = _js1641.length;
            for (var _js1642 = 0; _js1642 < _js1643; _js1642 += 1) {
                var item = _js1641[_js1642];
                htmx.trigger(item, body);
            };
            __PS_MV_REG = [];
            return;
        };
    };
};
function mcodeHandlerOnDrag(element) {
    return function () {
        var osvector = [];
        var ix = 0;
        console.log('drag-start', element, element.childNodes.length, element.childNodes);
        Array.from(element.childNodes).filter(function (item) {
            return (item instanceof HTMLElement);
        }).map(function (n, ia) {
            console.log('ii', ix);
            if (3 !== n.nodeType) {
                var bounds = n.getBoundingClientRect();
                console.log('bb', ix, bounds, osvector, bounds.top);
                osvector = osvector.concat(0 === osvector.length ? bounds.top : bounds.top - Math.floor(0.25 * osvector[osvector.length - 1]));
                dropTargetForElements({ element : n,
                                        onDrag : function () {
                    return console.log('abc', ia);
                },
                                        getData : function (data) {
                    console.log('dd', data);
                    __PS_MV_REG = [];
                    return attachClosestEdge({  }, { element : n,
                                                     input : data.input,
                                                     allowedEdges : ['top', 'bottom']
                                                   });
                },
                                        onDrop : function (event) {
                    var closestEdge = extractClosestEdge(event.self.data);
                    __PS_MV_REG = [];
                    return console.log('drix', closestEdge, event, ia);
                }
                                      });
            };
            __PS_MV_REG = [];
            return ++ix;
        });
        return console.log('oss', osvector);
    };
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
        var _js1644 = Object.keys(event.detail);
        var _js1646 = _js1644.length;
        for (var _js1645 = 0; _js1645 < _js1646; _js1645 += 1) {
            var k = _js1644[_js1645];
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
    var points1647 = points ? points : derivePoints(ent, chart);
    var circleRadius = 5;
    ctx.moveTo(points1647[0][0], points1647[0][1]);
    ctx.lineTo(points1647[1][0], points1647[1][1]);
    ctx.closePath();
    ctx.stroke();
    if (ent.inFlux) {
        var diffs = [[points1647[0][0] - points1647[1][0], points1647[0][1] - points1647[1][1]], [points1647[1][0] - points1647[0][0], points1647[1][1] - points1647[0][1]]];
        var ri = [Math.sign(diffs[0][1]) * Math.acos(diffs[0][0] / Math.sqrt(Math.pow(diffs[0][0], 2) + Math.pow(diffs[0][1], 2))), Math.sign(diffs[1][1]) * Math.acos(diffs[1][0] / Math.sqrt(Math.pow(diffs[1][0], 2) + Math.pow(diffs[1][1], 2)))];
        ctx.strokeStyle = 'black';
        ctx.fillStyle = 'black';
        ctx.lineWidth = 0.5;
        ctx.beginPath();
        ctx.arc(points1647[0][0], points1647[0][1], 1, 0, Math.PI * 2, true);
        ctx.fill();
        ctx.beginPath();
        ctx.arc(points1647[1][0], points1647[1][1], 1, 0, Math.PI * 2, true);
        ctx.fill();
        ctx.beginPath();
        ctx.arc(points1647[0][0], points1647[0][1], circleRadius, -Math.PI + (ri[0] - Math.PI * 0.2), -Math.PI + (ri[0] + Math.PI * 0.2), true);
        ctx.stroke();
        ctx.beginPath();
        ctx.arc(points1647[1][0], points1647[1][1], circleRadius, -Math.PI + (ri[1] - Math.PI * 0.2), -Math.PI + (ri[1] + Math.PI * 0.2), true);
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
        var _js1648 = ent.ratios[0];
        var _js1650 = _js1648.length;
        for (var _js1649 = 0; _js1649 < _js1650; _js1649 += 1) {
            var ratio = _js1648[_js1649];
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
        var _js1651 = ent.ratios[1];
        var _js1653 = _js1651.length;
        for (var _js1652 = 0; _js1652 < _js1653; _js1652 += 1) {
            var ratio = _js1651[_js1652];
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
            var zoomInterval1654 = 0.05 * timeInterval;
            var wheelDelta1655 = 0 < event.deltaY ? 1 : -1;
            return chart.updateOptions({ dateWindow : [1 === wheelDelta1655 ? timeRange[0] - zoomInterval1654 : timeRange[0] + zoomInterval1654, timeRange[1]], valueRange : chart.yAxisRange() });
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
            var _js1656 = entitiesCount - 1;
            for (var entix = 0; entix <= _js1656; entix += 1) {
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
                var _js1657 = mode.entities;
                var _js1659 = _js1657.length;
                for (var _js1658 = 0; _js1658 < _js1659; _js1658 += 1) {
                    var ent = _js1657[_js1658];
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
                var _js1660 = mode.entities;
                var _js1662 = _js1660.length;
                for (var _js1661 = 0; _js1661 < _js1662; _js1661 += 1) {
                    var ent = _js1660[_js1661];
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
                    var movingFrom1663 = mode.movingFrom;
                    tempCanvas.clearRect(0, 0, chart.canvas_.width, chart.canvas_.height);
                    var _js1664 = mode.entitiesInFlux;
                    var _js1666 = _js1664.length;
                    for (var _js1665 = 0; _js1665 < _js1666; _js1665 += 1) {
                        var ent = _js1664[_js1665];
                        if (0 === ent.pointsInFlux.length) {
                            ent.layerPoints = [[ent.layerPoints[0][0] - (movingFrom1663[0] - event.layerX), ent.layerPoints[0][1] - (movingFrom1663[1] - event.layerY)], [ent.layerPoints[1][0] - (movingFrom1663[0] - event.layerX), ent.layerPoints[1][1] - (movingFrom1663[1] - event.layerY)]];
                        } else {
                            var timeInterval = chart.rawData_[1][0] - chart.rawData_[0][0];
                            var domCoords = chart.eventToDomCoords(event);
                            var dataPos = chart.toDataCoords(domCoords[0], domCoords[1]);
                            var remainder = (dataPos[0] % timeInterval + timeInterval) % timeInterval;
                            if (0 !== remainder) {
                                dataPos[0] -= remainder;
                            };
                            var columnValue = self.state.contentIndex[dataPos[0]];
                            var _js1667 = ent.pointsInFlux;
                            var _js1669 = _js1667.length;
                            for (var _js1668 = 0; _js1668 < _js1669; _js1668 += 1) {
                                var point = _js1667[_js1668];
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
                var timeInterval1667 = chart.rawData_[1][0] - chart.rawData_[0][0];
                var domCoords1668 = chart.eventToDomCoords(event);
                var dataPos1669 = chart.toDataCoords(domCoords1668[0], domCoords1668[1]);
                var remainder1670 = (dataPos1669[0] % timeInterval1667 + timeInterval1667) % timeInterval1667;
                var ent1671 = mode.activeEntity;
                if (0 !== remainder1670) {
                    dataPos1669[0] -= remainder1670;
                };
                ent1671.points[1] = [dataPos1669[0], dataPos1669[1]];
                tempCanvas.clearRect(0, 0, chart.canvas_.width, chart.canvas_.height);
                __PS_MV_REG = [];
                return drawMethods[ent1671.type]['draw'](tempCanvas, ent1671, chart);
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
                    var _js1672 = sets[0];
                    var _js1674 = _js1672.length;
                    for (var _js1673 = 0; _js1673 < _js1674; _js1673 += 1) {
                        var point = _js1672[_js1673];
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
                var _js1675 = sets[0].length - 1;
                for (var p = 0; p <= _js1675; p += 1) {
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
                var _js1676 = mode.entities;
                var _js1678 = _js1676.length;
                for (var _js1677 = 0; _js1677 < _js1678; _js1677 += 1) {
                    var ent = _js1676[_js1677];
                    if (!(mode.mousedown && ent.inFlux)) {
                        drawMethods[ent.type]['draw'](ctx, ent, mode.chart);
                    };
                };
            };
        };
    };
};
function draggableProvision(element, inSeries) {
    var handleContainer = null;
    var handle = null;
    var onStart = function () {
        console.log('drag-start');
        return Array.from(element.childNodes).map(function (n, ix) {
            __PS_MV_REG = [];
            return dropTargetForElements({ element : element,
                                           onDrag : function () {
                return console.log('a', ix);
            },
                                           onDrop : function (self, source) {
                return console.log('drii', self, ix);
            }
                                         });
        });
    };
    var _js1679 = element.childNodes;
    var _js1681 = _js1679.length;
    for (var _js1680 = 0; _js1680 < _js1681; _js1680 += 1) {
        var n = _js1679[_js1680];
        if (n.className === 'field has-addons') {
            handleContainer = n;
            break;
        };
    };
    console.log(element.childNodes);
    var _js1682 = handleContainer.childNodes;
    var _js1684 = _js1682.length;
    for (var _js1683 = 0; _js1683 < _js1684; _js1683 += 1) {
        var n1685 = _js1682[_js1683];
        if (n1685.className === 'control drag-handle') {
            handle = n1685;
            break;
        };
    };
    __PS_MV_REG = [];
    return 'undefined' !== typeof(inSeries) ? console.log(draggable({ element : element,
                                                                 dragHandle : handle,
                                                                 onDragStart : mcodeHandlerOnDrag(inSeries)
                                                               })) : null;
};