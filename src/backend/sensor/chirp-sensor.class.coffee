CMD_READ_WATER_LEVEL = 0x00 #2bytes
STATUS_DRY = 0
STATUS_WET = 2
WATERLEVELS = ['Dry', 'Moist', 'Wet']

# CMD_ACCESS_CONFIG = 0xac
# CMD_READ_TEMP = 0xaa
# CMD_START_CONVERT = 0xee

inspect = require('util').inspect
chalk = require('chalk')

moment = require('moment')
async = require('async')
debugSensorChrip = require('debug')('sensor:Water')

Sensor = require('./sensor.class.js')
socketIoMessenger = require('../_socket-io/socket-io-messenger.js')
logger = require('../_logger/logger.js').getLogger()

class ChirpSensor extends Sensor
  constructor: (options, callback) ->
    debugSensorChrip "Water sensor #{options._id}"
    that = @
    options.modes = {} if !options.modes?
    super options, (err)->
      that.boot (err)->
        return callback err if err?
        that.readSensor()
        return callback null, that

  boot: (callback)->
    setTimeout ()->
      return callback()
    , 100

  translateToHuman: (waterLevel)->
    waterLevel = Math.round waterLevel
    return "No valid waterlevel" if !waterLevel? || !WATERLEVELS[waterLevel-1]?
    return WATERLEVELS[waterLevel-1]

  readSensor: ()->
    self = @
    if @.i2c1?
      @.i2c1.readByte self.address, CMD_READ_WATER_LEVEL, (err, waterLevel) ->
        console.log chalk.bgRed err if err?
        if !err? && waterLevel?
          debugSensorChrip "WATERLEVEL: #{waterLevel} #{self.translateToHuman waterLevel} #{moment().format('hh:mm DD-MM-YYYY')}"
          self.processSensorValue(self.detectors[0], waterLevel, ->)
        setTimeout ()->
          self.readSensor()
        , self.sensorReadIntervall
        return
    else
      setTimeout ()->
        self.readSensor()
      , self.sensorReadIntervall
      return


#/////////////////////////////////////////////////////////////////////////////////////////////////////
module.exports = ChirpSensor