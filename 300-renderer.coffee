class Renderer
  constructor: (@board, @canvas) ->
    @canvas[0].width = @board.width
    @canvas[0].height = @board.height
    @context = @canvas[0].getContext('2d')

  render: =>
    @context.setTransform 1, 0, 0, 1, 0, 0
    @context.clearRect 0, 0, @board.width, @board.height

    for field in @board.getFields()
      @renderNode field

  renderNode: (field) =>
    @context.strokeStyle = 'rgba(0,0,0,1)'
    @context.fillStyle = 'rgba(1,1,1,1)'
    @context.fillRect field.x, field.y, field.width, field.height

