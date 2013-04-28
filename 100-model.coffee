RAKE_LENGTH = 203
RAKE_WIDTH = 53
HANDLE_SIZE = 300
MAX_ANGULAR_VELOCITY = 0.002
DEBUG = true

class Rake
  rotationOrigin: null

  # List of line segments to use for collisioning
  segments: [
    [{x: 1, y: 2}, {x: RAKE_LENGTH - 1, y: 2}]
  ]

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
  x: undefined
  y: undefined

  constructor: (@radius, @sprite) ->

  at: (x, y) ->
    rock = new Rock(@radius, @sprite)
    rock.x = x
    rock.y = y
    return rock

class Garden
  constructor: (@rake, @rocks) ->
