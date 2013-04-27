window.requestAnimationFrame =
  window.requestAnimationFrame ||
  window.webkitRequestAnimationFrame ||
  window.mozRequestAnimationFrame ||
  window.oRequestAnimationFrame ||
  window.msRequestAnimationFrame ||
  (callback, element) -> window.setTimeout(callback, 1000/60)

window.localStorage = window.localStorage || {}

board = randomBoard(800, 600, 9, 1, 1, 1)

$(->
  canvas = $('#canvas')[0]
  window.renderer = new Renderer(board, $(canvas))

  createjs.Sound.registerSound('test.mp3|test.ogg', 'test', 3)
  $('#test-sound').click((e) ->
    createjs.Sound.play('test')
    e.preventDefault()
  )

  $("#canvas").click (event) ->
    renderer.findField(event.offsetX, event.offsetY).cycleHeat()
    event.preventDefault()

  ctx = canvas.getContext('2d')
  lastUpdate = Date.now()
  update = ->
    now = Date.now()
    delta = Math.min(50, now - lastUpdate)
    lastUpdate = now

    updateBoard(board, delta)
    renderer.render()

    window.requestAnimationFrame(update)
  window.requestAnimationFrame(update)
)
