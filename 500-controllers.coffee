UPDATE_SPEED = 2.0
MAX_FORCE = 0.1
MIN_FRACTION = 0.001
MAX_FRACTION = 0.999

Math.clamp = (min, max, x) ->
  if x < min then return min
  if x > max then return max
  return x

# Returns force on left, right, bottom, top in outward direction
updateNode = (node, width, height, dt) ->
  if node instanceof Field
    pressure = node.gas * node.heat / (width * height)
    node.pressure = pressure
    return {
      fLeft: pressure * height
      fRight: pressure * height
      fBottom: pressure * width
      fTop: pressure * width
    }
  if node.splitDirection == 'v'
    left = updateNode(node.left, width * node.fraction, height, dt)
    right = updateNode(node.right, width * (1 - node.fraction), height, dt)
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
    top = updateNode(node.left, width, height * node.fraction, dt)
    bottom = updateNode(node.right, width, height * (1 - node.fraction), dt)
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

updatePositions = (node, x, y, width, height) ->
  if node instanceof Field
    node.x = x
    node.y = y
    node.width = width
    node.height = height
  else
    if node.splitDirection == 'v'
      updatePositions(node.left, x, y, width * node.fraction, height)
      updatePositions(node.right, x + width * node.fraction, y, width * (1 - node.fraction), height)
    else
      updatePositions(node.left, x, y, width, height * node.fraction)
      updatePositions(node.right, x, y + height * node.fraction, width, height * (1 - node.fraction))

updateBoard = (board, dt) ->
  updateNode(board.root, board.width, board.height, dt)
  updatePositions(board.root, 0, 0, board.width, board.height)

randomBoard = (width, height, numSplits, numHot, numCold, numTargets) ->
  board = new Board(width, height, new Field(100, 1))
  hv = ['h', 'v']
  for i in [0...numSplits]
    field = board.randomField()
    parent = field.parent
    range = 0.7 * Math.pow(0.7, field.getDepth())
    fraction = 0.5 * (1 - range) + Math.random() * range
    split = field.split(hv[i % 2], fraction)
    if parent == undefined
      board.root = split
    else
      if parent.left == field
        parent.left = split
      else if parent.right == field
        parent.right = split

  # Add heat/cold and targets
  for i in [0...numHot]
    board.randomField((field) -> field.heat == 1).heat = HOT
  for i in [0...numCold]
    board.randomField((field) -> field.heat == 1).heat = COLD
  for i in [0...numTargets]
    board.randomField((field) -> field.heat == 1).isTarget = true

  # Compute balanced situation
  f = (node) ->
    if node instanceof Field
      return node.gas * node.heat
    else
      left = f(node.left)
      right = f(node.right)
      node.fraction = left / (left + right)
      return left + right
  f(board.root)
  console.log board

  # Find target positions
  updatePositions(board.root, 0, 0, board.width, board.height)
  for target in board.getFields() when target.isTarget
    board.targets.push({ x: target.x, y: target.y, width: target.width, height: target.height })

  # Remove heat again
  for field in board.getFields()
    field.heat = 1

  # Initialize randomly for cool effect
  for split in board.getSplits()
    split.fraction = Math.random()

  return board

