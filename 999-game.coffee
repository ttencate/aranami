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
  -> new Garden(new Rake(-30 + 20 + RAKE_WIDTH, 300 - RAKE_LENGTH/2, 0.5 * Math.PI), [ rocks[20].at(203, 402), rocks[6].at(462, 181), rocks[5].at(103, 62), rocks[17].at(738, 423), rocks[4].at(475, 540), rocks[41].at(767, 58), ])
  -> new Garden(new Rake(-30 + 20 + RAKE_WIDTH, 300 - RAKE_LENGTH/2, 0.5 * Math.PI), [ rocks[0].at(90, 512), rocks[8].at(374, 528), rocks[11].at(240, 243), rocks[30].at(393, 68), rocks[13].at(109, 76), rocks[42].at(512, 383), rocks[29].at(748, 147), rocks[1].at(666, 459), rocks[38].at(830, 492), ])
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
sandCtx = null

$(->
  loadLevel(levels[0]())
  ctx = $('#canvas')[0].getContext('2d')
  sandCtx = $('#sand')[0].getContext('2d')
  window.setTimeout((->
    garden.sand.drawText("››› DRAG THE RAKE", 60, 390)
    garden.sand.drawText("TO HERE ›››", 590, 310)
  ), 500)


  createjs.Sound.registerSound('test.mp3|test.ogg', 'test', 3)
  $('#test-sound').click((e) ->
    createjs.Sound.play('test')
    e.preventDefault()
  )

  $("#canvas").click (event) ->
    # TODO things
    event.preventDefault()

  lastUpdate = Date.now()
  update = ->
    now = Date.now()
    dt = Math.min(20, now - lastUpdate)
    lastUpdate = now

    updateGarden(dt)

    if DEBUG
      ctx.setTransform(1, 0, 0, 1, 0, 0)
      ctx.clearRect(0, 0, GARDEN_WIDTH, GARDEN_HEIGHT)
      renderDebug()

    window.requestAnimationFrame(update)
  window.requestAnimationFrame(update)

  updateDom()

  music = $('#music')[0]
  musicCheckbox = $('#enable-music')
  music.volume = 0.2
  setMusic = (enable) ->
    if enable then music.play() else music.pause()
    musicCheckbox.prop('checked', enable)
    localStorage.music = enable.toString()
  musicCheckbox.click (e) ->
    console.log e
    setMusic($(this).is(':checked'))
  if localStorage.music == undefined
    localStorage.music = "true"
  setMusic(localStorage.music == "true")
)
