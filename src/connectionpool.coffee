{createClient} = require './client2'

class ConnectionPool
    constructor: (@mailers) ->
        @connections = {}
        @_process(@mailers)

    _process: (mailers) ->
        for mailer in mailers
            @connections[mailer] = @_bindMailer(mailer)
        return

    _bindMailer: (mailer) ->
        self = this
        return do (mailer) ->
            obj = createClient mailer, self
            obj.on 'error', ->
                return
            return obj
            
    addToPool: (client) ->
        @connections[client.fullHostName] = client

    removeFromPool: (client) ->
        delete @connections[client.fullHostName]

    getConnections: ->
        @connections

    getPoolSize: ->
        if typeof @connections.length is 'undefined' then 0 else @connections.length

    connect: (host, callback) ->
        if not @connections[host]
            client = createClient host, this
            #log client.connection
            client.on 'connect', ->
                self.addToPool client
                callback true
                return
            client.on 'error', ->
                callback false
                return
        else
            callback false

        return

exports.createConnectionPool = (args...) ->
    new ConnectionPool args...

