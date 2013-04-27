HOT = 2.0
COLD = 0.3

class Board
  targets: []

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

  getSplits: ->
    splits = []
    f = (node) ->
      if node instanceof Split
        splits.push(node)
        f(node.left)
        f(node.right)
    f(@root)
    return splits

  getTargets: ->
    return @targets

  findField: (x,y) ->
    for field in @getFields()
      if x >= field.x and y >= field.y and x <= field.x + field.width and y <= field.y + field.height
        return field

  randomField: (predicate) ->
    if predicate
      fields = (field for field in @getFields() when predicate(field))
    else
      fields = @getFields()
    if fields == []
      throw "No fields match!"
    index = Math.floor(Math.random() * fields.length)
    return fields[index]

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

  isTarget: false

  constructor: (@gas, @heat) ->

  split: (direction, fraction) ->
    left = new Field(fraction * @gas, @heat)
    right = new Field((1 - fraction) * @gas, @heat)
    return new Split(direction, fraction, left, right)

  cycleHeat: ->
    return false if @isTarget

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
