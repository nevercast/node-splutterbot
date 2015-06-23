#!coffee
require 'coffee-script/register'  # Register coffee-script handler
Bus = require('./lib/bus').global        # Require event bus
EventEmitter = require('events').EventEmitter

console.log Bus

Bus.bus.debug = true
Bot = Bus.context 'bot'
Admin = Bot.context 'admin'
Net = Bus.context 'net'

Bot.emit 'begin'
Admin.emit 'test nested context'


consumeable = new EventEmitter
consumeable.on 'Event', (a,b,c) -> console.log 'Consumable Handler',a,b,c

# When proxy is true, the original emitter still receives it's events
# If proxy is falsy or omitted, the original emitter does not receive them
Net.consume consumeable, true
Net.on 'Event', (a,b,c) -> console.log 'Consumed Event',a,b,c

consumeable.emit 'Event', 1,2,3

consumeable.unconsume()

consumeable.emit 'Event', 4,5,6
