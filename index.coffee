#!coffee
require 'coffee-script/register'  # Register coffee-script handler
Bus = require('./lib/bus').global # Require event bus
IRC = require 'irc'               # Require irc library

# Debugging the eventbus
Bus.bus.debug = true

# Create IRC client
Client = new IRC.Client 'irc.esper.net', 'splutter',
  userName  : 'SplutterBot'
  realName  : 'nevercast/node-splutterbot'
  channels  : ['#cloudbot']
  ssl       : true,
  port      : 6697

# Create two bus namespaces
Bot = Bus.context 'bot'
Net = Bus.context 'net'

# Make our Net namespace consume Client events
Net.consume Client, true
