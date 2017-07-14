inspect = require('util').inspect
chalk = require('chalk')

Datalogger = require('../data-logger.class.js')

class DataloggerMock extends Datalogger
  constructor: (options) ->
    that = @
    super(options)
    return

  buildStatistic: ()->
    return null

  createEvent: (output, state, info, callback)->
    return calback()

  readEvents: (filterReadEvents, options, callback)->
    return calback()

  createSensorData: (sensorId, detector, callback)->
    return callback()

#/////////////////////////////////////////////////////////////////////////////////////////////////////
module.exports = DataloggerMock