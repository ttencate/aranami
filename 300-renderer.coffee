class Renderer
  constructor: (@board, @canvas) ->
    @canvas.width(@board.width)
    @canvas.height(@board.height)
    @context = @canvas[0].getContext('2d')
    @lastUpdate = Date.now()

  render: =>
    now = Date.now()
    delta = now - @lastUpdate
    @lastUpdate = now

    @context.setTransform 1, 0, 0, 1, 0, 0
    @context.clearRect 0, 0, @board.width, @board.height

    for field in @board.getFields()
      @renderNode field

  renderNode: (field) =>
    @context.strokeStyle = 'rgba(0,0,0,1)'
    @context.fillStyle = 'rgba(1,1,1,1)'
    @context.fillRect field.x, field.y, field.width, field.height

