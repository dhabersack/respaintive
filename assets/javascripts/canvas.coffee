# elements
canvas = document.querySelector('canvas')
colors = document.querySelectorAll('#colors > li')
tools = document.querySelectorAll('#tools > li')
redo = document.getElementById('redo')
undo = document.getElementById('undo')
undoAll = document.getElementById('undo-all')
context = canvas.getContext('2d')

# state
isDrawing = false

# variables for undo-functionality
allMoves = []
currentMove = null
undoneMoves = []

# coordinates
getX = (event) ->
  x = event.offsetX
  x = event.layerX - canvas.offsetLeft unless x
  return x

getY = (event) ->
  y = event.offsetY
  y = event.layerY - canvas.offsetTop unless y
  return y

# drawing
drawLineTo = (x, y) ->
  context.lineTo(x, y)
  context.stroke()

startDrawing = (event) ->
  isDrawing = true
  context.beginPath()

  x = getX(event)
  y = getY(event)

  context.moveTo(x, y)
  initializeCurrentMove(x, y)

draw = (event) ->
  if isDrawing
    x = getX(event)
    y = getY(event)

    drawLineTo(x, y)
    addCoordinatesToCurrentMove(x, y)

stopDrawing = (event) ->
  context.closePath()
  allMoves.push currentMove
  undoneMoves = []
  redo.className = ''
  enableUndo()
  isDrawing = false

# colors
initializeColor = (color) ->
  color.addEventListener('click', selectColor)
  setElementColor(color)

selectColor = (event) ->
  context.strokeStyle = event.target.dataset['color']
  (color.className = '' for color in colors)
  event.target.className = 'active'

setElementColor = (element) ->
  element.style.background = element.dataset['color']

# tools
initializeTool = (tool) ->
  tool.addEventListener('click', selectTool)

selectTool = (event) ->
  context.lineWidth = event.target.dataset['linewidth']
  (tool.className = '' for tool in tools)
  event.target.className = 'active'

# undo
initializeCurrentMove = (x, y) ->
  currentMove = {
    lineWidth: context.lineWidth,
    strokeStyle: context.strokeStyle,
    moves: [{ x: x, y: y }]
  }

addCoordinatesToCurrentMove = (x, y) ->
  currentMove.moves.push { x: x, y: y }

# undoes the last move by clearing the canvas and redoing all previous moves
executeUndo = ->
  clearCanvas()

  # save state
  lineWidth = context.lineWidth
  strokeStyle = context.strokeStyle

  undoneMoves.push allMoves.pop()
  (repeatMove(move) for move in allMoves)

  # restore state
  context.lineWidth = lineWidth
  context.strokeStyle = strokeStyle

  if allMoves.length == 0
    disableUndo()

  redo.className = 'available'

enableUndo = ->
  undo.className = 'available'
  undoAll.className = 'available'

disableUndo = ->
  undo.className = ''
  undoAll.className = ''

executeRedo = ->
  undoneMove = undoneMoves.pop()
  repeatMove(undoneMove)
  if undoneMoves.length == 0
    redo.className = ''

executeUndoAll = ->
  clearCanvas()
  allMoves = []
  disableUndo()

repeatMove = (move) ->
  context.beginPath()
  context.strokeStyle = move.strokeStyle
  context.lineWidth = move.lineWidth
  firstMove = move.moves[0]
  context.moveTo(firstMove.x, firstMove.y)
  (drawLineTo(item.x, item.y) for item in move.moves)
  context.closePath()

clearCanvas = ->
  context.clearRect(0, 0, canvas.width, canvas.height);

# initialize
initializeContext = ->
  context.strokeStyle = '#3e3e3e'
  context.lineCap = 'round'
  context.lineJoin = 'round'
  context.lineWidth = 1

initializeColors = ->
  (initializeColor(color) for color in colors)

initializeTools = ->
  (initializeTool(tool) for tool in tools)

initializeContext()
initializeColors()
initializeTools()

# register event listeners
canvas.addEventListener('mousedown', startDrawing, false)
canvas.addEventListener('mousemove', draw, false)
canvas.addEventListener('mouseup', stopDrawing, false)
redo.addEventListener('click', executeRedo, false)
undo.addEventListener('click', executeUndo, false)
undoAll.addEventListener('click', executeUndoAll, false)
