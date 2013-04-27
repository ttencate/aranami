UPDATE_SPEED = 2.0
MAX_FORCE = 0.1
MIN_FRACTION = 0.001
MAX_FRACTION = 0.999

Math.clamp = (min, max, x) ->
  if x < min then return min
  if x > max then return max
  return x

# Returns force on left, right, bottom, top in outward direction
updateNode = (node, x, y, width, height, dt) ->
  if node instanceof Field
    pressure = node.gas * node.heat / (width * height)
    node.x = x
    node.y = y
    node.width = width
    node.height = height
    node.pressure = pressure
    return {
      fLeft: pressure * height
      fRight: pressure * height
      fBottom: pressure * width
      fTop: pressure * width
    }
  if node.splitDirection == 'v'
    left = updateNode(node.left, x, y, width * node.fraction, height, dt)
    right = updateNode(node.right, x + width * node.fraction, y, width * (1 - node.fraction), height, dt)
    force = left.fRight - right.fLeft
    force = Math.clamp(-MAX_FORCE, MAX_FORCE, force)
    delta = UPDATE_SPEED * dt * force / width
    node.fraction += delta
    node.fraction = Math.clamp(MIN_FRACTION, MAX_FRACTION, node.fraction)
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
    force = Math.clamp(-MAX_FORCE, MAX_FORCE, force)
    delta = UPDATE_SPEED * dt * force / width
    node.fraction += delta
    node.fraction = Math.clamp(MIN_FRACTION, MAX_FRACTION, node.fraction)
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
  hv = ['h', 'v']
  for i in [0...numSplits]
    fields = board.getFields()
    index = Math.floor(Math.random() * fields.length)
    field = fields[index]
    parent = field.parent
    range = 0.7 * Math.pow(0.7, field.getDepth())
    fraction = 0.5 * (1 - range) + Math.random() * range
    split = field.split(hv[i % 2], fraction)
    split.fraction = Math.random()
    if parent == undefined
      board.root = split
    else
      if parent.left == field
        parent.left = split
      else if parent.right == field
        parent.right = split
  return board

