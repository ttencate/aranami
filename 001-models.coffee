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
      @heat = 1.5
    else if @heat == 1.5
      @heat = 0.5
    else
      @heat = 1.0
