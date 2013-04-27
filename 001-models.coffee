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
  constructor: (@splitDirection, @fraction, @left, @right) ->

class Field
  # Filled by updateBoard()
  x: undefined
  y: undefined
  width: undefined
  height: undefined
  
  constructor: (@gas, @heat) ->

  split: (direction, fraction) ->
    # returns a split with new left/right nodes,
    # which the caller use to replace this Field
