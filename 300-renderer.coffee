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
    $(".container").prepend "<div class='rock " + rock.sprite + "' style='left:" + rock.y + 'px; top:'  + rock.x + "px'></div>"
  updateDom()