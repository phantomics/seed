#!/usr/bin/env node

// Dorai Sitaram
// last modified 2020-11-14

// this script takes lines of Lisp or Scheme code from its
// stdin and produces an indented version thereof on its
// stdout

var fs = require('fs');
var events = require('events');

var tbd = new events.EventEmitter();
var lispKeywords = {};

function numLeadingSpaces(s) {
  if (s.match(/^\s*$/)) {
    return 0;
  } else {
    s = s.replace(/^(\s*).*/, '$1');
    s = s.replace(/\t/g, '        ');
    return s.length;
  }
}

function stringTrimBlanks(s) {
  s = s.replace(/^\s*/, '');
  s = s.replace(/\s*$/, '');
  return s;
}

function literalTokenP(s) {
  return !!s.match(/^[0-9#"]/);
}

function getLispIndentNumber(s) {
  var n;
  s = s.toLowerCase();
  if (n = lispKeywords[s]) {
    return n;
  } else if (s.match(/^def/)) {
    return 0;
  } else {
    return -1;
  }
}

function pastNextAtom(s, i) {
  var n = s.length;
  while (true) {
    if (i >= n) {
      return n;
    } 
    var c = s[i];
    if (c === '\\') {
      i++; i++;
    } else if (c.match(/[ \t\(\)\[\]"'`,;]/)) {
      return i;
    } else {
      i++;
    }
  }
}

function calcSubindent(s, i) {
  var n = s.length;
  var j = pastNextAtom(s, i);
  var deltaIndent = 0;
  var lispIndentNum = -1;
  if (j === i) {
    ;
  } else {
    var w = s.substring(i, j);
    if (i >= 2 && s[i-2].match(/['`]/)) {
      ;
    } else {
      var lispIndentNum = getLispIndentNumber(w);
      if (lispIndentNum == -2) {
        ;
      } else if (lispIndentNum == -1) {
        if (j < n) {
          deltaIndent = j - i + 1
        } else {
          deltaIndent = 1
        }
      } else {
        deltaIndent = 1
      }
    }
  }
  return {
    deltaIndent: deltaIndent,
    lispIndentNum: lispIndentNum,
    nextTokenIndex: j
  }
}

var defaultLeftI = -1;
var leftI = 0;
var parenStack = [];
var insideStringP = false;

function indentLine(currLine) {
  var leadingSpaces = numLeadingSpaces(currLine);
  var currLeftI;
  if (insideStringP) {
    currLeftI = leadingSpaces;
  } else if (parenStack.length === 0) {
    if (defaultLeftI === -1) { defaultLeftI = leadingSpaces; }
    leftI = defaultLeftI;
    currLeftI = leftI;
  } else {
    currLeftI = parenStack[0].spacesBefore;
    if (parenStack[0].numFinishedSubforms < parenStack[0].lispIndentNum) {
      currLeftI += 2;
    }
  }
  currLine = stringTrimBlanks(currLine);
  if (currLine !== "") {
    for (var i = 0; i < currLeftI; i++) {
      process.stdout.write(' ');
    }
    process.stdout.write(currLine);
  }
  process.stdout.write('\n');

  var escapeP = false;
  var tokenIntersticeP = false;
  var i = 0;
  function incrFinishedSubforms() {
    if (!tokenIntersticeP) {
      if (parenStack.length > 0) {
        parenStack[0].numFinishedSubforms++;
      }
    }
    tokenIntersticeP = true;
  }
  while (i < currLine.length) {
    var c = currLine[i];
    if (escapeP) {
      escapeP = false; i++;
    } else if (c === '\\') {
      tokenIntersticeP = false; escapeP = true; i++;
    } else if (insideStringP) {
      if (c === '"') { insideStringP = false; incrFinishedSubforms(); } i++;
    } else if (c === ';') {
      incrFinishedSubforms(); break;
    } else if (c === '"') {
      incrFinishedSubforms(); insideStringP = true; i++;
    } else if (c.match(/[ \t]/)) {
      incrFinishedSubforms(); i++;
    } else if (c.match(/[\(\[]/)) {
      incrFinishedSubforms();
      var si = calcSubindent(currLine, i+1);
      parenStack.unshift({ spacesBefore: 1 + i + currLeftI + si.deltaIndent,
        lispIndentNum: si.lispIndentNum,
        numFinishedSubforms: -1
      });
      tokenIntersticeP = true;
      var iNext = i+1;
      if (si.nextTokenIndex > iNext) {
        iNext = si.nextTokenIndex;
        tokenIntersticeP = false;
      }
      i = iNext;
    } else if (c.match(/[\)\]]/)) {
      tokenIntersticeP = false;
      if (parenStack.length > 0) {
        parenStack.shift();
      } else {
        leftI = 0;
      }
      i++;
    } else {
      tokenIntersticeP = false; i++;
    }
  }
  incrFinishedSubforms();
}

function indentLines() {
  process.stdin.setEncoding('utf8');
  var prevLine;
  process.stdin.on('data', function(data) {
    var lines = data.split('\n');
    if (lines.length) {
      if (prevLine) {
        lines[0] = prevLine + lines[0];
      }
      for (var i = 0; i < lines.length-1; i++) {
        tbd.emit('indentLine', lines[i]);
      }
      prevLine = lines[lines.length-1];
    }
  });
  process.stdin.on('end', function() {
    if (prevLine) {
      tbd.emit('indentLine', prevLine);
      prevLine = '';
    }
  });
}

function customize() {
  fs.readFile(process.env.LISPWORDS || (process.env.HOME + '/lispwords.json'), 'utf8',
    function(err, data) {
      if (!err) {
        var lw = JSON.parse(data);
        for (var kw in lw) {
          lispKeywords[kw] = lw[kw];
        }
      } else {
        // process.stderr.write('~/lispwords.json missing or ill-formed\n');
      }
      tbd.emit('customizationDone');
    });
}

tbd.on('start', customize);
tbd.on('customizationDone', indentLines);
tbd.on('indentLine', indentLine);

tbd.emit('start');
