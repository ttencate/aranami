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
  -> new Garden(new Rake(), [], 4),
  -> new Garden(new Rake(), [ rocks[0].at(343, 418), rocks[1].at(606, 316), rocks[4].at(466, 502), ], 4),
  -> new Garden(new Rake(), [ rocks[2].at(562, 209), rocks[3].at(345, 424), rocks[5].at(824, 367), rocks[6].at(620, 505), ], 5),
]
currentLevelIndex = 0

ctx = null
sandCtx = null

$(->
  match = /^#level(\d+)$/.exec(window.location.hash)
  if match
    currentLevelIndex = parseInt(match[1]) - 1
    if currentLevelIndex < 0 || currentLevelIndex >= levels.length
      currentLevelIndex = 0

  loadLevel(levels[currentLevelIndex]())
  ctx = $('#canvas')[0].getContext('2d')
  sandCtx = $('#sand')[0].getContext('2d')
  garden.sand.drawTo(sandCtx)

  window.WebFontConfig = {
    custom: {
      families: [ 'Short Stack' ]
      urls: [ 'fonts.css' ]
    }
    fontactive: ->
      garden.sand.drawText("\u203a\u203a\u203a DRAG THE RAKE", 170, 212)
      garden.sand.drawText("TO HERE \u203a\u203a\u203a", 590, 310)
  }
  (->
    wf = document.createElement('script')
    wf.src = 'http://ajax.googleapis.com/ajax/libs/webfont/1/webfont.js'
    wf.type = 'text/javascript'
    wf.async = 'true'
    s = document.getElementsByTagName('script')[0]
    s.parentNode.insertBefore(wf, s)
  )()

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
  music.volume = 0.3
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
