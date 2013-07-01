window.WorkoutTimer = class WorkoutTimer
  constructor: ->
    @startAt = 0
    @state = "unstarted"
    @time = 0
    @reverse = false
    @pausedAt = 0
    @tickFn = ->
    @finishFn = ->
    @counter = 0
    @lastTick = 0

  currentTime: -> new Date() / 1000

  getCounter: ->
    if @reverse
      @time - @counter
    else
      @counter

  start: ->
    @state = "running"
    @countDownFn()

  unpause: =>
    @state = "running"
    @countDownFn()

  countDownFn: (obj) =>
    fn = =>
      @updateTime()
      if @finished()
        @state = "finished"
        @tickFn(@counter)
        @finishFn(@counter)
      else
        @tickFn(@counter)
      if @state == "running"
        setTimeout(fn, 50)
    fn()

  finished: =>
    @counter >= @time

  updateTime: =>
    current = @currentTime()
    if @state == "running"
      @counter += current - @lastTick
      @counter = Math.min(@counter, @time) # Don't go over the time limit
      @lastTick = current

  percentDone: ->
    @getCounter() / @time * 100

  setReverse: (input) =>
    console.log "reverse setting to #{input}"
    @reverse = input

  setTime: (t) =>
    @time = t

  getTime: => @time

  go: =>
    @lastTick = @currentTime()
    if @state == "paused"
      @unpause()
    else if @state == "unstarted"
      @start()

  pause: =>
    if @state != "paused"
      @pausedAt = @currentTime()
      @state = "paused"

  getState: => @state

  onTick: (fn)   => @tickFn = fn
  onFinish: (fn) => @finishFn = fn

