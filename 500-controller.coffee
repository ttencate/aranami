Math.clamp = (min, max, x) ->
  if x < min then return min
  if x > max then return max
  return x

$(->
  $('.handle-left')
    .data('rotation-center', [RAKE_LENGTH - 10, 3])
    .data('offset', [(RAKE_WIDTH - HANDLE_SIZE) / 2, (RAKE_WIDTH - HANDLE_SIZE) / 2])
  $('.handle-right')
    .data('rotation-center', [10, 3])
    .data('offset', [RAKE_LENGTH - (RAKE_WIDTH - HANDLE_SIZE) / 2 - HANDLE_SIZE, (RAKE_WIDTH - HANDLE_SIZE) / 2])

  MAX_ANGLE_CHANGE = 0.001
  draggedHandle = null

  $('.handle').mousedown (e) ->
    if e.which != 1 then return
    draggedHandle = $(this)
    handleOffset = draggedHandle.data('offset')
    [x, y] = [e.offsetX + handleOffset[0], e.offsetY + handleOffset[1]]
    [centerX, centerY] = draggedHandle.data('rotation-center')
    angle = Math.atan2(y - centerY, x - centerX)
    draggedHandle.data('grab-angle', angle)
    e.preventDefault()

  $('.handle').mousemove (e) ->
    if e.which != 1 then return
    handleOffset = draggedHandle.data('offset')
    [x, y] = [handleOffset[0] + e.offsetX, handleOffset[1] + e.offsetY]
    [centerX, centerY] = draggedHandle.data('rotation-center')
    grabAngle = draggedHandle.data('grab-angle')
    angle = Math.atan2(y - centerY, x - centerX)
    da = angle - grabAngle
    rake = garden.rake
    rake.x += centerX * Math.cos(rake.angle) - centerY * Math.sin(rake.angle)
    rake.y += centerX * Math.sin(rake.angle) + centerY * Math.cos(rake.angle)
    rake.angle += da
    rake.x -= centerX * Math.cos(rake.angle) - centerY * Math.sin(rake.angle)
    rake.y -= centerX * Math.sin(rake.angle) + centerY * Math.cos(rake.angle)
    updateDom()
    e.preventDefault()

  $(document).mouseup (e) ->
    if draggedHandle then draggedHandle = null
)

updateDom = ->
  rake = garden.rake
  $('.rake').css
    x: "#{rake.x}px"
    y: "#{rake.y}px"
    rotate: "#{rake.angle}rad"
