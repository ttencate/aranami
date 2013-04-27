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
