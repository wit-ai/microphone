navigator.getUserMedia =
  navigator.getUserMedia ||
  navigator.webkitGetUserMedia ||
  navigator.mozGetUserMedia ||
  navigator.msGetUserMedia

window.AudioContext =
  window.AudioContext ||
  window.webkitAudioContext ||
  window.mozAudioContext ||
  window.msAudioContext


do ->
  w = window
  for vendor in ['ms', 'moz', 'webkit', 'o']
      break if w.requestAnimationFrame
      w.requestAnimationFrame = w["#{vendor}RequestAnimationFrame"]
      w.cancelAnimationFrame = (w["#{vendor}CancelAnimationFrame"] or
                                w["#{vendor}CancelRequestAnimationFrame"])

  # deal with the case where rAF is built in but cAF is not.
  if w.requestAnimationFrame
      return if w.cancelAnimationFrame
      browserRaf = w.requestAnimationFrame
      canceled = {}
      w.requestAnimationFrame = (callback) ->
          id = browserRaf (time) ->
              if id of canceled then delete canceled[id]
              else callback time
      w.cancelAnimationFrame = (id) -> canceled[id] = true

  # handle legacy browsers which don’t implement rAF
  else
      targetTime = 0
      w.requestAnimationFrame = (callback) ->
          targetTime = Math.max targetTime + 16, currentTime = +new Date
          w.setTimeout (-> callback +new Date), targetTime - currentTime

      w.cancelAnimationFrame = (id) -> clearTimeout id

log = if /debug/.test(window.location.search)
  (-> console.log.apply(console, arguments))
else
  ->

WitError = (message, infos) ->
  @name = "WitError"
  @message = (message || "")
  @infos = infos
  return @
WitError.prototype = Error.prototype

WEBSOCKET_HOST = 'wss://api.wit.ai/speech_ws'

Microphone = (elem) ->
  # object state
  @conn  = null
  @ctx   = new AudioContext()
  @state = 'disconnected'
  @rec   = false

  # methods
  @handleError = (e) ->
    if _.isFunction(f = @onerror)
      err = if _.isString(e)
        e
      else if _.isString(e.message)
        e.message
      else
        "Something went wrong!"

      f.call(window, err, e)
  @handleResult = (res) ->
    if _.isFunction(f = @onresult)
      intent   = res.outcome.intent
      entities = res.outcome.entities
      f.call(window, intent, entities, res)

  # DOM setup
  if elem
    @elem = elem

    elem.innerHTML = """
      <div class='mic mic-box icon-wit-mic'>
      </div>
      <svg class='mic-svg mic-box'>
      </svg>
    """
    elem.className += ' wit-microphone'
    elem.addEventListener 'click', (e) =>
      @fsm('toggle_record')

    svg = @elem.children[1]
    ns  = "http://www.w3.org/2000/svg"
    @path = document.createElementNS(ns, 'path')
    @path.setAttribute('stroke', '#eee')
    @path.setAttribute('stroke-width', '5')
    @path.setAttribute('fill', 'none')
    svg.appendChild(@path)

  # DOM methods
  @rmactive = ->
    if @elem
      @elem.classList.remove('active')
  @mkactive = ->
    if @elem
      @elem.classList.add('active')
  @mkthinking = ->
    @thinking = true
    if @elem
      style = getComputedStyle(svg)
      @elem.classList.add('thinking')
      w = parseInt(style.width, 10)
      h = parseInt(style.height, 10)
      b = if style.boxSizing == 'border-box'
        parseInt(style.borderTopWidth, 10)
      else
        0
      r = w/2-b-5
      T = 1000 # msecs
      from_x = w/2-b
      from_y = h/2-b-r
      xrotate = 0
      swf  = 1 # sweep flag (anticw=0, clockwise=1)
      start = window.performance?.now() || new Date
      tick = (time) =>
        rads = (((time-start)%T)/T) * 2*Math.PI - Math.PI/2
        to_x = Math.cos(rads)*r+w/2-b
        to_y = Math.sin(rads)*r+h/2-b
        laf  = +(1.5*Math.PI > rads > Math.PI/2) # large arc flag (smallest=0 or largest=1 is drawn)
        @path.setAttribute('d', "M#{from_x},#{from_y}A#{r},#{r},#{xrotate},#{laf},#{swf},#{to_x},#{to_y}")

        if @thinking
          requestAnimationFrame tick
        else
          @elem.classList.remove('thinking')
          @path.setAttribute('d', 'M0,0')

      requestAnimationFrame tick

  @rmthinking = ->
    @thinking = false

  return this

states =
  disconnected:
    connect: (token) ->
      if not token
        @handleError('No token provided')

      # websocket
      conn = new WebSocket(WEBSOCKET_HOST)
      conn.onopen = (e) =>
        conn.send(JSON.stringify(["auth", token]))
      conn.onclose = (e) =>
        @fsm('socket_closed')
      conn.onmessage = (e) =>
        [type, data] = JSON.parse(e.data)

        if data
          @fsm.call(this, type, data)
        else
          @fsm.call(this, type)

      @conn = conn

      # webrtc
      on_stream = (stream) =>
        ctx  = @ctx
        src  = ctx.createMediaStreamSource(stream)
        proc = (ctx.createScriptProcessor || ctx.createJavascriptNode).call(ctx, 4096, 1, 1)
        proc.onaudioprocess = (e) =>
          return unless @rec
          bytes = e.inputBuffer.getChannelData(0)
          @conn.send(bytes)

        src.connect(proc)
        proc.connect(ctx.destination)

        # NECESSARY HACK: prevent garbage-collection of these guys
        @stream = stream
        @proc   = proc
        @src    = src

        # @cleanup = ->
        #   src.disconnect()
        #   proc.disconnect()
        #   stream.stop()

        @fsm('got_stream')

      navigator.getUserMedia(
        { audio: true },
        on_stream,
        @handleError
      )
      'connecting'
  connecting:
    'auth-ok': -> 'waiting_for_stream'
    got_stream: -> 'waiting_for_auth'
    error: (err) ->
      @handleError(err)
      'connecting'
    socket_closed: -> 'disconnected'
  waiting_for_auth:
    'auth-ok': -> 'ready'
  waiting_for_stream:
    got_stream: -> 'ready'
  ready:
    socket_closed: -> 'disconnected'
    timeout: -> 'ready'
    start: -> @fsm('toggle_record')
    toggle_record: ->
      @conn.send(JSON.stringify(["start", @context || {}]))
      @rec = true
      console.error "No context" if !@ctx
      console.error "No stream" if !@stream
      console.error "No source" if !@src
      console.error "No processor" if !@proc

      'audiostart'
  audiostart:
    error: (data) ->
      @rec = false
      @handleError(new WitError("Error during recording", code: 'RECORD', data: data))
      'ready'
    socket_closed: ->
      @rec = false
      'disconnected'
    stop: -> @fsm('toggle_record')
    toggle_record: ->
      # if _.isFunction(f = @cleanup)
      #   f()
      #   @cleanup = null

      @rec = false
      @conn.send(JSON.stringify(["stop"]))
      @timer = setTimeout (=> @fsm('timeout')), 7000

      'audioend'
  audioend:
    socket_closed: ->
      clearTimeout(@timer) if @timer
      'disconnected'
    timeout: ->
      @handleError(new WitError('Wit timed out', code: 'TIMEOUT'))
      'ready'
    error: (data) ->
      clearTimeout(@timer) if @timer
      @handleError(new WitError('Wit did not recognize intent', code: 'RESULT', data: data))
      'ready'
    result: (data) ->
      clearTimeout(@timer) if @timer
      @handleResult(data)
      'ready'

Microphone.prototype.fsm = (event) ->
  f   = states[@state]?[event]
  ary = Array.prototype.slice.call(arguments, 1)
  if _.isFunction(f)
    s   = f.apply(this, ary)
    log "fsm: #{@state} + #{event} -> #{s}", ary
    @state = s

    if s in ['audiostart', 'audioend', 'ready']
      if _.isFunction(f = this['on' + s])
        f.call(window)

    switch s
      when 'disconnected'
        @rmthinking()
        @rmactive()
      when 'ready'
        @rmthinking()
        @rmactive()
      when 'audiostart'
        @mkactive()
      when 'audioend'
        @mkthinking()
        @rmactive()
  else
    log "fsm error: #{@state} + #{event}", ary

  s

Microphone.prototype.connect = (token) ->
  @fsm('connect', token)

Microphone.prototype.start = ->
  @fsm('start')

Microphone.prototype.stop = ->
  @fsm('stop')

Microphone.prototype.setContext = (context) ->
  @context ||= {}
  for k, v of context
    @context[k] = context[k]
  log 'context: ', @context
  null

# utils
window._     ||= {}
_.isFunction ||= (x) -> (typeof x) == 'function'
_.isString   ||= (obj) -> toString.call(obj) == '[object String]'

window.Wit   ||= {}
Wit.Microphone = Microphone
