window.requestAnimationFrame =
  window.requestAnimationFrame ||
  window.webkitRequestAnimationFrame ||
  window.mozRequestAnimationFrame ||
  window.oRequestAnimationFrame ||
  window.msRequestAnimationFrame ||
  (callback, element) -> window.setTimeout(callback, 1000/60)

window.localStorage = window.localStorage || {}

board = new Board 500, 400,
  new Split 'v', 0.4,
    new Field 20, 1
    new Field 20, 1.5

$(->

  canvas = $('#canvas')[0]

  createjs.Sound.registerSound('test.mp3|test.ogg', 'test', 3)
  $('#test-sound').click((e) ->
    createjs.Sound.play('test')
    e.preventDefault()
  )

  ctx = canvas.getContext('2d')
  lastUpdate = Date.now()
  update = ->
    now = Date.now()
    delta = now - lastUpdate
    lastUpdate = now

    ctx.setTransform(1, 0, 0, 1, 0, 0)
    ctx.clearRect(0, 0, canvas.width, canvas.height)

    window.requestAnimationFrame(update)
  window.requestAnimationFrame(update)
)
