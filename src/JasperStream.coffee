path = require 'path'

class JasperStream

    jarPath = path.join __dirname, '..', '/bin/jasper-report.jar'

    push: (records, params, callback) ->
        if records?
            jasper = require('child_process').spawn 'java', ['-jar', jarPath, '', "#{JSON.stringify(params)}"]
        else
            jasper = require('child_process').spawn 'java', ['-jar', jarPath, "#{JSON.stringify(params)}"]

        destination = require('fs').createWriteStream "#{params.file_path}"
        error = require('fs').createWriteStream 'err.log'

        destination.on 'error', (data) ->
            console.log 'destination error', data
            error.write "Destination error: #{data}"

        jasper.stdin.on 'error', (data) ->
            console.log 'stdin error', data
            error.write "Stdin error: #{data}"

        jasper.stdout.on 'error', (data) ->
            console.log 'stdout error', data
            error.write "Stdout error: #{data}"

        jasper.stdout.on 'data', (data) ->
            destination.write data

        jasper.stdout.on 'end', ->
            destination.end()
            callback()

        jasper.stdin.write JSON.stringify(records), 'utf8'

module.exports = JasperStream
