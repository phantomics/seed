window.seedData = {  };
function fetchContact(system, branch, input, handler) {
    __PS_MV_REG = [];
    return fetch('/contact/', { method : 'POST',
                                body : JSON.stringify({ portal : system,
                                                        branch : branch,
                                                        input : input
                                                      }),
                                headers : { 'Content-type' : 'application/json; charset=UTF-8' }
                              }).then(function (response) {
        return response.json();
    }).then(handler);
};
if ('undefined' === typeof d3Effects) {
    var d3Effects = { textLabel : function (inNode, params) {
        return inNode.append('text').attr('dy', '0.31em').attr('x', 58).attr('text-anchor', 'start').text(function (d) {
            console.log('td', d);
            return d.data.title;
        }).clone(true).lower().attr('stroke-linejoin', 'round').attr('stroke-width', 3).attr('stroke', 'white').attr('fill', function (d) {
            return null;
        });
    },
                      expandControl : function (inNode, params) {
        var mainRadius = 48;
        var innerRadius = 6;
        var outerRadius = 8;
        var crossbarLength = 8;
        var crossbarBreadth = 2;
        var group = inNode.append('svg:g').attr('class', 'expand-control');
        group.append('svg:circle').attr('class', 'button-backing').attr('cy', 0).attr('cx', mainRadius).attr('r', outerRadius);
        group.append('svg:circle').attr('class', 'button-circle').attr('cy', 0).attr('cx', mainRadius).attr('r', innerRadius);
        return group.append('svg:rect').attr('x', mainRadius - crossbarLength / 2).attr('y', crossbarBreadth / -2).attr('height', crossbarBreadth).attr('width', crossbarLength);
    },
                      circleIcon : function (inNode, params) {
        var mainRadius = 16;
        var iconGroup = inNode.append('svg:g').attr('class', 'circle-glyph');
        iconGroup.append('svg:circle').attr('class', 'outer-circle').attr('cy', 0).attr('cx', mainRadius).attr('r', mainRadius);
        return iconGroup.append('svg:circle').attr('class', 'inner-circle').attr('cy', 0).attr('cx', mainRadius).attr('r', mainRadius - 4);
    }
                    };
};
function d3Build(fetcher) {
    return function (data) {
        console.log('dat', data);
        var width = 600;
        var height = 600;
        var svg = d3.create('svg').attr('class', 'd3view-graph-foldout').attr('width', width).attr('height', height);
        var barHeight = 36;
        var marginTop = 10;
        var marginRight = 10;
        var marginLeft = 10;
        var marginBottom = 10;
        var dx = 10;
        var dy = 10;
        var root = d3.hierarchy(data);
        var layoutTree = d3.tree().nodeSize([20, 20]);
        var diagonal = d3.linkHorizontal().x(function (d) {
            return d.y;
        }).y(function (d) {
            return d.x;
        });
        var diag = d3.linkHorizontal().x(function (d) {
            return d.y;
        }).y(function (d) {
            return d.x;
        });
        var glink = svg.append('g').attr('fill', 'none').attr('stroke', '#555').attr('stroke-opacity', 0.4).attr('stroke-width', 1.5);
        var gnode = svg.append('g').attr('cursor', 'pointer').attr('pointer-events', 'all');
        function update(event, source) {
            var o;
            var duration = 500;
            var nodes = root.descendants().reverse();
            var links9 = root.links();
            var ix = 0;
            var left = null;
            var right = null;
            var transition = null;
            var node = null;
            var nodeEnter = null;
            var nodeUpdate = null;
            var nodeExit = null;
            var link = null;
            var linkEnter = null;
            console.log('rt', root);
            layoutTree(root);
            left = root;
            right = root;
            function dftraverse(list) {
                return list.forEach(function (d, i) {
                    if ('null' !== typeof d.index) {
                        d.index = ix;
                        ++ix;
                    };
                    __PS_MV_REG = [];
                    return d.children ? dftraverse(d.children) : null;
                });
            };
            dftraverse(nodes);
            console.log('rd', root.descendants());
            root.descendants().forEach(function (n, i) {
                return n.x = barHeight * (n.index - 1);
            });
            transition = svg.transition().duration(duration).attr('height', height).attr('viewBox', [+marginLeft, left.x - marginTop, width, height]).tween('resize', window.ResizeObserver ? null : function () {
                return function () {
                    return svg.dispatch('toggle');
                };
            });
            node = gnode.selectAll('g.node').data(nodes, function (d) {
                return d.id;
            });
            nodeEnter = node.enter().append('g').attr('class', 'node').attr('transform', function (d) {
                return 'translate(' + source.y0 + ',' + source.x0 + ')';
            }).attr('fill-opacity', 0).attr('stroke-opacity', 0).attr('display', function (d) {
                return 0 === d.id ? 'none' : 'relative';
            }).on('click', function (thisEvent, d) {
                console.log('ind', d.data, d.data.to);
                if ((d.data.to || 0 === d.data.to) && !(d.children || d._children)) {
                    return fetcher(function (data) {
                        var ins = d3.hierarchy(data);
                        var all = root.descendants();
                        var ccount = all.length;
                        if (0 === d.height) {
                            all.forEach(function (item) {
                                return item.height = 2 + item.height;
                            });
                        };
                        console.log('dt', data);
                        ins.parent = d;
                        ins.depth = d.depth + 1;
                        ins.id = ccount;
                        ins.children[0]['depth'] = 2 + d.depth;
                        ins.children[0]['id'] = 2 + ccount;
                        ins.children[0]['children'] = null;
                        ins._children = ins.children;
                        ins.children = null;
                        d.children = [ins];
                        d._children = null;
                        layoutTree(root);
                        console.log('retd', typeof data, d, ins, data);
                        __PS_MV_REG = [];
                        return update(thisEvent, root);
                    }, { index : d.data.to });
                } else {
                    console.log('cl', d);
                    d.children = d.children ? null : d._children;
                    __PS_MV_REG = [];
                    return update(thisEvent, d);
                };
            });
            Object.keys(window.d3Effects).forEach(function (e, i) {
                return window.d3Effects[e](nodeEnter, {  });
            });
            nodeUpdate = node.merge(nodeEnter).transition(transition).attr('transform', function (d) {
                return 'translate(' + d.y + ',' + d.x + ')';
            }).attr('fill-opacity', 1).attr('stroke-opacity', 1);
            nodeExit = node.exit().transition(transition).remove().attr('transform', function (d) {
                console.log('aa', d, d.y, d.x);
                return 'translate(' + d.y + ',' + d.x + ')';
            }).attr('fill-opacity', 0).attr('stroke-opacity', 0);
            link = glink.selectAll('path').data(links9, function (d) {
                return d.target.id;
            });
            linkEnter = (o = { x : source.x0, y : source.y0 }, link.enter().append('path').attr('d', diagonal({ source : o, target : o })).attr('class', 'c' + source.id).attr('display', function (d) {
                console.log('dd', d);
                return 1 === d.target.depth ? 'none' : 'relative';
            }));
            link.merge(linkEnter).transition(transition).attr('d', diagonal);
            link.exit().transition(transition).remove().attr('d', function (d) {
                var o = { x : source.x, y : source.y };
                __PS_MV_REG = [];
                return diagonal({ source : o, target : o });
            });
            __PS_MV_REG = [];
            return root.eachBefore(function (d) {
                d.x0 = d.x;
                return d.y0 = d.y;
            });
        };
        root.x0 = dy / 2;
        root.y0 = 0;
        root.descendants().forEach(function (d, i) {
            d.id = i;
            d._children = d.children;
            return d.depth && 7 !== d.data.title.length ? (d.children = null) : null;
        });
        update(null, root);
        __PS_MV_REG = [];
        return document.getElementById('d3-container').append(svg.node());
    };
};