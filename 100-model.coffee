RAKE_LENGTH = 360
RAKE_WIDTH = 60
HANDLE_SIZE = 300

class Rake
  # x and y are the top left
  # angle is in radians, 0 is horizontal
  constructor: (@x, @y, @angle) ->

  toLocal: (x, y) ->
    dx = x - @x
    dy = y - @y
    return {
      x: dx * Math.cos(@angle) + dy * Math.sin(@angle)
      y: -dx * Math.sin(@angle) + dy * Math.cos(@angle)
    }

class Rock
  constructor: (@x, @y) ->

class Garden
  constructor: (@rake, @rocks) ->
