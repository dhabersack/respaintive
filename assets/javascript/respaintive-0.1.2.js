(function() {
  'use strict';
  var ContextState, Move, MoveHistory, Point, adjustCanvasSize, body, canvas, clearCanvas, closeSettings, color, colors, context, contextState, currentMove, defaultLineCap, defaultLineJoin, defaultLineWidth, defaultStrokeStyle, disable, draw, enable, executeRedo, executeTrash, executeUndo, executeUndoAll, getEventX, getEventY, hideSettings, isDrawing, openSettings, redo, redoHistory, regexpPixelValue, selectColor, selectTool, settings, showSettings, startDrawing, stopDrawing, tool, tools, trash, undo, undoAll, undoHistory, _i, _j, _k, _l, _len, _len1, _len2, _len3;

  ContextState = (function() {
    function ContextState() {}

    ContextState.prototype.restore = function() {
      context.lineWidth = this.lineWidth;
      context.strokeStyle = this.strokeStyle;
      return true;
    };

    ContextState.prototype.save = function() {
      this.lineWidth = context.lineWidth;
      this.strokeStyle = context.strokeStyle;
      return true;
    };

    return ContextState;

  })();

  MoveHistory = (function() {
    function MoveHistory() {
      this.moves = [];
    }

    MoveHistory.prototype.clear = function() {
      this.moves.length = 0;
      return true;
    };

    MoveHistory.prototype.isEmpty = function() {
      return this.moves.length === 0;
    };

    MoveHistory.prototype.pop = function() {
      return this.moves.pop();
    };

    MoveHistory.prototype.push = function(move) {
      return this.moves.push(move);
    };

    MoveHistory.prototype.size = function() {
      return this.moves.length;
    };

    return MoveHistory;

  })();

  Point = (function() {
    function Point(x, y) {
      this.x = x;
      this.y = y;
    }

    return Point;

  })();

  Move = (function() {
    function Move(startingPoint, lineWidth, strokeStyle) {
      this.startingPoint = startingPoint;
      this.lineWidth = lineWidth;
      this.strokeStyle = strokeStyle;
      this.points = [];
    }

    Move.prototype.addPoint = function(point) {
      return this.points.push(point);
    };

    Move.prototype.draw = function() {
      var point, _i, _len, _ref;

      context.beginPath();
      context.strokeStyle = this.strokeStyle;
      context.lineWidth = this.lineWidth;
      context.moveTo(this.startingPoint.x, this.startingPoint.y);
      _ref = this.points;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        point = _ref[_i];
        context.lineTo(point.x, point.y);
      }
      context.stroke();
      return context.closePath();
    };

    return Move;

  })();

  body = document.querySelector('body');

  canvas = document.querySelector('canvas');

  closeSettings = document.getElementById('settings-close');

  colors = document.querySelectorAll('#colors > li');

  openSettings = document.getElementById('settings-open');

  redo = document.getElementById('redo');

  settings = document.getElementById('settings');

  tools = document.querySelectorAll('#tools > li');

  trash = document.getElementById('trash');

  undo = document.getElementById('undo');

  undoAll = document.getElementById('undo-all');

  defaultStrokeStyle = '#3e3e3e';

  defaultLineCap = 'round';

  defaultLineJoin = 'round';

  defaultLineWidth = 1;

  regexpPixelValue = /(\d+)px/;

  context = canvas.getContext('2d');

  contextState = new ContextState();

  isDrawing = false;

  currentMove = null;

  redoHistory = new MoveHistory();

  undoHistory = new MoveHistory();

  getEventX = function(event) {
    var bodyOffset, right, x;

    right = (window.getComputedStyle(body)).right;
    bodyOffset = regexpPixelValue.test(right) ? +(regexpPixelValue.exec(right))[1] : 0;
    x = event.offsetX ? event.offsetX : event.pageX - canvas.offsetLeft + bodyOffset;
    if (event.touches) {
      x = event.touches[0].screenX - canvas.offsetLeft + bodyOffset;
    }
    return x;
  };

  getEventY = function(event) {
    var y;

    y = event.offsetY ? event.offsetY : event.pageY - canvas.offsetTop;
    if (event.touches) {
      y = event.touches[0].screenY - canvas.offsetTop;
    }
    return y;
  };

  startDrawing = function(event) {
    var x, y;

    context.beginPath();
    x = getEventX(event);
    y = getEventY(event);
    currentMove = new Move(new Point(x, y), context.lineWidth, context.strokeStyle);
    context.moveTo(x, y);
    isDrawing = true;
    return event.preventDefault();
  };

  draw = function(event) {
    var x, y;

    if (isDrawing) {
      x = getEventX(event);
      y = getEventY(event);
      context.lineTo(x, y);
      context.stroke();
      currentMove.addPoint(new Point(x, y));
    }
    return event.preventDefault();
  };

  stopDrawing = function(event) {
    context.closePath();
    undoHistory.push(currentMove);
    enable(undo);
    enable(undoAll);
    enable(trash);
    redoHistory.clear();
    disable(redo);
    isDrawing = false;
    return event.preventDefault();
  };

  selectColor = function(event) {
    var color, _i, _len;

    context.strokeStyle = event.target.dataset.color;
    for (_i = 0, _len = colors.length; _i < _len; _i++) {
      color = colors[_i];
      color.className = '';
    }
    event.target.className = 'active';
    return event.preventDefault();
  };

  selectTool = function(event) {
    var tool, _i, _len;

    context.lineWidth = event.target.dataset.linewidth;
    for (_i = 0, _len = tools.length; _i < _len; _i++) {
      tool = tools[_i];
      tool.className = '';
    }
    event.target.className = 'active';
    return event.preventDefault();
  };

  executeRedo = function(event) {
    var move;

    if (!redoHistory.isEmpty()) {
      contextState.save();
      move = redoHistory.pop();
      move.draw();
      undoHistory.push(move);
      enable(undo);
      enable(undoAll);
      if (redoHistory.isEmpty()) {
        disable(redo);
      }
      contextState.restore();
    }
    return event.preventDefault();
  };

  executeUndo = function(event) {
    var move, _i, _len, _ref;

    clearCanvas();
    contextState.save();
    redoHistory.push(undoHistory.pop());
    _ref = undoHistory.moves;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      move = _ref[_i];
      move.draw();
    }
    if (undoHistory.isEmpty()) {
      disable(undo);
      disable(undoAll);
    }
    enable(redo);
    contextState.restore();
    return event.preventDefault();
  };

  executeUndoAll = function(event) {
    var move, _i, _len, _ref;

    _ref = undoHistory.moves;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      move = _ref[_i];
      executeUndo(event);
    }
    return event.preventDefault();
  };

  enable = function(element) {
    element.className = 'enabled';
    return true;
  };

  disable = function(element) {
    element.className = '';
    return true;
  };

  clearCanvas = function() {
    return context.clearRect(0, 0, canvas.width, canvas.height);
  };

  executeTrash = function(event) {
    clearCanvas();
    undoHistory.clear();
    redoHistory.clear();
    disable(undo);
    disable(undoAll);
    disable(redo);
    disable(trash);
    return event.preventDefault();
  };

  adjustCanvasSize = function() {
    var move, _i, _len, _ref, _results;

    canvas.width = "" + (body.clientWidth - 20);
    _ref = undoHistory.moves;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      move = _ref[_i];
      _results.push(move.draw());
    }
    return _results;
  };

  hideSettings = function(event) {
    body.className = '';
    settings.className = '';
    return event.preventDefault();
  };

  showSettings = function(event) {
    body.className = 'offset';
    settings.className = 'offset';
    return event.preventDefault();
  };

  context.strokeStyle = defaultStrokeStyle;

  context.lineCap = defaultLineCap;

  context.lineJoin = defaultLineJoin;

  context.lineWidth = defaultLineWidth;

  adjustCanvasSize();

  canvas.addEventListener('mousedown', startDrawing, false);

  canvas.addEventListener('touchstart', startDrawing, false);

  canvas.addEventListener('mousemove', draw, false);

  canvas.addEventListener('touchmove', draw, false);

  canvas.addEventListener('mouseup', stopDrawing, false);

  canvas.addEventListener('touchend', stopDrawing, false);

  for (_i = 0, _len = colors.length; _i < _len; _i++) {
    color = colors[_i];
    color.addEventListener('click', selectColor, false);
  }

  for (_j = 0, _len1 = colors.length; _j < _len1; _j++) {
    color = colors[_j];
    color.addEventListener('touchstart', selectColor, false);
  }

  for (_k = 0, _len2 = tools.length; _k < _len2; _k++) {
    tool = tools[_k];
    tool.addEventListener('click', selectTool, false);
  }

  for (_l = 0, _len3 = tools.length; _l < _len3; _l++) {
    tool = tools[_l];
    tool.addEventListener('touchstart', selectTool, false);
  }

  redo.addEventListener('click', executeRedo, false);

  redo.addEventListener('touchstart', executeRedo, false);

  trash.addEventListener('click', executeTrash, false);

  trash.addEventListener('touchstart', executeTrash, false);

  undo.addEventListener('click', executeUndo, false);

  undo.addEventListener('touchstart', executeUndo, false);

  undoAll.addEventListener('click', executeUndoAll, false);

  undoAll.addEventListener('touchstart', executeUndoAll, false);

  closeSettings.addEventListener('click', hideSettings, false);

  closeSettings.addEventListener('touchstart', hideSettings, false);

  openSettings.addEventListener('click', showSettings, false);

  openSettings.addEventListener('touchstart', showSettings, false);

  window.addEventListener('resize', adjustCanvasSize, false);

}).call(this);
