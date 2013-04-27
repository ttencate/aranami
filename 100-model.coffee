RAKE_LENGTH = 360
RAKE_WIDTH = 60
HANDLE_SIZE = 300

class Rake
  # x and y are the top left
  # angle is in radians, 0 is horizontal
  constructor: (@x, @y, @angle) ->

class Garden
  constructor: (@rake) ->
