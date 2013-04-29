updateDom = ->
  rake = garden.rake
  $('.rake').css
    x: "#{rake.x}px"
    y: "#{rake.y}px"
    rotate: "#{rake.angle}rad"

makeRockDiv = (rock) ->
  rockDiv = $("<div class='rock " + rock.sprite + "' style='left:" + rock.x + 'px; top:'  + rock.y + "px'></div>")
  rockDiv.data('rock', rock)
  if DEBUG
    rockDiv.mousemove (e) ->
      if e.which == 2
        pos = $(this).position()
        x = pos.left + e.offsetX - 30
        y = pos.top + e.offsetY - 30
        rock.x = x
        rock.y = y
        $(this).css({left: "#{x}px", top: "#{y}px"})
        e.preventDefault()
        e.stopPropagation()
    rockDiv.mousedown (e) ->
      if e.which == 1 && e.ctrlKey
        rockDiv.remove()
        window.garden.rocks = (r for r in window.garden.rocks when r != rock)
  $(".container").append rockDiv
  return rockDiv

loadLevel = (level) ->
  window.garden = level
  window.score = 0
  $(".rock").remove()
  for rock in level.rocks
    rockDiv = makeRockDiv(rock)
  #$('#debug').append window.garden.sand.canvas
  updateDom()

renderDebug = ->
  ctx.lineWidth = 2

  for rock in garden.rocks
    ctx.beginPath()
    ctx.arc(rock.x, rock.y, rock.radius, 0, 360, true)
    ctx.stroke()

  rake = garden.rake
  for segment in rake.segments
    p = rake.toGlobal(segment[0])
    q = rake.toGlobal(segment[1])
    ctx.beginPath()
    ctx.moveTo(p.x, p.y)
    ctx.lineTo(q.x, q.y)
    ctx.stroke()
