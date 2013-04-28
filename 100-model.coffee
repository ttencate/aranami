GARDEN_WIDTH = 960
GARDEN_HEIGHT = 600
RAKE_LENGTH = 203
RAKE_WIDTH = 53
RAKE_TEETH = 12
HANDLE_SIZE = 300
MAX_ANGULAR_VELOCITY = 0.002
DEBUG = true

class Rake
  rotationOrigin: null

  # List of line segments to use for collisioning
  segments: [
    [{x: 1, y: 2}, {x: RAKE_LENGTH - 1, y: 2}]
  ]

  teeth: ({x: 1 + (RAKE_LENGTH - 1) / (RAKE_TEETH - 1) * i, y: 2} for i in [0...RAKE_TEETH])

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
    S = 16
    @dentCanvas = $("<canvas width='#{S}' height='#{S}'>")[0]
    ctx = @dentCanvas.getContext('2d')
    id = ctx.createImageData(S, S)
    i = 0
    for y in [0...S]
      for x in [0...S]
        dx = x - S/2
        dy = y - S/2
        d = Math.sqrt(dx*dx + dy*dy) / (S/2)
        int = 255 * d*d
        alpha = 255 * (1 - d*d*d)
        id.data[i++] = int
        id.data[i++] = int
        id.data[i++] = int
        id.data[i++] = alpha
    ctx.putImageData(id, 0, 0)

    @canvas = $("<canvas width='#{GARDEN_WIDTH}' height='#{GARDEN_HEIGHT}'>")[0]
    @ctx = @canvas.getContext('2d')
    @clear()

  clear: ->
    @ctx.fillStyle = '#808080'
    @ctx.globalCompositeOperation = 'source-over'
    @ctx.fillRect(0, 0, @canvas.width, @canvas.height)

  dent: (pos) ->
    x = Math.round(pos.x - @dentCanvas.width / 2)
    y = Math.round(pos.y - @dentCanvas.height / 2)
    @ctx.drawImage(@dentCanvas, x, y)
    @drawTo(sandCtx, {x: x - 1, y: y - 1, width: @dentCanvas.width + 2, height: @dentCanvas.height + 2})

  drawTo: (ctx, rect) ->
    if !rect then rect = {x: 1, y: 1, width: GARDEN_WIDTH-1, height: GARDEN_HEIGHT-1}
    rect.x = Math.max(1, rect.x)
    rect.y = Math.max(1, rect.y)
    rect.width = Math.min(GARDEN_WIDTH - 1 - rect.x, rect.width)
    rect.height = Math.min(GARDEN_WIDTH - 1 - rect.y, rect.height)
    input = @ctx.getImageData(rect.x - 1, rect.y - 1, rect.width + 2, rect.height + 2)
    output = ctx.createImageData(rect.width, rect.height)
    index = (x, y) -> 4 * ((rect.width + 2) * y + x)
    i = 0
    l = index(0, 1)
    r = index(2, 1)
    t = index(1, 0)
    b = index(1, 2)
    light = @light
    for y in [0...rect.height]
      for x in [0...rect.width]
        dx = 0.5 * (input.data[l] - input.data[r]) / 255
        dy = 0.5 * (input.data[t] - input.data[b]) / 255
        if dx != 0 || dy != 0
          dot = light.x * dx + light.y * dy
          f = Math.sin(dot)
          int = if f < 0 then 0 else 255
          alpha = 2 * 255 * Math.abs(f)
          output.data[i] = int
          output.data[i+1] = int
          output.data[i+2] = int
          output.data[i+3] = alpha
        i += 4
        l += 4
        r += 4
        t += 4
        b += 4
      l += 8
      r += 8
      t += 8
      b += 8
    ctx.putImageData(output, rect.x, rect.y)

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

  dump: ->
    lines = []
    lines.push "-> new Garden(new Rake(-30 + 20 + RAKE_WIDTH, 300 - RAKE_LENGTH/2, 0.5 * Math.PI),"
    lines.push '['
    for rock in @rocks
      if rock.x > 0 && rock.y > 0
        index = (i for i in [0...rocks.length] when rocks[i].sprite == rock.sprite)[0]
        lines.push "rocks[#{index}].at(#{rock.x}, #{rock.y}),"
    lines.push ']'
    console.log lines.join(' ')

