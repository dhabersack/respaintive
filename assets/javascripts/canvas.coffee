# elements
canvas = document.querySelector('canvas')
context = canvas.getContext('2d')

isDrawing = false
color = null

colors = document.querySelectorAll('#colors > li')
tools = document.querySelectorAll('#tools > li')

eraser = document.getElementById('eraser')

# drawing
startDrawing = (event) ->
  isDrawing = true
  context.beginPath()
  context.moveTo(event.offsetX, event.offsetY)

endDrawing = (event) ->
  context.closePath()
  isDrawing = false

draw = (event) ->
  if isDrawing
    context.lineTo(event.offsetX, event.offsetY)
    context.stroke()

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
  context.lineWidth = event.target.dataset['weight']
  (tool.className = '' for tool in tools)
  event.target.className = 'active'

# eraser
selectEraser = (event) ->
  context.strokeStyle = '#fff'

eraser.addEventListener('click', selectEraser, false)

# initialize
initializeContext = ->
  context.strokeStyle = '#3e3e3e'
  context.lineCap = 'round'
  context.lineJoin = 'round'

initializeColors = ->
  (initializeColor(color) for color in colors)

initializeTools = ->
  (initializeTool(tool) for tool in tools)

initializeContext()
initializeColors()
initializeTools()

canvas.addEventListener('mousedown', startDrawing, false)
canvas.addEventListener('mousemove', draw,         false)
canvas.addEventListener('mouseup',   endDrawing,   false)
