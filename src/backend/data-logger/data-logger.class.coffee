STATISTIC_INTERVALL = 48 * 60 * 60 * 1000

inspect = require('util').inspect
chalk = require('chalk')

mongoose = require('mongoose')
async = require('async')
_ = require('lodash')
moment = require('moment')

ObjectId = require('mongoose').Types.ObjectId
SensorData = require('./sensor-data.model.js').getModel()
EventModel = require('./event.model.js').getModel()

socketIoMessenger = require('../_socket-io/socket-io-messenger.js')
logger = require('../_logger/logger.js').getLogger()

class DataLogger
  constructor: (options) ->
    @.buildStatistic()
    return

#--------------------------- Statistic & Clean up --------------------------------------
  buildStatistic: ()-> # builds a statistic and removes values older than 48h
    setTimeout ()->
      #todo first build a statistic
      EventModel.remove(timestamp: {$gt: moment().subtract(48, 'hours')}).exec (err)->
        logger.error if err?
    , STATISTIC_INTERVALL

#--------------------------------------------- Events (Outputs) --------------------------------------
  createEvent: (output, state, info, callback)->
    eventData = {
      state: state
      output: output._id
      timestamp: moment().toDate()
    }
    eventData.info = info if info?
    newEvent = new EventModel(eventData)
    newEvent.save (err, result) ->
      logger.error err if err?
      EventModel.findOne({_id: result._id}).populate('output').lean().exec (err, eventFound)->
        return callback err if err?
        socketIoMessenger.sendMessage('eventData', {'payload':eventFound})
        return callback()

  readEvents: (filterReadEvents, options, callback)-> #todo LAST LIMIT
    query = EventModel.find(filterReadEvents).sort({"timestamp":-1})

    if options.limit?
      query = query.limit(options.limit)

    if options.populate?.output?
      query = query.populate('output', {})

    query.exec callback
#--------------------------------------------- Data (Sensors) --------------------------------------
  createSensorData: (sensorId, detector, callback)->
    sensorData = {value: detector.currentValue['y'], timestamp: detector.currentValue['x']}
    sensorData.detectorType = detector.type
    sensorData.sensor = sensorId
    newSensorData = new SensorData(sensorData)

    newSensorData.save (err, result) ->
      logger.error err if err?
      return callback()

  clearEvents: (filterClearEvents, options, callback)->
    EventModel.remove({}).exec callback

#///////////////////////////////////////////////////////////////////////////////////////////////////
module.exports = DataLogger
