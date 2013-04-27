class Board
  constructor: (@width, @height, @root) ->

class Split
  constructor: (@splitDirection, @fraction, @left, @right) ->

class Field
  constructor: (@gas, @heat) ->

  split: (direction, fraction) ->
    # returns a split with new left/right nodes,
    # which the caller use to replace this Field