MessageBus  = require './lib/bus'   # Require event bus
Store       = require './lib/store' # Require store
App         = require './lib/app'   # Require application
IRC         = require 'irc'         # Require irc library


app = new App MessageBus, Store, IRC
app.on 'error', console.log

MessageBus.bus.debug = true
