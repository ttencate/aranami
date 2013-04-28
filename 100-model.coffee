RAKE_LENGTH = 360
RAKE_WIDTH = 60
HANDLE_SIZE = 300
MAX_ANGULAR_VELOCITY = 0.001

class Rake
  rotationOrigin: null

  # x and y are the top left
  # angle is in radians, 0 is horizontal
  constructor: (@x, @y, @angle) ->
    @targetAngle = @angle

  toLocal: (pos) ->
    dx = pos.x - @x
    dy = pos.y - @y
    return {
      x: dx * Math.cos(@angle) + dy * Math.sin(@angle)
      y: -dx * Math.sin(@angle) + dy * Math.cos(@angle)
    }

  toGlobal: (local) ->
    return {
      x: @x + local.x * Math.cos(@angle) - local.y * Math.sin(@angle)
      y: @y + local.x * Math.sin(@angle) + local.y * Math.cos(@angle)
    }

class Rock
  constructor: (@x, @y) ->

class Garden
  constructor: (@rake, @rocks) ->
