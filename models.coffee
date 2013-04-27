class Board
  constructor: (@width, @height, @root) ->

class Split
  constructor: (@left, @right, @splitDirection, @fraction) ->

class Field
  constructor: (@gas, @heat) ->

  split: (direction, fraction) ->
    # returns a split with new left/right nodes,
    # which the caller use to replace this Field