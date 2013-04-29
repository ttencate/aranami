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
  -> new Garden(new Rake(), [ rocks[4].at(277, 194), rocks[19].at(467, 139), rocks[8].at(608, 379), rocks[1].at(269, 470), rocks[13].at(652, 174), ], 4),
  -> new Garden(new Rake(), [ rocks[6].at(160, 298), rocks[13].at(479, 211), rocks[17].at(304, 389), rocks[28].at(819, 51), rocks[11].at(728, 316), ], 5),
  -> new Garden(new Rake(), [ rocks[25].at(421, 165), rocks[12].at(336, 385), rocks[6].at(106, 419), rocks[22].at(237, 430), rocks[13].at(372, 55), rocks[15].at(530, 157), rocks[12].at(627, 200), rocks[2].at(706, 303), ], 5),
  -> new Garden(new Rake(), [ rocks[5].at(264, 200), rocks[12].at(237, 399), rocks[13].at(529, 239), rocks[8].at(206, 162), rocks[14].at(455, 449), rocks[23].at(525, 138), rocks[21].at(758, 293), rocks[24].at(720, 479), rocks[28].at(207, 457), rocks[44].at(267, 505), ], 8),
]
currentLevelIndex = 0

ctx = null
sandCtx = null

getStars = (i) -> parseInt(localStorage["stars#{i}"]) # NaN if not yet finished
setStars = (i, stars) -> localStorage["stars#{i}"] = stars
isUnlocked = (i) -> i <= 0 || !isNaN(getStars(i-1))

loadLevel = (i) ->
  $('#won').fadeOut(1000)
  level = levels[i]()
  currentLevelIndex = i
  window.garden = level
  $(".rock").remove()
  for rock in level.rocks
    rockDiv = makeRockDiv(rock)
  #$('#debug').append window.garden.sand.canvas
  updateDom()
  garden.sand.drawTo(sandCtx)
  if i == 0
    drawInstructions()
  updateLevelLinks()

updateLevelLink = (link, i) ->
  link.attr('href', "#level#{i+1}")
  numStars = getStars(i)
  if isNaN(numStars) then numStars = 0
  stars = ""
  (stars += "\u2605") for j in [0...numStars]
  (stars += "\u2606") for j in [0...3-numStars]
  link.html("#{stars} Level #{i+1}")
  link.css('visibility', if isUnlocked(i) then 'visible' else 'hidden')
  link.toggleClass('current', i == currentLevelIndex)
  link.click (e) ->
    window.location.hash = "#level#{i+1}"
    loadLevel(i)
    e.preventDefault()

updateLevelLinks = ->
  for i in [0...levels.length]
    link = $("#levellink#{i}")
    updateLevelLink(link, i)

drawInstructions = ->
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

$(->

  match = /^#level(\d+)$/.exec(window.location.hash)
  if match
    currentLevelIndex = parseInt(match[1]) - 1
    if currentLevelIndex < 0 || currentLevelIndex >= levels.length
      currentLevelIndex = 0
  updateLevelLinks()

  ctx = $('#canvas')[0].getContext('2d')
  sandCtx = $('#sand')[0].getContext('2d')
  loadLevel(currentLevelIndex)

  createjs.Sound.registerSound('test.mp3|test.ogg', 'test', 3)
  $('#test-sound').click((e) ->
    createjs.Sound.play('test')
    e.preventDefault()
  )

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

  $('#restart').click (e) ->
    loadLevel(currentLevelIndex)
    e.preventDefault()

  music = $('#music')[0]
  musicLink = $('#enable-music')
  music.volume = 0.3
  getMusic = -> localStorage.music == undefined || localStorage.music == "true"
  setMusic = (enable) ->
    if enable then music.play() else music.pause()
    musicLink.find('.icon').html(if enable then "\u266b" else "\u2a2f")
    localStorage.music = enable.toString()
  musicLink.click (e) ->
    setMusic(!getMusic())
    e.preventDefault()
  setMusic(getMusic())

  $('#won .retry').click (e) ->
    loadLevel(currentLevelIndex)
    e.preventDefault()
  $('#won .next').click (e) ->
    if currentLevelIndex + 1 < levels.length
      loadLevel(currentLevelIndex + 1)
    e.preventDefault()
)
