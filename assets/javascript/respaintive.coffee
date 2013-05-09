'use strict'

####################
# CLASSES          #
####################

# Saves and restores a state of the drawing context.
class ContextState
  restore: ->
    context.lineWidth = @lineWidth
    context.strokeStyle = @strokeStyle
    true

  save: ->
    @lineWidth = context.lineWidth
    @strokeStyle = context.strokeStyle
    true

# Manages a list of moves.
class MoveHistory
  constructor: ->
    @moves = []

  clear: ->
    @moves.length = 0
    true

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
    context.lineTo(point.x, point.y) for point in @points
    context.stroke()
    context.closePath()

# Elements on the page.
body          = document.querySelector 'body'
canvas        = document.querySelector 'canvas'
closeSettings = document.getElementById 'settings-close'
colors        = document.querySelectorAll '#colors > li'
openSettings  = document.getElementById 'settings-open'
redo          = document.getElementById 'redo'
settings      = document.getElementById 'settings'
tools         = document.querySelectorAll '#tools > li'
trash         = document.getElementById 'trash'
undo          = document.getElementById 'undo'
undoAll       = document.getElementById 'undo-all'

# regular expressions
regexpPixelValue = /(\d+)px/

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
  right = body.style.right
  bodyOffset = if regexpPixelValue.test right then +(regexpPixelValue.exec right)[1] else 0

  x = if event.offsetX then event.offsetX else event.pageX - canvas.offsetLeft  + bodyOffset
  if event.touches then event.touches[0].screenX - canvas.offsetLeft + bodyOffset else x

getEventY = (event) ->
  y = if event.offsetY then event.offsetY else event.pageY - canvas.offsetTop
  if event.touches then event.touches[0].screenY - canvas.offsetTop else y


####################
# DRAWING          #
####################

startDrawing = (event) ->
  context.beginPath()

  x = getEventX(event)
  y = getEventY(event)

  currentMove = new Move(new Point(x, y), context.lineWidth, context.strokeStyle)
  context.moveTo(x, y)

  isDrawing = true

  event.preventDefault()

draw = (event) ->
  if isDrawing
    x = getEventX(event)
    y = getEventY(event)

    context.lineTo(x, y)
    context.stroke()

    currentMove.addPoint(new Point(x, y))

  event.preventDefault()

stopDrawing = (event) ->
  context.closePath()

  undoHistory.push currentMove
  enable undo
  enable undoAll
  enable trash

  redoHistory.clear()
  disable redo

  isDrawing = false

  event.preventDefault()

# colors
selectColor = (event) ->
  context.strokeStyle = event.target.dataset.color
  color.className = '' for color in colors
  event.target.className = 'active'

  event.preventDefault()

# tools
selectTool = (event) ->
  context.lineWidth = event.target.dataset.linewidth
  tool.className = '' for tool in tools
  event.target.className = 'active'

  event.preventDefault()


####################
# UNDO/REDO        #
####################

executeRedo = (event) ->
  unless redoHistory.isEmpty()
    contextState.save()

    move = redoHistory.pop()
    move.draw()
    undoHistory.push move

    enable undo
    enable undoAll
    disable redo if redoHistory.isEmpty()

    contextState.restore()

  event.preventDefault()

# Undoes the last move by clearing the canvas and redoing all previous moves.
executeUndo = (event) ->
  clearCanvas()

  contextState.save()

  redoHistory.push undoHistory.pop()
  move.draw() for move in undoHistory.moves

  (disable undo; disable undoAll) if undoHistory.isEmpty()
  enable redo

  contextState.restore()

  event.preventDefault()

executeUndoAll = (event) ->
  executeUndo(event) for move in undoHistory.moves
  event.preventDefault()

enable = (element) ->
  element.className = 'enabled'
  true

disable = (element) ->
  element.className = ''
  true

clearCanvas = ->
  context.clearRect 0, 0, canvas.width, canvas.height;


####################
# TRASH            #
####################

executeTrash = (event) ->
  clearCanvas()
  undoHistory.clear()
  redoHistory.clear()

  disable undo
  disable undoAll
  disable redo
  disable trash

  event.preventDefault()


####################
# RESPONSIVENESS   #
####################

adjustCanvasSize = ->
  canvas.width = "#{ body.clientWidth - 20 }"
  move.draw() for move in undoHistory.moves


####################
# OFF-CANVAS MENU  #
####################

hideSettings = (event) ->
  body.style.right = '0px'
  settings.style.display = 'none'

  event.preventDefault()

showSettings = (event) ->
  body.style.right = '280px'
  settings.style.display = 'block'

  event.preventDefault()


####################
# INITIALIZATION   #
####################

# initialize context
# TODO this seems to not do anything
context.strokeStyle = defaultStrokeStyle
context.lineCap     = defaultLineCap
context.lineJoin    = defaultLineJoin
context.lineWidth   = defaultLineWidth

# properly size canvas
adjustCanvasSize()


####################
# EVENT HANDLING   #
####################

# canvas
canvas.addEventListener 'mousedown',  startDrawing, false
canvas.addEventListener 'touchstart', startDrawing, false
canvas.addEventListener 'mousemove',  draw,         false
canvas.addEventListener 'touchmove',  draw,         false
canvas.addEventListener 'mouseup',    stopDrawing,  false
canvas.addEventListener 'touchend',   stopDrawing,  false

# menu bars
color.addEventListener 'click',      selectColor, false for color in colors
color.addEventListener 'touchstart', selectColor, false for color in colors
tool.addEventListener  'click',      selectTool,  false for tool  in tools
tool.addEventListener  'touchstart', selectTool,  false for tool  in tools

# actions
redo.addEventListener    'click',      executeRedo,    false
redo.addEventListener    'touchstart', executeRedo,    false
trash.addEventListener   'click',      executeTrash,   false
trash.addEventListener   'touchstart', executeTrash,   false
undo.addEventListener    'click',      executeUndo,    false
undo.addEventListener    'touchstart', executeUndo,    false
undoAll.addEventListener 'click',      executeUndoAll, false
undoAll.addEventListener 'touchstart', executeUndoAll, false

# off-canvas settings menu
closeSettings.addEventListener 'click',      hideSettings, false
closeSettings.addEventListener 'touchstart', hideSettings, false
openSettings.addEventListener  'click',      showSettings, false
openSettings.addEventListener  'touchstart', showSettings, false

# window
window.addEventListener 'resize', adjustCanvasSize, false
