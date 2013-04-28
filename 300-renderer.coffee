updateDom = ->
  rake = garden.rake
  $('.rake').css
    x: "#{rake.x}px"
    y: "#{rake.y}px"
    rotate: "#{rake.angle}rad"

loadLevel = (level) ->
  window.garden = level
  $(".rock").remove()
  for rock in level.rocks
    rockDiv = $("<div class='rock " + rock.sprite + "' style='left:" + rock.x + 'px; top:'  + rock.y + "px'></div>")
    if DEBUG
      ((rock) ->
        rockDiv.mousemove (e) ->
          if e.which == 1
            pos = $(this).position()
            x = pos.left + e.offsetX - 30
            y = pos.top + e.offsetY - 30
            rock.x = x
            rock.y = y
            $(this).css({left: "#{x}px", top: "#{y}px"})
            e.preventDefault()
      )(rock)
    $(".container").append rockDiv
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
