class Renderer
  strokeWidth: 10.0

  constructor: (@board, @canvas) ->
    @canvas[0].width = @board.width + @strokeWidth
    @canvas[0].height = @board.height + @strokeWidth
    @context = @canvas[0].getContext('2d')

  render: =>
    @context.setTransform 1, 0, 0, 1, 0, 0
    @context.clearRect 0, 0, @board.width, @board.height

    @context.translate(@strokeWidth/2, @strokeWidth/2)
    for field in @board.getFields()
      @renderNode field
    @context.translate(-@strokeWidth/2, -@strokeWidth/2)


  renderNode: (field) =>
    @context.strokeStyle = 'rgba(0, 0, 0, 1)'

    pressure = Math.abs (field.pressure - @board.meanPressure()) * 400000
    fillRed   = 255 - pressure
    fillGreen = 255 - pressure
    fillBlue  = 255 - pressure

    heat = (field.heat - 1) * 50
    if field.isHot()
      fillBlue = 0
      fillGreen = 0
    else if field.isCold()
      fillRed   = 0
      fillGreen = 0

    @context.fillStyle   = 'rgba(' + Math.round(fillRed) + ', ' + Math.round(fillGreen) + ', ' + Math.round(fillBlue) + ', 1)'
    @context.lineWidth = @strokeWidth
    @context.fillRect field.x, field.y, field.width, field.height
    @context.strokeRect field.x, field.y, field.width, field.height

