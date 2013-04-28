window.requestAnimationFrame =
  window.requestAnimationFrame ||
  window.webkitRequestAnimationFrame ||
  window.mozRequestAnimationFrame ||
  window.oRequestAnimationFrame ||
  window.msRequestAnimationFrame ||
  (callback, element) -> window.setTimeout(callback, 1000/60)

window.localStorage = window.localStorage || {}

rocks = [
  new Rock(16, 'rocks_01')
  new Rock(20, 'rocks_02')
  new Rock(25, 'rocks_03')
  new Rock(23, 'rocks_04')
  new Rock(28, 'rocks_05')
  new Rock(17, 'rocks_06')
  new Rock(38, 'rocks_07')
  # NB: Er is geen 8, rare photoshop
  new Rock(23, 'rocks_09')
  new Rock(30, 'rocks_10')
  new Rock(30, 'rocks_11')
  new Rock(30, 'rocks_12')
  # new Rock(23, 'rocks_13') # Staat niet mooi in het midden
  new Rock(34, 'rocks_14')
  new Rock(30, 'rocks_15')
  new Rock(30, 'rocks_16')
  new Rock(30, 'rocks_17')
  new Rock(32, 'rocks_18')
  new Rock(38, 'rocks_19')
  new Rock(34, 'rocks_20')
  new Rock(27, 'rocks_21')
  new Rock(30, 'rocks_22')
  new Rock(29, 'rocks_23')
  new Rock(32, 'rocks_24')
  new Rock(30, 'rocks_25') # Deze is mooi rond!
  new Rock(30, 'rocks_26')
  new Rock(30, 'rocks_27')
  new Rock(30, 'rocks_28')
  new Rock(30, 'rocks_29')
  new Rock(32, 'rocks_30')
  new Rock(34, 'rocks_31')
  new Rock(30, 'rocks_32')
  new Rock(30, 'rocks_33')
  new Rock(30, 'rocks_34')
  new Rock(30, 'rocks_35')
  new Rock(30, 'rocks_36')
  new Rock(25, 'rocks_37')
  new Rock(31, 'rocks_38')
  new Rock(30, 'rocks_39')
  new Rock(30, 'rocks_40')
  # new Rock(30, 'rocks_41') staat niet mooi in het midden
  new Rock(28, 'rocks_42')
  new Rock(27, 'rocks_43')
  new Rock(30, 'rocks_44')
  new Rock(33, 'rocks_45')
  new Rock(27, 'rocks_46')
  new Rock(28, 'rocks_47')
  new Rock(28, 'rocks_48')
  new Rock(35, 'rocks_49')
  new Rock(20, 'rocks_50')
]

levels = [
  -> new Garden(new Rake(-30 + 20 + RAKE_WIDTH, 300 - RAKE_LENGTH/2, 0.5 * Math.PI),
                [
                  rocks[40].at(200,  50),
                  rocks[41].at(200, 150),
                  rocks[42].at(200, 250),
                  rocks[43].at(200, 350),
                  rocks[44].at(200, 450),
                  rocks[45].at(300,  50),
                  rocks[46].at(300, 150),
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
