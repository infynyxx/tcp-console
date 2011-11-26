commander = require 'commander'
{createConsole} = require './tcp-console'

exports.main = ->
    commander
        .version('0.0.1')
        .option('-s, --server [value]', 'Select mailer')
        #.option('-m, --mailers [value]', 'Select mailers')
        .option('-c, --config-file [value]', 'Configuration file')
        .parse(process.argv)

    options =
        mailer: if commander.server then commander.server else null
        mailers: if commander.mailers then commander.mailers else null
        config: if commander.configFile then commander.configFile else null

    if options.mailer is null and options.mailers is null
        console.log 'Specify a server'
        process.exit 1

    c = createConsole options
    c.initialize()
