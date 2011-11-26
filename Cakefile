require.paths.unshift "#{__dirname}/node_modules"

{spawn, exec} = require 'child_process'
{print} = require 'sys'

build = (watch, callback) ->
    if typeof watch is 'function'
        callback = watch
        watch = false
    options = ['-c', '-o', 'lib', 'src']
    options.unshift '-w' if watch

    coffee = spawn 'coffee', options
    coffee.stdout.on 'data', (data) ->
        print data.toString()
    coffee.stderr.on 'data', (data) ->
        print data.toString()
    coffee.on 'exit', (status) ->
        callback?() if status is 0

deploy = (branch = 'master') ->
    git_pull = exec 'ssh sailthru@ec2-184-72-234-254.compute-1.amazonaws.com "cd /home/sailthru/jmailer-console && git checkout master && git pull origin ' + branch + '"', (error, stdout, stderr) ->
        print "stdout: " + stdout.toString()
        print "error: " + error + "\n" if error isnt null
        print "stderr: " + stderr.toString()

        if error is null
            rsync_cmd = "rsync -a --delete --force /home/sailthru/jmailer-console sailthru@ec2-east-midway:/home/sailthru"
            rsync = exec 'ssh sailthru@ec2-184-72-234-254.compute-1.amazonaws.com "' + rsync_cmd + '" ', (error2, stdout2, stderr2) ->
                print "stdout: " + stdout2.toString()
                print "error: " + error2 + "\n" if error2 isnt null
                print "stderr: " + stderr2.toString()
            return
        print "\n"
    return
   
task 'build', 'Compile CoffeScript source files', ->
    build()

task 'watch', 'Recompile CoffeScript when source files are modified', ->
    build true

task 'test', 'Run the test suite', ->
    build ->
        require.paths.unshift __dirname + '/lib'
        {reporters} = require 'nodeunit'
        process.chdir __dirname
        reporters.default.run ['test']

task 'deploy', 'Deploy', ->
    deploy()
    return
