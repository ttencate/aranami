Math.clamp = (min, max, x) ->
  if x < min then return min
  if x > max then return max
  return x

$(->
  origin = null
  grabAngle = 0

  toLocal = (element, e) ->
    pagePosition = $(element).position()
    pos = {x: e.pageX - pagePosition.left, y: e.pageY - pagePosition.top}
    return garden.rake.toLocal(pos.x, pos.y)

  $('.container').mousedown (e) ->
    if e.which != 1 then return
    local = toLocal(this, e)
    if local.y > -20 && local.y < RAKE_WIDTH + 20
      if local.x < RAKE_LENGTH / 2
        origin = {x: RAKE_LENGTH - 10, y: 3}
      else
        origin = {x: 10, y: 3}
    if origin
      grabAngle = Math.atan2(local.y - origin.y, local.x - origin.x)
    e.preventDefault()

  $('.container').mousemove (e) ->
    if origin and !e.which
      origin = null
      return
    if e.which != 1
      return
    if origin
      local = toLocal(this, e)
      angle = Math.atan2(local.y - origin.y, local.x - origin.x)
      da = angle - grabAngle
      rake = garden.rake
      rake.x += origin.x * Math.cos(rake.angle) - origin.y * Math.sin(rake.angle)
      rake.y += origin.x * Math.sin(rake.angle) + origin.y * Math.cos(rake.angle)
      rake.angle += da
      rake.x -= origin.x * Math.cos(rake.angle) - origin.y * Math.sin(rake.angle)
      rake.y -= origin.x * Math.sin(rake.angle) + origin.y * Math.cos(rake.angle)
      updateDom()
    e.preventDefault()

  $(document).mouseup (e) ->
    if draggedHandle then draggedHandle = null
)

