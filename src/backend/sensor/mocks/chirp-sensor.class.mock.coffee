HISTORY_LENGTH = 30
WATERLEVELS = ['Dry', 'Moist', 'Wet']

inspect = require('util').inspect
chalk = require('chalk')

moment = require('moment')
async = require('async')
debugSensorChrip = require('debug')('sensor:water')

SensorMock = require('./sensor.class.mock.js')
socketIoMessenger = require('../../_socket-io/socket-io-messenger.js')
logger = require('../../_logger/logger.js').getLogger()

class ChirpSensorMock extends SensorMock
  constructor: (options, callback) ->
    debugSensorChrip "Chirp sensor mock #{options._id}"
    that = @
    super options, (err)->
      async.eachSeries that.detectors,
        (detector, next)->
          detector.min = 0
          detector.max = 2
          detector.round = true
          detector.change = 10
          that.seedSensor detector, HISTORY_LENGTH, null, ->
            that.boot (err)->
              that.readSensor()
              next err
        callback null, that

  boot: (callback)->
    setTimeout ()->
      return callback()
    , 100

  readSensor: ()->
    self = @
    waterLevel = self.randSensorValue @.detectors[0]
    debugSensorChrip "WATERLEVEL: #{WATERLEVELS[waterLevel]} #{moment().format('hh:mm:ss DD-MM-YYYY')}"
    self.processSensorValue(self.detectors[0], waterLevel, ->)
    setTimeout ()->
      self.readSensor()
    , self.sensorReadIntervall
    return

#/////////////////////////////////////////////////////////////////////////////////////////////////////
module.exports = ChirpSensorMock