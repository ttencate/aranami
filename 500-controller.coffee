Math.clamp = (min, max, x) ->
  if x < min then return min
  if x > max then return max
  return x

$(->
  grabAngle = null
  globalOrigin = null

  toPos = (element, e) ->
    pagePosition = $(element).position()
    return {x: e.pageX - pagePosition.left, y: e.pageY - pagePosition.top}

  beginDrag = (pos) ->
    rake = garden.rake
    local = rake.toLocal(pos)
    localOrigin = null
    if local.y > -20 && local.y < RAKE_WIDTH + 20
      if local.x < RAKE_LENGTH / 2
        localOrigin = {x: RAKE_LENGTH - 10, y: 3}
      else
        localOrigin = {x: 10, y: 3}
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

updateGarden = (dt) ->
  rake = garden.rake
  origin = rake.rotationOrigin
  if origin && rake.targetAngle != rake.angle
    da = rake.targetAngle - rake.angle
    m = MAX_ANGULAR_VELOCITY * dt
    clamped = false
    if da < -m
      da = -m
      clamped = true
    if da > m
      da = m
      clamped = true
    rake.x += origin.x * Math.cos(rake.angle) - origin.y * Math.sin(rake.angle)
    rake.y += origin.x * Math.sin(rake.angle) + origin.y * Math.cos(rake.angle)
    garden.rake.angle += da
    rake.x -= origin.x * Math.cos(rake.angle) - origin.y * Math.sin(rake.angle)
    rake.y -= origin.x * Math.sin(rake.angle) + origin.y * Math.cos(rake.angle)
    if !clamped
      rake.angle = rake.targetAngle
  updateDom()
