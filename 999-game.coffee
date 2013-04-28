window.requestAnimationFrame =
  window.requestAnimationFrame ||
  window.webkitRequestAnimationFrame ||
  window.mozRequestAnimationFrame ||
  window.oRequestAnimationFrame ||
  window.msRequestAnimationFrame ||
  (callback, element) -> window.setTimeout(callback, 1000/60)

window.localStorage = window.localStorage || {}

levels = [
  -> new Garden(new Rake(-30 + 20 + RAKE_WIDTH, 300 - RAKE_LENGTH/2, 0.5 * Math.PI),
                [
                  #new Rock(37, 200, 30, 'rocks_01'),
                  new Rock(250, 300, 30, 'rocks_02'),
                  #new Rock(550, 600, 30, 'rocks_03'),
                ])
  -> new Garden(new Rake(20 + RAKE_WIDTH, 300 - RAKE_LENGTH/2, 0.5 * Math.PI),
                [])
  ]

ctx = null

$(->
  loadLevel(levels[0]())
  canvas = $('#canvas')[0]

  createjs.Sound.registerSound('test.mp3|test.ogg', 'test', 3)
  $('#test-sound').click((e) ->
    createjs.Sound.play('test')
    e.preventDefault()
  )

  $("#canvas").click (event) ->
    # TODO things
    event.preventDefault()

  ctx = canvas.getContext('2d')
  lastUpdate = Date.now()
  update = ->
    now = Date.now()
    dt = Math.min(50, now - lastUpdate)
    lastUpdate = now

    updateGarden(dt)
    renderDebug()

    window.requestAnimationFrame(update)
  window.requestAnimationFrame(update)

  updateDom()
)
