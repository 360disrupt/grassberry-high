CMD_READ_TEMPERATURE = 0x00 #2bytes
CMD_READ_HUMIDITY = 0x01 #2bytes
SENSOR_REGISTER = 0x02
BOOT_CMD = 0x30 #0x30(48)  Temperature, Humidity enabled, Resolultion = 14-bits, Heater on

inspect = require('util').inspect
chalk = require('chalk')

moment = require('moment')
async = require('async')
debugTemp = require('debug')('sensor:temp')
debugHumidity = require('debug')('sensor:humidity')

Sensor = require('./sensor.class.js')
systemRead = require('../system/system.read.js')
socketIoMessenger = require('../_socket-io/socket-io-messenger.js')
logger = require('../_logger/logger.js').getLogger()

class HDC1000Sensor extends Sensor #temperature/humidity
  constructor: (options, callback) ->
    debugTemp "Temp/Humdity sensor #{options._id}"
    that = @
    super options, (err)->
      systemOptions = {}
      systemRead.getSystem systemOptions, (err, system)->
        if system?.units?.temperature?
          that.temperatureMode = system.units.temperature
        else
          that.temperatureMode = 'celsius'

        that.boot (err)->
          return callback err if err?
          that.readSensor()
          return callback null, that


  boot: (callback)->
    self = @
    if @.i2c1?
      @.i2c1.writeByte @.address, SENSOR_REGISTER, BOOT_CMD, (err)->
        console.error "@boot hdc1000 sensor", err if err?
        return callback()
    else
      return callback("I2c not started can't boot hdc1000 sensor")

#--------------------------- Conversions ----------------------------------
  convertHumidity: (byte1, byte2)->
    humidity = (byte1 * 256) + byte2
    humidity = (humidity / 65536.0) * 100.0
    return humidity

  convertTemp: (byte1, byte2)->
    temp = (byte1 * 256) + byte2
    cTemp = (temp / 65536.0) * 165.0 - 40
    fTemp = cTemp * 1.8 + 32
    return {cTemp: cTemp, fTemp: fTemp}

#--------------------------- Read ----------------------------------
  readTemperature: (callback)->
    self = @
    async.waterfall [
      (next)->
        self.i2c1.sendByte self.address, CMD_READ_TEMPERATURE, (err) ->
          setTimeout next, 500
      (next)->
        self.i2c1.receiveByte self.address, next
      (byte1, next)->
        self.i2c1.receiveByte self.address, (err, byte2)->
          return next err if err?
          return next null if (!byte1? || !byte2?) || (byte1 == 0 && byte2 == 0)
          temp = self.convertTemp byte1, byte2
          switch self.temperatureMode
            when 'fahrenheit'
              temp = temp.fTemp
            else
              temp = temp.cTemp

          debugTemp "TEMPERATURE: #{inspect temp} (adr #{self.address}) #{moment().format('hh:mm DD-MM-YYYY')} #{self.temperatureMode}"
          return next null, temp
    ], callback

  readHumidity: (callback)->
    self = @
    async.waterfall [
      (next)->
        self.i2c1.sendByte self.address, CMD_READ_HUMIDITY, (err) ->
          setTimeout next, 500
      (next)->
        self.i2c1.receiveByte self.address, next
      (byte1, next)->
        self.i2c1.receiveByte self.address, (err, byte2)->
          return next err if err?
          return next null if !byte1? || !byte2? || (byte1 == 0 && byte2 == 0)
          humidity = self.convertHumidity byte1, byte2
          debugHumidity "HUMIDITY: #{humidity} (adr #{self.address})}  #{moment().format('hh:mm DD-MM-YYYY')}"
          return next null, humidity
    ], callback

  readSensor: ()->
    self = @
    if @.i2c1?
      # console.log "READING TEMPERATURE/HUMIDITY SENSOR (adr #{self.address})"
      async.eachSeries @.detectors,
        (detector, next)->
          switch detector.type
            when 'temperature'
              self.readTemperature (err, temperature)->
                console.error err if err?
                if !err? && temperature?
                  self.processSensorValue(detector, temperature, next) #TODO choose dependend on user detector

            when 'humidity'
              self.readHumidity (err, humidity)->
                console.error err if err?
                if !err? && humidity?
                  self.processSensorValue(detector, humidity, next) #TODO choose dependend on user detector

            else
              return next "Detector type #{detector.type} not implemented"
        (err) ->
          logger.error "@hdc1000", err if err?
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
module.exports = HDC1000Sensor