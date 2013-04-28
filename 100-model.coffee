GARDEN_WIDTH = 800
GARDEN_HEIGHT = 600
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

class Sand
  light: {x: Math.cos(2/3 * Math.PI), y: -Math.sin(2/3 * Math.PI)}

  constructor: ->
    @canvas = $("<canvas width='#{GARDEN_WIDTH}' height='#{GARDEN_HEIGHT}'>")[0]
    @ctx = @canvas.getContext('2d')
    @clear()

  clear: ->
    @ctx.fillStyle = '#808080'
    @ctx.fillRect(0, 0, @canvas.width, @canvas.height)
    @ctx.beginPath()
    @ctx.moveTo(100, 100)
    @ctx.lineTo(200, 100)
    @ctx.lineWidth = 10
    @ctx.stroke()

  drawTo: (ctx) ->
    input = @ctx.getImageData(0, 0, GARDEN_WIDTH, GARDEN_HEIGHT)
    output = ctx.createImageData(GARDEN_WIDTH, GARDEN_HEIGHT)
    index = (x, y) -> 4 * (GARDEN_WIDTH * y + x)
    i = index(1, 1)
    l = index(0, 1)
    r = index(2, 1)
    t = index(1, 0)
    b = index(1, 2)
    light = @light
    for y in [1...GARDEN_HEIGHT-1]
      for x in [1...GARDEN_WIDTH-1]
        dx = 0.5 * (input.data[l] - input.data[r]) / 255
        dy = 0.5 * (input.data[t] - input.data[b]) / 255
        if dx != 0 || dy != 0
          dot = light.x * dx + light.y * dy
          f = Math.sin(dot)
          int = if f < 0 then 0 else 255
          alpha = 255 * Math.abs(f)
          output.data[i] = int
          output.data[i+1] = int
          output.data[i+2] = int
          output.data[i+3] = alpha
        i += 4
        l += 4
        r += 4
        t += 4
        b += 4
      i += 8
      l += 8
      r += 8
      t += 8
      b += 8
    ctx.putImageData(output, 0, 0)

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
    @sand = new Sand()

