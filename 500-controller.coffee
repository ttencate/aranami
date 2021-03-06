$(->
  grabAngle = null
  globalOrigin = null

  incrementScore = ->
    garden.score = garden.score + 1
    garden.sand.drawPoint(garden.score)

  toPos = (e) ->
    pagePosition = $('#container').offset()
    return {x: e.pageX - pagePosition.left, y: e.pageY - pagePosition.top}

  beginDrag = (pos) ->
    rake = garden.rake
    local = rake.toLocal(pos)
    localOrigin = null
    if local.x > -20 && local.x < RAKE_Q + 20 && local.y > -20 && local.y < RAKE_Q + 20
      if local.x < local.y
        localOrigin = {x: RAKE_Q, y: RAKE_P}
      else
        localOrigin = {x: RAKE_P, y: RAKE_Q}
    if localOrigin
      incrementScore()
      globalOrigin = rake.toGlobal(localOrigin)
      grabAngle = Math.atan2(pos.y - globalOrigin.y, pos.x - globalOrigin.x)
      rake.rotationOrigin = localOrigin
      rake.targetAngle = rake.angle

  moveDrag = (pos) ->
    angle = Math.atan2(pos.y - globalOrigin.y, pos.x - globalOrigin.x)
    garden.rake.targetAngle += angle - grabAngle
    grabAngle = angle

  endDrag = () ->
    rake = garden.rake
    rake.rotationOrigin = null
    rake.targetAngle = rake.angle
    grabAngle = null
    globalOrigin = null

  $('.rake').mousedown (e) ->
    if e.which == 1
      pos = toPos(e)
      beginDrag(pos)
    e.preventDefault()

  $(document).mousemove (e) ->
    if e.which == 1 && grabAngle != null
      pos = toPos(e)
      moveDrag(pos)
    else
      grabAngle = null
    e.preventDefault()

  $(document).mouseup (e) ->
    if e.which == 1 && grabAngle != null
      endDrag()
    e.preventDefault()

  if DEBUG
    $(document).keypress (e) ->
      if e.which == 96 # backtick
        garden.dump()
        e.preventDefault()
      else if e.which == 42 # asterisk
        win()
      else if e.which == 45 # minus
        dumpTimes()
      else if e.which == 92 # backslash
        garden.rake.x = RAKE_START_X
        garden.rake.y = RAKE_START_Y
        garden.rake.angle = RAKE_START_ANGLE
        garden.rake.targetAngle = garden.rake.angle
        updateDom()
        garden.sand.clear()
      else
        s = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
        index = s.indexOf(String.fromCharCode(e.which))
        if index >= 0 && index < rocks.length
          rock = rocks[index].at(50, -50)
          garden.rocks.push(rock)
          $('.container').append(makeRockDiv(rock))
)

win = ->
  garden.won = true
  stars = Math.clamp(0, 3, 3 - (garden.score - garden.par))
  currentStars = getStars(currentLevelIndex)

  $('.star').removeClass('visible')
  $('#won .level').html("#{currentLevelIndex+1}")
  $('#won .moves').html(garden.score)
  $('#won .par').html(garden.par)
  $('#won').fadeIn(1000)
  $('#won .next').toggle(currentLevelIndex + 1 < levels.length)
  for i in [0...stars]
    $(".star#{i+1}").addClass('visible')

  if isNaN(currentStars) || stars > currentStars
    setStars(currentLevelIndex, stars)
    updateLevelLinks()

checkWin = ->
  for tooth in garden.rake.teeth
    pos = garden.rake.toGlobal(tooth)
    # plank is 100x350 at 855x125
    if pos.x >= 855 && pos.y >= 125 && pos.y <= 125 + 350
      win()
      return

updateGarden = (dt) ->
  return if garden.won
  rake = garden.rake
  if rake.rotationOrigin && Math.abs(Math.canonicalAngle(rake.targetAngle - rake.angle)) >= ANGULAR_STEP
    da = Math.canonicalAngle(rake.targetAngle - rake.angle)
    if da > Math.PI
      da -= 2*Math.PI
    if da < 0
      da = -ANGULAR_STEP
    else
      da = ANGULAR_STEP

    oldX = rake.x
    oldY = rake.y
    oldAngle = rake.angle
    oldTeeth = (rake.toGlobal(tooth) for tooth in rake.teeth)

    origin = rake.rotationOrigin
    rake.x += origin.x * Math.cos(rake.angle) - origin.y * Math.sin(rake.angle)
    rake.y += origin.x * Math.sin(rake.angle) + origin.y * Math.cos(rake.angle)
    rake.angle += da
    rake.angle = Math.canonicalAngle(rake.angle)
    rake.x -= origin.x * Math.cos(rake.angle) - origin.y * Math.sin(rake.angle)
    rake.y -= origin.x * Math.sin(rake.angle) + origin.y * Math.cos(rake.angle)

    inSand = (pos) -> pos.x >= 0 && pos.y >= 0 && pos.x <= GARDEN_WIDTH && pos.y <= GARDEN_HEIGHT

    collides = false
    for segment in rake.segments
      a = rake.toGlobal(segment[0])
      b = rake.toGlobal(segment[1])
      if !inSand(a) || !inSand(b) then collides = true
      break if collides
      for rock in garden.rocks
        p = {x: a.x - rock.x, y: a.y - rock.y}
        q = {x: b.x - rock.x, y: b.y - rock.y}
        if Math.length(p) <= rock.radius || Math.length(q) <= rock.radius
          collides = true
          break
        v = {x: q.x - p.x, y: q.y - p.y}
        t = -(p.x * v.x + p.y * v.y) / ((v.x * v.x + v.y * v.y))
        u = Math.length({x: p.x + t * v.x, y: p.y + t * v.y})
        if Math.abs(u) <= rock.radius && t >= 0 && t <= 1
          collides = true
          break
      break if collides

    if collides
      rake.x = oldX
      rake.y = oldY
      rake.angle = oldAngle
    else
      dents = for i in [0...rake.teeth.length]
        dent = rake.toGlobal(rake.teeth[i])
        oldTooth = oldTeeth[i]
        dent.angle = Math.atan2(dent.y - oldTooth.y, dent.x - oldTooth.x)
        dent
      garden.sand.drawDents(dents)
      updateDom()
      checkWin()
