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

if !DEBUG
  startTimer = ->
  endTimer = ->

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
    S = 16
    w = S/2 + 1
    h = S
    @dentCanvas = $("<canvas width='#{w}' height='#{h}'>")[0]
    dentCtx = @dentCanvas.getContext('2d')
    id = dentCtx.createImageData(w, h)
    i = 0
    for y in [0...h]
      for x in [0...w]
        dx = x - 1
        dy = y - S/2
        d = Math.sqrt(dx*dx + dy*dy) / (S/2)
        int = 255 * (0.37 - 0.37 * Math.cos(2*Math.PI*Math.min(1, d*d)) + 0.5*d*d)
        alpha = 255 * Math.clamp(0, 1, 3 - 3*d)
        id.data[i+0] = int
        id.data[i+1] = int
        id.data[i+2] = int
        id.data[i+3] = alpha
        i += 4
    dentCtx.putImageData(id, 0, 0)

    @canvas = $("<canvas width='#{GARDEN_WIDTH}' height='#{GARDEN_HEIGHT}'>")[0]
    @ctx = @canvas.getContext('2d')
    @clear()

  clear: ->
    @ctx.fillStyle = '#808080'
    @ctx.globalCompositeOperation = 'source-over'
    @ctx.fillRect(0, 0, @canvas.width, @canvas.height)
    if sandCtx
      sandCtx.clearRect(0, 0, GARDEN_WIDTH, GARDEN_HEIGHT)

  drawDents: (poss) ->
    startTimer('drawDents')
    minX = GARDEN_WIDTH
    minY = GARDEN_HEIGHT
    maxX = 0
    maxY = 0
    for pos in poss
      @ctx.save()
      @ctx.translate(pos.x, pos.y)
      @ctx.rotate(pos.angle)
      @ctx.drawImage(@dentCanvas, -1, -@dentCanvas.height / 2 - 0.5)
      @ctx.restore()
      minX = Math.min(minX, pos.x)
      minY = Math.min(minY, pos.y)
      maxX = Math.max(maxX, pos.x)
      maxY = Math.max(maxY, pos.y)
    startTimer('drawDents drawTo')
    S = @dentCanvas.height
    @drawTo(sandCtx, {
      x: minX - S/2 - 1, y: minY - S/2 - 1, width: maxX - minX + S + 2, height: maxY - minY + S + 2
    })
    endTimer()
    endTimer()

  drawRocks: (rocks) ->
    for rock in rocks
      for [w, c] in [[15, '#ccc'], [13, '#fff'], [11, '#ccc'], [9, '#888'], [7, '#444'], [5, '#000']]
        for i in [0...4]
          r = rock.radius - 18 + 12*i
          @ctx.lineWidth = w
          @ctx.strokeStyle = c
          @ctx.beginPath()
          @ctx.arc(rock.x, rock.y, r, 0, 2*Math.PI, false)
          @ctx.stroke()

  drawPlank: ->
    x = 855 + 2
    y = 125 + 2
    w = 100 - 4
    h = 350 - 6
    @ctx.lineJoin = 'round'
    for [l, c] in [[15, '#aaa'], [13, '#ccc'], [11, '#ccc'], [9, '#888'], [7, '#444'], [5, '#000']]
      @ctx.lineWidth = l
      @ctx.strokeStyle = c
      @ctx.strokeRect(x, y, w, h)
    @ctx.fillStyle = '#000'
    @ctx.fillRect(x, y, w, h)

  drawText: (text, x, y, size, redraw) ->
    redraw = true if redraw == undefined
    onFontLoaded =>
      size = size || 40
      @ctx.font = "#{size}px 'Short Stack'"
      @ctx.fillStyle = '#fff'
      d = 3
      for [dx, dy] in [[-d, 0], [d, 0], [0, -d], [0, d]]
        @ctx.fillText(text, x + dx, y + dy)
      @ctx.fillStyle = '#000'
      @ctx.fillText(text, x, y)
      @drawTo(sandCtx) if redraw

  drawPoint: (point) ->
    onFontLoaded =>
      @ctx.save()
      @ctx.translate(-10 + 15 * point, 45)
      if point % 5 == 0
        @ctx.translate(-60, -10)
        @ctx.rotate(0.35 * Math.PI)
        @ctx.scale(0.8, 1.8)
      @ctx.translate(2 * (Math.random() - 0.5), 2 * (Math.random() - 0.5))
      @ctx.scale(1, 1 + 0.1 * (Math.random() - 0.5))
      @drawText('1', 0, 0, 50)
      @ctx.restore()

  drawTo: (ctx, rect) ->
    startTimer('drawTo')
    if !rect then rect = {x: 1, y: 1, width: GARDEN_WIDTH-2, height: GARDEN_HEIGHT-2}
    rect.x = Math.max(1, Math.floor(rect.x))
    rect.y = Math.max(1, Math.floor(rect.y))
    rect.width = Math.min(GARDEN_WIDTH - 1 - rect.x, Math.ceil(rect.width + 1))
    rect.height = Math.min(GARDEN_HEIGHT - 1 - rect.y, Math.ceil(rect.height + 1))
    if rect.width <= 0 || rect.height <= 0
      endTimer()
      return
    startTimer('getImageData')
    input = @ctx.getImageData(rect.x - 1, rect.y - 1, rect.width + 2, rect.height + 2)
    inputData = input.data
    endTimer()
    startTimer('createImageData')
    output = ctx.createImageData(rect.width, rect.height)
    outputData = output.data
    endTimer()
    startTimer('sandLoop')
    index = (x, y) -> 4 * ((rect.width + 2) * y + x)
    i = 0
    l = index(0, 1)
    r = index(2, 1)
    t = index(1, 0)
    b = index(1, 2)
    lightX = @light.x
    lightY = @light.y
    for y in [0...rect.height]
      ay = rect.y + y
      for x in [0...rect.width]
        ax = rect.x + x
        vl = inputData[l]
        vr = inputData[r]
        vt = inputData[t]
        vb = inputData[b]
        vc = 0.25 * (vl+vr+vt+vb)
        dx = 0.25 * (vl - vr) / 255
        dy = 0.25 * (vt - vb) / 255
        dot = lightX * dx + lightY * dy
        a = ax + GARDEN_WIDTH*ay + vl + vr + vt + vb
        random = (a*2654435761 % 0x100000000) / 0x100000000
        lightness = (2 * dot - 0.1 * Math.max(0, (128-vc) / 128))
        if vc != 128
          lightness += 0.2 * (random - 0.5)
        int = if lightness < 0 then 64 else 255
        alpha = 255 * Math.abs(lightness)
        outputData[i] = int
        outputData[i+1] = int
        outputData[i+2] = int
        outputData[i+3] = alpha
        i += 4
        l += 4
        r += 4
        t += 4
        b += 4
      l += 8
      r += 8
      t += 8
      b += 8
    endTimer()
    startTimer('putImageData')
    ctx.putImageData(output, rect.x, rect.y)
    endTimer()
    endTimer()

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

