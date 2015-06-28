Redis = require 'redis'

module.exports =
  # Create a Store
  # (name:string) Store name
  # [isPersistent:boolean] Is this store saved to Redis
  createStore : (name, isPersistent) ->
    isPersistent = isPersistent is true and typeof Redis isnt 'undefined'
    throw new Error 'Expected name to be string' if typeof name isnt 'string'
    return new Store name, isPersistent
  # MemoryStorage is a timestamping key-value store
  # All keys are stamped with the current time in ms.
  # hasExpired can be used to see if the value is old.
  # Intended use is a memory cache for a backing IO store.
  MemoryStorage : class MemoryStorage
    # Object containing key-value data
    @data : {}
    # Construct a new MemoryStorage
    # [msExpirationTime:number] Optional default timeout. Sets @timeout
    constructor: (msExpirationTime) ->
      if typeof msExpirationTime is 'number'
        @timeout = msExpirationTime
    # Returns all the keys in storage.
    getKeys: -> Object.keys @data
    # Has an object expired
    # (key:string) Key of the object
    # [msExpirationTime:number] Optional expiration time. Defaults to @timeout
    hasExpired: (key, msExpirationTime) ->
      maxAge = typeof msExpirationTime is 'number' ? msExpirationTime : \
               @timeout
      # If there is no timeout, we always expire
      # If the key is missing, return expired (Cache_Miss)
      if typeof maxAge isnt 'number' or not @has key
        return false
      else
        return Date.now() - @data[key].timestamp >= maxAge
    # Does the store contain a key
    # (key:string) Key to check for
    has: (key) -> @data.hasOwnProperty key
    # Get a key
    # (key:string) Name of the object's key.
    # (callback:function) Callback fired with result. Delegate: (error, result)
    get: (key, callback) ->
      if @has key
        cachedValue = @data[key].value
        process.nextTick -> callback(null, cachedValue)
      else
        process.nextTick -> callback new Error 'No record found'
    # Set a key in the store
    # (key:string) Name of the object to set
    # (value:object) The value to store by key
    set: (key, value) ->
      if @has key
        @data[key].timestamp = Date.now()
        @data[key].value = value
      else
        @data[key] =
          timestamp: Date.now()
          value: value
  # Main store class
  Store: class Store
    # Create a new store
    # (name:string) Name of the store
    # (isPersistent:boolean) Is the store backed by Redis or memory only
    constructor: (@name, @isPersistent) ->
      @cache = new MemoryStorage 5000
      if Redis and @isPersistent
        # Create redis client.
        @redisClient = Redis.createClient detect_buffers: true
        @redisClient.on 'error', (error) ->
          console.log "Warning: Redis[#{@name}] encountered an error\n" + \
                      error + '\n' + \
                      'Reconnection will be attempted.'
        @redisClient.on 'ready', ->
          console.log "Notice: Redis[#{@name}] is ready for data access."
        @redisClient.on 'end', ->
          console.log "Notice: Redis[#{@name}] connection was closed."
    isOnline: -> @isPersistent and @redisClient and @redisClient.connected
    get: (key, callback) ->
      # If the cache misses and Redis is available
      if @cache.hasExpired key and @isOnline
        # Fetch from Redis
        @redisClient.get key, (err, result) ->
          # Write the value in to the cache if no errors
          @cache.set key, result if not err
          # Pass it on to our callback
          callback err, result
      else
        # We are offline or the cache hit
        # Pass the key and callback to the cache for handling.
        @cache.get key, callback
    set: (key, value) ->
      # Log it into our cache.
      @cache.set key, value
      # If we are persistent, send the request to Redis. Online or not.
      @redisClient.set key, value if @isPersistent and @redisClient

# If Redis was not available, notify the user.
if typeof Redis is 'undefined'
  console.log \
  'Notice: Redis was not found, persistent storage will not be unavailable.'
