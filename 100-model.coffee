GARDEN_WIDTH = 960
GARDEN_HEIGHT = 600

# These determine the shape of the rake
RAKE_P = 33
RAKE_Q = RAKE_P + 141

# For grabbing it
RAKE_LENGTH = 203
RAKE_WIDTH = 53

RAKE_TOOTH_START = 12
RAKE_TOOTH_STEP = 25.5
RAKE_TEETH = 6

RAKE_START_X = 20
RAKE_START_Y = GARDEN_HEIGHT / 2
RAKE_START_ANGLE = -1/4 * Math.PI
HANDLE_SIZE = 300
ANGULAR_STEP = 2*Math.PI / 360
DEBUG = window.location.hostname == 'localhost'

class Rake
  rotationOrigin: null

  # List of line segments to use for collisioning
  segments: [
    [{x: RAKE_P, y: RAKE_P}, {x: RAKE_Q, y: RAKE_P}]
    [{x: RAKE_P, y: RAKE_P}, {x: RAKE_P, y: RAKE_Q}]
  ]

  # x and y are the top left
  # angle is in radians, 0 is horizontal
  constructor: (@x, @y, @angle) ->
    if @x == undefined then @x = RAKE_START_X
    if @y == undefined then @y = RAKE_START_Y
    if @angle == undefined then @angle = RAKE_START_ANGLE
    @targetAngle = @angle
    @teeth = ({x: RAKE_P + RAKE_TOOTH_START + RAKE_TOOTH_STEP * i, y: RAKE_P} for i in [0...RAKE_TEETH])
    @teeth = @teeth.concat({x: RAKE_P, y: RAKE_P + RAKE_TOOTH_START + RAKE_TOOTH_STEP * i} for i in [0...RAKE_TEETH])

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
    S = 18
    @dentCanvas = $("<canvas width='#{S}' height='#{S}'>")[0]
    dentCtx = @dentCanvas.getContext('2d')
    @bumpCanvas = $("<canvas width='#{S}' height='#{S}'>")[0]
    bumpCtx = @bumpCanvas.getContext('2d')
    did = dentCtx.createImageData(S, S)
    bid = bumpCtx.createImageData(S, S)
    i = 0
    for y in [0...S]
      for x in [0...S]
        dx = x - S/2
        dy = y - S/2
        d = Math.sqrt(dx*dx + dy*dy) / (S/2)
        pos = 255 * 0.5 * (0.5 - 0.5 * Math.cos(2 * Math.PI * Math.min(d, 1)))
        neg = 255 * Math.clamp(0, 1, 1 - 2*d)
        did.data[i+0] = 0
        did.data[i+1] = 255
        did.data[i+2] = 0
        did.data[i+3] = neg
        bid.data[i+0] = 255
        bid.data[i+1] = 0
        bid.data[i+2] = 0
        bid.data[i+3] = pos
        i += 4
    dentCtx.putImageData(did, 0, 0)
    bumpCtx.putImageData(bid, 0, 0)

    @canvas = $("<canvas width='#{GARDEN_WIDTH}' height='#{GARDEN_HEIGHT}'>")[0]
    @ctx = @canvas.getContext('2d')
    @clear()

  clear: ->
    @ctx.fillStyle = '#000'
    @ctx.globalCompositeOperation = 'source-over'
    @ctx.fillRect(0, 0, @canvas.width, @canvas.height)
    if sandCtx
      sandCtx.clearRect(0, 0, GARDEN_WIDTH, GARDEN_HEIGHT)

  dent: (pos) ->
    @ctx.globalCompositeOperation = 'lighter'
    x = Math.round(pos.x - @dentCanvas.width / 2)
    y = Math.round(pos.y - @dentCanvas.height / 2)
    @ctx.drawImage(@dentCanvas, x, y)
    @ctx.drawImage(@bumpCanvas, x, y)
    @drawTo(sandCtx, {x: x - 1, y: y - 1, width: @dentCanvas.width + 2, height: @dentCanvas.height + 2})

  drawText: (text, x, y) ->
    @ctx.font = "40px 'Short Stack'"
    @ctx.fillStyle = '#f00'
    d = 3
    for [dx, dy] in [[-d, 0], [d, 0], [0, -d], [0, d]]
      @ctx.fillText(text, x + dx, y + dy)
    @ctx.fillStyle = '#0f0'
    @ctx.fillText(text, x, y)
    @drawTo(sandCtx)

  drawTo: (ctx, rect) ->
    if !rect then rect = {x: 1, y: 1, width: GARDEN_WIDTH-2, height: GARDEN_HEIGHT-2}
    rect.x = Math.max(1, rect.x)
    rect.y = Math.max(1, rect.y)
    rect.width = Math.min(GARDEN_WIDTH - 1 - rect.x, rect.width)
    rect.height = Math.min(GARDEN_HEIGHT - 1 - rect.y, rect.height)
    return if rect.width <= 0 || rect.height <= 0
    input = @ctx.getImageData(rect.x - 1, rect.y - 1, rect.width + 2, rect.height + 2)
    output = ctx.createImageData(rect.width, rect.height)
    index = (x, y) -> 4 * ((rect.width + 2) * y + x)
    i = 0
    c = index(0, 0)
    l = index(0, 1)
    r = index(2, 1)
    t = index(1, 0)
    b = index(1, 2)
    light = @light
    posNeg = (pos, neg) -> pos - (neg/255) * (neg + pos)
    for y in [0...rect.height]
      for x in [0...rect.width]
        vl = posNeg(input.data[l], input.data[l+1])
        vr = posNeg(input.data[r], input.data[r+1])
        vt = posNeg(input.data[t], input.data[t+1])
        vb = posNeg(input.data[b], input.data[b+1])
        dc = input.data[c+1]
        dx = 0.25 * (vl - vr) / 255
        dy = 0.25 * (vt - vb) / 255
        dot = light.x * dx + light.y * dy
        random = Math.abs(Math.sin(dot * 78.233 + x * 12.9898 + y * 23.957) * 43758.5453) % 1.0
        f = Math.clamp(-0.7, 0.7, Math.sin(dot) + 0.2 * (random - 0.5))
        int = if f < 0 then 64 else 255
        alpha = 255 * Math.abs(f)
        output.data[i] = int
        output.data[i+1] = int
        output.data[i+2] = int
        output.data[i+3] = alpha
        c += 4
        i += 4
        l += 4
        r += 4
        t += 4
        b += 4
      c += 8
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
  score: 0

  constructor: (@rake, @rocks, @par) ->
    @sand = new Sand()

  dump: ->
    lines = []
    lines.push "-> new Garden(new Rake(),"
    lines.push '['
    for rock in @rocks
      if rock.x > 0 && rock.y > 0
        index = (i for i in [0...rocks.length] when rocks[i].sprite == rock.sprite)[0]
        lines.push "rocks[#{index}].at(#{rock.x}, #{rock.y}),"
    lines.push ']),'
    console.log lines.join(' ')

