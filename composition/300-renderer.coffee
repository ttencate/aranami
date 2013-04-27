class Renderer
  strokeWidth: 10.0

  constructor: (@board, @canvas) ->
    @canvas[0].width = @board.width + @strokeWidth
    @canvas[0].height = @board.height + @strokeWidth
    @context = @canvas[0].getContext('2d')

  findField: (x, y) ->
    @board.findField(x * @board.width / @canvas[0].width, y * @board.height / @canvas[0].height)

  render: =>
    @context.setTransform 1, 0, 0, 1, 0, 0
    @context.clearRect 0, 0, @board.width, @board.height

    @context.translate(@strokeWidth/2, @strokeWidth/2)

    meanPressure = @board.meanPressure()

    for target in @board.getTargets()
      @renderTarget target
    for field in @board.getFields()
      @renderNode field, meanPressure

    @context.translate(-@strokeWidth/2, -@strokeWidth/2)

  renderNode: (field, meanPressure) =>
    @context.strokeStyle = 'rgba(0, 0, 0, 1)'

    if field.isTarget
      @context.fillStyle = 'yellow'
    else
      pressure = Math.abs (field.pressure - meanPressure) * 400000
      fillRed   = 255 - pressure
      fillGreen = 255 - pressure
      fillBlue  = 255 - pressure
      opacity   = 0

      heat = (field.heat - 1) * 50
      if field.isHot()
        fillBlue  = 0
        fillGreen = 0
        opacity   = 0.4
      else if field.isCold()
        fillRed   = 0
        fillGreen = 0
        opacity   = 0.4

      @context.fillStyle   = 'rgba(' + Math.round(fillRed) + ', ' + Math.round(fillGreen) + ', ' + Math.round(fillBlue) + ', ' + opacity + ')'

    @context.lineWidth = @strokeWidth
    @context.fillRect field.x, field.y, field.width, field.height
    @context.strokeRect field.x, field.y, field.width, field.height

  renderTarget: (field) =>
    @context.fillStyle = 'rgba(255, 255, 0, 0.3)'
    @context.fillRect field.x, field.y, field.width, field.height



