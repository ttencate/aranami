HOT = 2.0
COLD = 0.3

class Board
  constructor: (@width, @height, @root) ->

  getFields: ->
    fields = []
    f = (node) ->
      if node instanceof Field
        fields.push(node)
      else
        f(node.left)
        f(node.right)
    f(@root)
    return fields

  findField: (x,y) ->
    for field in @getFields()
      if x >= field.x and y >= field.y and x <= field.x + field.width and y <= field.y + field.height
        return field

  meanPressure: ->
    fields = @getFields()
    total = fields.reduce (sum, field) ->
      sum + field.pressure
    , 0
    total / fields.length


class Split
  parent: undefined

  constructor: (@splitDirection, @fraction, @left, @right) ->
    @left.parent = this
    @right.parent = this

class Field
  parent: undefined

  # Filled by updateBoard()
  x: undefined
  y: undefined
  width: undefined
  height: undefined

  constructor: (@gas, @heat) ->

  split: (direction, fraction) ->
    left = new Field(fraction * @gas, @heat)
    right = new Field((1 - fraction) * @gas, @heat)
    return new Split(direction, fraction, left, right)

  cycleHeat: ->
    if @heat == 1.0
      @heat = HOT
    else if @heat == HOT
      @heat = COLD
    else
      @heat = 1.0

  isHot: ->
    @heat > 1

  isCold: ->
    @heat < 1

  getDepth: ->
    depth = 0
    parent = @parent
    while parent
      parent = parent.parent
      depth++
    return depth
