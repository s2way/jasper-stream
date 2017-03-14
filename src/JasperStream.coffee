path = require 'path'

class JasperStream

    jarPath = path.join __dirname, '..', '/bin/jasper-report.jar'

    push: (records, params, callback) ->
        log = (msg, info) ->
            console.log 'Jasper says:', msg, info

        if records?
            jasper = require('child_process').spawn 'java', ['-jar', jarPath, '', "#{JSON.stringify(params)}"]
        else
            jasper = require('child_process').spawn 'java', ['-jar', jarPath, "#{JSON.stringify(params)}"]

        destination = require('fs').createWriteStream "#{params.file_path}"

        destination.on 'error', (error) ->
            log 'destination error', error
            callback error: error

        jasper.stdin.on 'error', (error) ->
            log 'stdin error', error
            callback error: error

        jasper.stdout.on 'error', (error) ->
            log 'stdout error', error
            callback error: error

        jasper.stdout.on 'data', (data) ->
            destination.write data

        jasper.stdout.on 'end', ->
            jasper.stdin.end()
            destination.end()
            callback null, params.file_path


        jasper.stdin.write JSON.stringify(records), 'utf8'


module.exports = JasperStream
