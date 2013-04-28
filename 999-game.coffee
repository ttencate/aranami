window.requestAnimationFrame =
  window.requestAnimationFrame ||
  window.webkitRequestAnimationFrame ||
  window.mozRequestAnimationFrame ||
  window.oRequestAnimationFrame ||
  window.msRequestAnimationFrame ||
  (callback, element) -> window.setTimeout(callback, 1000/60)

window.localStorage = window.localStorage || {}

rocks = [
  new Rock(30, 'rocks_01')
  new Rock(30, 'rocks_02')
  new Rock(30, 'rocks_03')
  new Rock(30, 'rocks_04')
  new Rock(30, 'rocks_05')
  new Rock(30, 'rocks_06')
  new Rock(30, 'rocks_07')
  new Rock(30, 'rocks_08')
  new Rock(30, 'rocks_09')
  new Rock(30, 'rocks_10')
  new Rock(30, 'rocks_11')
  new Rock(30, 'rocks_12')
  new Rock(30, 'rocks_13')
  new Rock(30, 'rocks_14')
  new Rock(30, 'rocks_15')
  new Rock(30, 'rocks_16')
  new Rock(30, 'rocks_17')
  new Rock(30, 'rocks_18')
  new Rock(30, 'rocks_19')
  new Rock(30, 'rocks_20')
  new Rock(30, 'rocks_21')
  new Rock(30, 'rocks_22')
  new Rock(30, 'rocks_23')
  new Rock(30, 'rocks_24')
  new Rock(30, 'rocks_25')
  new Rock(30, 'rocks_26')
  new Rock(30, 'rocks_27')
  new Rock(30, 'rocks_28')
  new Rock(30, 'rocks_29')
  new Rock(30, 'rocks_30')
  new Rock(30, 'rocks_31')
  new Rock(30, 'rocks_32')
  new Rock(30, 'rocks_33')
  new Rock(30, 'rocks_34')
  new Rock(30, 'rocks_35')
  new Rock(30, 'rocks_36')
  new Rock(30, 'rocks_37')
  new Rock(30, 'rocks_38')
  new Rock(30, 'rocks_39')
  new Rock(30, 'rocks_40')
  new Rock(30, 'rocks_41')
  new Rock(30, 'rocks_42')
  new Rock(30, 'rocks_43')
  new Rock(30, 'rocks_44')
  new Rock(30, 'rocks_45')
  new Rock(30, 'rocks_46')
  new Rock(30, 'rocks_47')
  new Rock(30, 'rocks_48')
  new Rock(30, 'rocks_49')
  new Rock(30, 'rocks_50')
]

levels = [
  -> new Garden(new Rake(-30 + 20 + RAKE_WIDTH, 300 - RAKE_LENGTH/2, 0.5 * Math.PI),
                [
                  rocks[0].at(37, 200),
                  rocks[1].at(250, 300),
                  rocks[2].at(550, 600),
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
    if DEBUG then renderDebug()

    window.requestAnimationFrame(update)
  window.requestAnimationFrame(update)

  updateDom()
)
