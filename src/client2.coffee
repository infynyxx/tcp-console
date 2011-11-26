net = require 'net'
{log} = require './util'
{createConnectionPool} = require './connectionpool'
{EventEmitter} = require 'events'

class Client extends EventEmitter
    constructor: (@fullHostName, @connectionPool) ->
        @retryCount = 0
        @connection
        @setup()

    setup: ->
        hostInfo = @fullHostName.split ':'
        if hostInfo.length isnt 2
            log 'Invalid host: ' + @fullHostName
            process.exit 1
        @port = parseInt(hostInfo[1])
        @host = hostInfo[0]

        if isNaN @port
            log 'Invalid host: ' + @fullHostName
            process.exit 1

        @connection = @connect()

        self = this

        @connection.on 'close', ->
            log ''
            log 'connection closed for ' + self.fullHostName
            process.exit 1

        @connection.on 'data', (data) ->
            self.emit 'data', data
            return

        @connection.on 'error', (err) ->
            #log JSON.stringify err
            self.connectionPool.removeFromPool self
            self.error = true
            self.emit 'error'
            return
        
        @connection.on 'connect', ->
            self.connectionPool.addToPool self
            self.emit 'connect'
        
        @connection.on 'end', ->
            return

        return

    connect: (is_retry = false) ->
        connection = net.createConnection @port, @host
        connection.setEncoding 'utf-8'
        #connection.setNoDelay()
        connection

exports.createClient = (args...) ->
    new Client args...
