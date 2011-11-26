readline = require 'readline'
prefix = 'MAILER> '
{log} = require './util'
#{createClient} = require './client2'
{createConnectionPool} = require './connectionpool'

class TConsole
    constructor: (options) ->
        @mailers = @parseOptions options
        @connectionPool = createConnectionPool @mailers
        @lastActiveHost = @mailers[0] if options.mailer and @connectionPool.connections[@mailers[0]]?
        @welcomeMessage = '***Welcome to TCP Console***'
        @prefix = 'CONSOLE> '

    initialize: ->
        self = this
        log @welcomeMessage
        @readline = readline.createInterface process.stdin, process.stdout
        @readline.on 'line', (cmd) ->
            self.parseCommand cmd
        @readline.on 'close', ->
            process.stdout.write '\n'
            process.exit 0

        for mailer, client of @connectionPool.getConnections()
            client.on 'data', (data) ->
                log data
                self.prompt()

        @prompt()
        return
        

    _request: (host, cmd, callback) ->
        self = this
        buffer = new Buffer cmd + '\n'
        client = @connectionPool.connections[host]
        writeBuffer = (client) ->
            client.connection.write buffer, 'utf-8', ->
                self.setLastActiveHost host
                callback()
                return
            return

        if client
            writeBuffer client
        else
            @connectionPool.connect host, (response) ->
                if response is true
                    writeBuffer(self.connectionPool.connections[host])
                    self.connectionPool.connections[host].on 'data', (data) ->
                        log data
                        self.prompt()
                else
                    callback()
                    log "Can't connect to " + host
                    self.prompt()
                    return
        return

    _requestWithHost: (host, command, callback) ->
        @_request host, command, callback
        return

    _requestWithoutHost: (command, callback) ->
        #log @lastActiveHost
        if typeof @lastActiveHost is 'undefined'
            log 'Please specify a mailer to connect.'
            return undefined
        @_request @lastActiveHost, command, callback
        return

    parseCommand: (cmd, callback) ->
        cmd = cmd.trim()
        wait = false
        self = this
        switch cmd
            when 'help' then @helpMessage()
            when 'quit', 'exit'
                log 'Bye\n'
                process.exit 0
            else
                if not @lastActiveHost? || @connectionPool.mailers.length is 0
                    log 'Please specify a mailer to connect.'
                else
                    cb = ->
                        wait = true
                        return


                    @_requestWithoutHost cmd, cb
                                    
        @prompt() if wait is false

        return

    isMailerCommand: (cmd) ->
        commandRegex = /^{.*}/
        return commandRegex.exec(cmd) isnt null

    extractCommand: (cmd) ->
        commandRegex = /{.*}/
        commandRegex.exec(cmd)

    isShutdownCommand: (cmd) ->
        isShutdownCommand = false
        try
            jsonObj = JSON.parse cmd
            isShutdownCommand = true if jsonObj['action']? is 'shutdown'
        catch error
            return
        isShutdownCommand

    setLastActiveHost: (host) ->
        @lastActiveHost = host
        return

    helpMessage: ->
        log 'Nothing for now. But I will add soon'
        return

    prompt: ->
        length = @prefix.length
        @readline.setPrompt @prefix, length
        @readline.prompt()
        return
        
    parseOptions: (options) ->
        mailers = []
        
        if options.mailer
            mailers.push options.mailer
        else if options.mailers
            splits = options.mailers.split ','
            for mailer in splits
                mailers.push mailer
        else if options.configFile
            # read config file
            mailers = []
        return mailers

exports.createConsole = (args...) ->
    new TConsole args...
