####################
# CLASSES          #
####################

# Saves and restores a state of the drawing context.
class ContextState
  restore: ->
    context.lineWidth = @lineWidth
    context.strokeStyle = @strokeStyle

  save: ->
    @lineWidth = context.lineWidth
    @strokeStyle = context.strokeStyle

# Manages a list of moves.
class MoveHistory
  constructor: ->
    @moves = []

  clear: ->
    @moves.length = 0

  isEmpty: ->
    @moves.length == 0

  pop: ->
    @moves.pop()

  push: (move) ->
    @moves.push move

  size: ->
    @moves.length

# Represents a point in two-dimensional space.
class Point
  constructor: (@x, @y) ->

# Represents a move in the drawing context.
class Move
  constructor: (@startingPoint, @lineWidth, @strokeStyle) ->
    @points = []

  addPoint: (point) ->
    @points.push point

  draw: ->
    context.beginPath()
    context.strokeStyle = @strokeStyle
    context.lineWidth = @lineWidth
    context.moveTo @startingPoint.x, @startingPoint.y
    drawLineTo point for point in @points
    context.closePath()

# Elements on the page.
canvas    = document.querySelector 'canvas'
colors    = document.querySelectorAll '#colors > li'
redo      = document.getElementById 'redo'
redoCount = document.querySelector '#redo > span'
tools     = document.querySelectorAll '#tools > li'
undo      = document.getElementById 'undo'
undoAll   = document.getElementById 'undo-all'
undoCount = document.querySelector '#undo > span'

# default configuration of drawing context
defaultStrokeStyle = '#3e3e3e'
defaultLineCap     = 'round'
defaultLineJoin    = 'round'
defaultLineWidth   = 1

# drawing context
context = canvas.getContext '2d'

# state
contextState = new ContextState()
isDrawing = false

# variables for undo-functionality
currentMove = null
redoHistory = new MoveHistory()
undoHistory = new MoveHistory()

# Extract coordinates from events.
getEventX = (event) ->
  if event.offsetX then event.offsetX else event.layerX - canvas.offsetLeft

getEventY = (event) ->
  if event.offsetY then event.offsetY else event.layerY - canvas.offsetTop


####################
# DRAWING          #
####################

drawLineTo = (point) ->
  context.lineTo(point.x, point.y)
  context.stroke()

startDrawing = (event) ->
  context.beginPath()

  x = getEventX(event)
  y = getEventY(event)

  currentMove = new Move(new Point(x, y), context.lineWidth, context.strokeStyle)
  context.moveTo(x, y)

  isDrawing = true

draw = (event) ->
  if isDrawing
    x = getEventX(event)
    y = getEventY(event)

    drawLineTo(new Point(x, y))
    currentMove.addPoint(new Point(x, y))

stopDrawing = (event) ->
  context.closePath()

  undoHistory.push currentMove
  enableUndo()

  redoHistory.clear()
  disableRedo()

  updateCounts()

  isDrawing = false

# colors
initializeColor = (color) ->
  color.addEventListener 'click', selectColor, false
  setElementColor color

selectColor = (event) ->
  context.strokeStyle = event.target.dataset['color']
  color.className = '' for color in colors
  event.target.className = 'active'

setElementColor = (element) ->
  element.style.background = element.dataset['color']

# tools
initializeTool = (tool) ->
  tool.addEventListener 'click', selectTool, false

selectTool = (event) ->
  context.lineWidth = event.target.dataset['linewidth']
  tool.className = '' for tool in tools
  event.target.className = 'active'


####################
# UNDO/REDO        #
####################

executeRedo = ->
  move = redoHistory.pop()
  if move
    contextState.save()

    move.draw()
    undoHistory.push move

    updateCounts()

    enableUndo()
    disableRedo() if redoHistory.isEmpty()

    contextState.restore()

# undoes the last move by clearing the canvas and redoing all previous moves
executeUndo = ->
  clearCanvas()

  contextState.save()

  redoHistory.push undoHistory.pop()
  move.draw() for move in undoHistory.moves

  updateCounts()

  disableUndo() if undoHistory.isEmpty()
  enableRedo()

  contextState.restore()

executeUndoAll = ->
  executeUndo() for move in undoHistory.moves

enableRedo = ->
  redo.className = 'available'

enableUndo = ->
  undo.className    = 'available'
  undoAll.className = 'available'

disableRedo = ->
  redo.className = ''

disableUndo = ->
  undo.className    = ''
  undoAll.className = ''

updateRedoCount = ->
  redoCount.innerHTML = redoHistory.size()

updateUndoCount = ->
  undoCount.innerHTML = undoHistory.size()

updateCounts = ->
  updateUndoCount()
  updateRedoCount()

clearCanvas = ->
  context.clearRect 0, 0, canvas.width, canvas.height;


####################
# INITIALIZATION   #
####################

# initialize context
context.strokeStyle = defaultStrokeStyle
context.lineCap     = defaultLineCap
context.lineJoin    = defaultLineJoin
context.lineWidth   = defaultLineWidth

# initialize menu bars
initializeColor color for color in colors
initializeTool  tool  for tool  in tools


####################
# EVENT HANDLING   #
####################

# register event listeners
canvas.addEventListener  'mousedown', startDrawing,   false
canvas.addEventListener  'mousemove', draw,           false
canvas.addEventListener  'mouseup',   stopDrawing,    false
redo.addEventListener    'click',     executeRedo,    false
undo.addEventListener    'click',     executeUndo,    false
undoAll.addEventListener 'click',     executeUndoAll, false
