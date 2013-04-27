UPDATE_SPEED = 1000.0

# Returns force on left, right, bottom, top in outward direction
updateNode = (node, x, y, width, height, dt) ->
  if node instanceof Field
    pressure = node.gas * node.heat / (width * height)
    node.x = x
    node.y = y
    node.width = width
    node.height = height
    return {
      fLeft: pressure
      fRight: pressure
      fBottom: pressure
      fTop: pressure
    }
  if node.splitDirection == 'h'
    left = updateNode(node.left, x, y, width * node.fraction, height, dt)
    right = updateNode(node.right, x + width * node.fraction, y, width * (1 - node.fraction), height, dt)
    force = left.fRight - right.fLeft
    delta = UPDATE_SPEED * dt * force / width
    node.fraction += delta
    if node.fraction < 0 then node.fraction = 0.001
    if node.fraction > 1 then node.fraction = 0.999
    return {
      fLeft: left.fLeft
      fRight: right.fRight
      fBottom: left.fBottom + right.fBottom
      fTop: left.fTop + right.fTop
    }
  else
    top = updateNode(node.left, x, y, width, height * node.fraction, dt)
    bottom = updateNode(node.right, x, y + height * node.fraction, width, height * (1 - node.fraction), dt)
    force = top.fBottom - bottom.fTop
    delta = UPDATE_SPEED * dt * force / width
    node.fraction += delta
    if node.fraction < 0 then node.fraction = 0.001
    if node.fraction > 1 then node.fraction = 0.999
    return {
      fLeft: top.fLeft + bottom.fLeft
      fRight: top.fRight + bottom.fRight
      fBottom: bottom.fBottom
      fTop: top.fTop
    }

updateBoard = (board, dt) ->
  updateNode(board.root, 0, 0, board.width, board.height, dt)

randomBoard = (width, height, numSplits) ->
  board = new Board(width, height, new Field(100, 1))
  for i in [0...numSplits]
    fields = board.getFields()
    index = Math.floor(Math.random() * fields.length)
    field = fields[index]
    parent = field.parent
    split = field.split((if Math.random() < 0.5 then 'h' else 'v'), Math.random())
    if parent == undefined
      board.root = split
    else
      if parent.left == field
        parent.left = split
      else
        parent.right = split
  return board

