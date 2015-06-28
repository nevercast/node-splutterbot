EventEmitter = require('events').EventEmitter

initSettings = (settings) ->
  defaultSettings =
    networks: [
      esper:
        nickname: 'splutter',
        username: 'Splutter',
        realname: 'SplutterBot'
        channels: ['#splutterbot']
        servers: [
          host: 'irc.esper.net'
          port: 6697
          secure: true
        ,
          host: 'irc.esper.net'
          port: 6667
        ]
    ]
    permissions: [
      provider: 'nickserv'
      network: 'esper'
      ident: 'nevercast'
      access: 10
    ,
      provider: 'channelops'
      network: 'esper'
      ident: '#splutterbot'
      access: 7
    ,
      provider: 'channelops'
      network: 'esper'
      ident: '#cloudbot'
      access: 5
    ]
  for key, value of defaultSettings
    # Check store, set if missing.
    ((key, value) -> # Create a function scope for the loop.
      settings.get key, (err, result) ->
        if err or typeof result isnt 'object'
          console.log "Info: Settings was missing key #{key}. Loaded default."
          settings.set key, value
    ) key, value


module.exports = class App extends EventEmitter
  constructor: (@Bus, @Store, @IRC) ->
    @Settings = @Store.createStore 'settings', true
    initSettings @Settings
    @TestClient = new @IRC.Client 'irc.esper.net', 'splutter',
      userName  : 'SplutterBot'
      realName  : 'nevercast/node-splutterbot'
      channels  : ['#splutterbot']
      secure    : true,
      port      : 6697
    @NetBus = @Bus.context 'Net'
    @NetBus.consume @TestClient, true
    @NetBus.on 'netError', (errorDetails...) -> @emit 'error', errorDetails...
