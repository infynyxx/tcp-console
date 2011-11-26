debug = true

exports.debug = debug

exports.log = (str) ->
    str = str.trim("\n") if typeof str is 'string'
    console.log str

exports.debugLog = (str) ->
    console.log str if debug is true
