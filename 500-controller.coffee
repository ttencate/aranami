$(->
  grabAngle = null
  globalOrigin = null

  toPos = (element, e) ->
    pagePosition = $(element).offset()
    return {x: e.pageX - pagePosition.left, y: e.pageY - pagePosition.top}

  beginDrag = (pos) ->
    rake = garden.rake
    local = rake.toLocal(pos)
    localOrigin = null
    if local.y > -20 && local.y < RAKE_WIDTH + 20
      if local.x < RAKE_LENGTH / 2
        localOrigin = {x: RAKE_LENGTH - 1, y: 2}
      else
        localOrigin = {x: 1, y: 2}
    if localOrigin
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

  $('.container').mousedown (e) ->
    if e.which == 1
      pos = toPos(this, e)
      beginDrag(pos)
    e.preventDefault()

  $('.container').mousemove (e) ->
    if e.which == 1 && grabAngle != null
      pos = toPos(this, e)
      moveDrag(pos)
    else
      grabAngle = null
    e.preventDefault()

  $(document).mouseup (e) ->
    if e.which == 1 && grabAngle != null
      endDrag()
    e.preventDefault()
)

drawDents = ->
  rake = garden.rake
  sand = garden.sand
  for tooth in rake.teeth
    pos = rake.toGlobal(tooth)
    sand.dent(pos)

updateGarden = (dt) ->
  rake = garden.rake
  if rake.rotationOrigin && rake.targetAngle != rake.angle
    da = rake.targetAngle - rake.angle
    if da < -Math.PI
      da += 2*Math.PI
    if da > Math.PI
      da -= 2*Math.PI
    m = MAX_ANGULAR_VELOCITY * dt
    clamped = false
    if da < -m
      da = -m
      clamped = true
    if da > m
      da = m
      clamped = true

    oldX = rake.x
    oldY = rake.y
    oldAngle = rake.angle

    origin = rake.rotationOrigin
    rake.x += origin.x * Math.cos(rake.angle) - origin.y * Math.sin(rake.angle)
    rake.y += origin.x * Math.sin(rake.angle) + origin.y * Math.cos(rake.angle)
    rake.angle += da
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
      if !clamped
        rake.angle = rake.targetAngle
      drawDents()
      updateDom()
