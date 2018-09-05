APP_PATH = process.env.APP_PATH

inspect = require('util').inspect
chalk = require('chalk')
debugSystemSupport = require('debug')('system:support')

async = require('async')
fs = require('fs')
# archiver = require('archiver')
# streamBuffers = require('stream-buffers')

apiEndpoints = require('../_api/api-endpoints.js')()
shellService  = require('../shell/shell.service.js')
restHelper = require('../_api/rest.helper.js')

# readLogs = (callback)->

#   input = fs.createReadStream("../../logs/test")

#   input.on 'error', (err) ->
#     return callback err

#   output = new streamBuffers.WritableStreamBuffer()

#   output.on 'close', () ->
#     console.log(archive.pointer() + ' total bytes')
#     console.log('archiver has been finalized and the output file descriptor has closed.')

#   output.on 'end', () ->
#     console.log('Data has been drained')
#     return callback null, output

#   output.on 'error', (err) ->
#     return callback err

#   input.pipe output
#   input.pipe null


@.sendLogs = (options, callback)->
  return callback "APP_PATH not configured operation not possible" if !process.env.APP_PATH?
  logZipPath = "#{APP_PATH}/logs/logs.tar.gz"
  async.waterfall [
    (next)->
      shellService.mongoDump next
    (status, next)->
      debugSystemSupport "Created mongodump: ", inspect status
      shellService.getSerial next
    (serial, next)->
      debugSystemSupport "Serial: ", serial
      shellService.zipLogs (err)->
        return next err if err?
        return next null, serial
    (serial, next)->
      fs.stat logZipPath, (err, stats)->
        return next err if err?
        debugSystemSupport "Logs are: #{stats.size/ 1000000.0} mb"
        return next null, serial
    (serial, next)->
      fs.readFile logZipPath, (err, buffer)->
        debugSystemSupport "Zipped logs"
        return next err, serial, buffer
    (serial, logs, next)->
      method = 'POST'
      url = "#{apiEndpoints['support']}/#{serial}"
      data = { logs: logs}
      debugSystemSupport "Sending logs for serial #{serial}"
      restHelper.emit method, url, data, next
  ], callback




