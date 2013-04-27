UPDATE_SPEED = 1000.0

# Returns force on left, right, bottom, top in outward direction
updateNode = (node, width, height, dt) ->
  if node instanceof Field
    pressure = node.gas * node.heat / (width * height)
    return {
      fLeft: pressure
      fRight: pressure
      fBottom: pressure
      fTop: pressure
    }
  if node.splitDirection == 'h'
    left = updateNode(node.left, width * node.fraction, height, dt)
    right = updateNode(node.right, width * (1 - node.fraction), height, dt)
    force = left.fRight - right.fLeft
    delta = UPDATE_SPEED * dt * force / width
    node.fraction += delta
    console.log node.fraction
    if node.fraction < 0 then node.fraction = 0
    if node.fraction > 1 then node.fraction = 1
    return {
      fLeft: left.fLeft
      fRight: right.fRight
      fBottom: left.fBottom + right.fBottom
      fTop: left.fTop + right.fTop
    }
  else
    top = updateNode(node.left, width, height * node.fraction, dt)
    bottom = updateNode(node.right, width, height * (1 - node.fraction), dt)
    force = top.fBottom - bottom.fTop
    delta = UPDATE_SPEED * dt * force / width
    node.fraction += delta
    console.log node.fraction
    if node.fraction < 0 then node.fraction = 0
    if node.fraction > 1 then node.fraction = 1
    return {
      fLeft: top.fLeft + bottom.fLeft
      fRight: top.fRight + bottom.fRight
      fBottom: bottom.fBottom
      fTop: top.fTop
    }

updateBoard = (board, dt) ->
  updateNode(board.root, board.width, board.height, dt)

