EventEmitter = require('events').EventEmitter

class Bus extends EventEmitter

  # Set max listeners if value exists
  constructor: (@limit) ->
    @setMaxListeners @limit if @limit

  emit : (event, args...) ->
    console.log 'EventBus DEBUG', event if @debug
    super event, args...

# Bus context prefixes a bus with a name
class BusContext
  constructor: (@bus, context) ->
    @prefix = context + ':' if context

  _prefixEvent: (event) ->
    return @prefix + event if @prefix
    @event

  # Add listeners
  addListener : (event, cb) -> @bus.on @_prefixEvent(event), cb
  on : (event, cb) -> @addListener event, cb
  once : (event, cb) -> @bus.once @_prefixEvent(event), cb

  # Emit events
  emit : (event, args...) -> @bus.emit @_prefixEvent(event), args...

  # Remove listener
  removeListener : (event) -> @bus.removeListener @_prefixEvent(event)

  # Create a sub-context
  context : (subContext) ->
    subContext = @prefix + subContext if @prefix
    new BusContext @bus, subContext

  # Consume another EventEmitter in to our context
  consume : (eventEmitter, proxy) ->
    oldEmitter = eventEmitter.emit
    eventEmitter.unconsume = ->
      eventEmitter.emit = oldEmitter
    eventEmitter.emit = (event, args...) =>
      @emit event, args...
      oldEmitter.call eventEmitter, event, args... if proxy

module.exports = new BusContext new Bus 1000
module.exports.Bus = Bus
module.exports.BusContext = BusContext
