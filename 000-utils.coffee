Math.clamp = (min, max, x) ->
  if x < min then return min
  if x > max then return max
  return x

Math.length = (v) ->
  return Math.sqrt(v.x * v.x + v.y * v.y)

Math.normalize = (v) ->
  n = Math.length(v)
  return {x: v.x / n, y: v.y / n}

Math.canonicalAngle = (rad) ->
  return ((rad % (2*Math.PI)) + (2*Math.PI)) % (2*Math.PI)

startTimes = []
times = {}
counts = {}
startTimer = (name) ->
  startTimes.push [name, Date.now()]
  counts[name] ||= 0
  counts[name]++
endTimer = ->
  endTime = Date.now()
  [name, startTime] = startTimes.pop()
  times[name] ||= 0
  times[name] += endTime - startTime
dumpTimes = ->
  for name, time of times
    count = counts[name]
    console.log "#{name} #{time} #{time / count}"
  return

