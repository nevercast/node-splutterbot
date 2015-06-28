EventEmitter = require('events').EventEmitter
module.exports = class App extends EventEmitter
  constructor: (@Bus, @Store, @IRC) ->
    @TestClient = new @IRC.Client 'irc.esper.net', 'splutter',
      userName  : 'SplutterBot'
      realName  : 'nevercast/node-splutterbot'
      channels  : ['#splutterbot']
      secure    : true,
      port      : 6697
    @NetBus = @Bus.context 'Net'
    @NetBus.consume @TestClient, true
    @NetBus.on 'netError', (errorDetails...) -> @emit 'error', errorDetails...
