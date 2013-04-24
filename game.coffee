window.requestAnimationFrame =
  window.requestAnimationFrame ||
  window.webkitRequestAnimationFrame ||
  window.mozRequestAnimationFrame ||
  window.oRequestAnimationFrame ||
  window.msRequestAnimationFrame ||
  (callback, element) -> window.setTimeout(callback, 1000/60)

window.localStorage = window.localStorage || {}

$(->
  createjs.Sound.registerSound('test.mp3|test.ogg', 'test', 3)
  $('#test-sound').click((e) ->
    createjs.Sound.play('test')
    e.preventDefault()
  )

  canvas = $('#canvas')[0]
  ctx = canvas.getContext('2d')
  angle = 0
  lastUpdate = Date.now()
  update = ->
    now = Date.now()
    delta = now - lastUpdate
    lastUpdate = now

    angle += 0.003 * delta

    ctx.setTransform(1, 0, 0, 1, 0, 0)
    ctx.clearRect(0, 0, canvas.width, canvas.height)

    ctx.font = '50px sans-serif'
    ctx.textAlign = 'center'
    ctx.textBaseline = 'middle'
    ctx.translate(canvas.width / 2 + Math.sin(0.003 * lastUpdate) * 200, canvas.height / 2)
    ctx.rotate(angle)
    ctx.fillText('Hello world!', 0, 0)
    window.requestAnimationFrame(update)
  window.requestAnimationFrame(update)
)
