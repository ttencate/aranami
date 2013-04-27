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

    fillRed   = 255 - (field.pressure * 100000)
    fillGreen = 255 - (field.pressure * 100000)
    fillBlue  = 255 - (field.pressure * 100000)

    heat = (field.heat - 1) * 50
    if heat > 0
      fillBlue = fillBlue - heat
      fillGreen = fillGreen - heat
    else if heat < 0
      fillRed   = fillRed + heat
      fillGreen = fillGreen + heat

    @context.fillStyle   = 'rgba(' + Math.round(fillRed) + ', ' + Math.round(fillGreen) + ', ' + Math.round(fillBlue) + ', 1)'
    @context.lineWidth = @strokeWidth
    @context.fillRect field.x, field.y, field.width, field.height
    @context.strokeRect field.x, field.y, field.width, field.height

