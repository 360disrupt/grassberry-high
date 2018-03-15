# CMD_GET_SENSOR = [ 0xff, 0x01, 0x86, 0x00, 0x00, 0x00, 0x00, 0x00, 0x79]
# CMD_CALIBRATE = [ 0xff, 0x87, 0x87, 0x00, 0x00, 0x00, 0x00, 0x00, 0xf2 ]

CMD_MEASURE = Buffer.from([0xff,0x01,0x9c,0x00,0x00,0x00,0x00,0x00,0x63])
IOCONTROL   = 0x0e << 3
FCR         = 0x02 << 3
LCR         = 0x03 << 3
DLL         = 0x00 << 3
DLH         = 0x01 << 3
THR         = 0x00 << 3
RHR         = 0x00 << 3
TxLVL       = 0x08 << 3
RxLVL       = 0x09 << 3

inspect = require('util').inspect
chalk = require('chalk')

moment = require('moment')
async = require('async')
debugCO2 = require('debug')('sensor:co2')

Sensor = require('./sensor.class.js')

typeTransformerService = require('../_helper/type-transformer.service.js')
socketIoMessenger = require('../_socket-io/socket-io-messenger.js')
logger = require('../_logger/logger.js').getLogger()

class MHZ16Sensor extends Sensor #co2
  constructor: (options, callback) ->
    debugCO2 "CO2 sensor #{options._id}"
    that = @
    if process.env.KALMAN_FILTER
      options.modes = options.modes || {}
      options.modes.kalman = JSON.parse process.env.KALMAN_FILTER # {"R":0.1,"Q":0.1}
    super options, (err)->
      that.boot (err)->
        return callback err if err?
        that.readSensor()
        return callback null, that

  boot: (callback)->
    self = @
    if @.i2c1?
      async.series [
        (next)->
          setTimeout ->
            self.i2c1.writeByte self.address, IOCONTROL, 0x08, (err)->
            return next err if err? && err.code != 'EIO'
            return next()
          , 100
        (next)->
          setTimeout ->
            self.i2c1.writeByte self.address, FCR, 0x07, next
          , 100
        (next)->
          setTimeout ->
            self.i2c1.writeByte self.address, LCR, 0x83, next
          , 100
        (next)->
          setTimeout ->
            self.i2c1.writeByte self.address, DLL, 0x60, next
          , 100
        (next)->
          setTimeout ->
            self.i2c1.writeByte self.address, DLH, 0x00, next
          , 100
        (next)->
          setTimeout ->
            self.i2c1.writeByte self.address, LCR, 0x03, next
          , 100

      ], (err)->
        console.error "CO2 BOOT ERROR", err, err.stack, inspect err if err?
        return callback(err)
    else
      return callback("I2c not started can't boot humidity sensor")

#--------------------------- Conversions ----------------------------------
  parse: (response)->
    return null if response.length != 9
    checksum = response.reduce(((previousValue, currentValue) ->
      previousValue + currentValue
    ), 0)

    return null if !(response[0] == 0xff && response[1] == 0x9c && checksum%256 == 0xff)

    ppm = (response[2]<<24) + (response[3]<<16) + (response[4]<<8) + response[5]
    return ppm


  readCO2: (callback)->
    self = @
    async.waterfall [
      (next)->
        self.i2c1.writeByte self.address, FCR, 0x07, next
      (next)->
        self.i2c1.readByte self.address, TxLVL, (err, response)->
          return next "TxLVL length < cmd length" if response < CMD_MEASURE.length
          self.i2c1.writeI2cBlock self.address, THR, CMD_MEASURE.length, CMD_MEASURE, (err, bytesWritten, buffer)->
            return next err
      (next)->
        sensorData = Buffer.alloc(0)
        left = 9

        timeout = setTimeout ->
          return next "Operation timed out"
        , 9000

        async.whilst ()->
            return left > 0
        , (nextWhilst)->
          async.waterfall [
            (nextWaterfall)->
              self.i2c1.readByte self.address, RxLVL, (err, rxLevel)->
                return nextWaterfall err if err?
                if rxLevel > left
                  rxLevel = left
                left = left - rxLevel
                return nextWaterfall null, rxLevel
            (rxLevel, nextWaterfall)->
              if rxLevel == 0
                setTimeout ()->
                  return nextWaterfall()
                , 200
              else
                receivedData = Buffer.alloc(rxLevel)
                self.i2c1.readI2cBlock self.address, RHR, rxLevel, receivedData, (err)->
                  return nextWaterfall err if err?
                  # console.log "old len #{sensorData.length} #{receivedData.length} left #{left}"
                  sensorData = Buffer.concat [sensorData, receivedData]
                  return nextWaterfall err if err?
                  return nextWaterfall()
          ], nextWhilst
        , (err)->
          clearTimeout(timeout)
          if timeout._called != true
            return next err if err?
            return next null, sensorData

    ], (err, sensorData)->
      return callback err if err?
      if !err? && sensorData?
        # console.log "sensorData", sensorData.toString('hex')
        sensorData = typeTransformerService.toArray sensorData
        ppm = self.parse sensorData
        debugCO2 "CO2: PPM  #{ppm} (adr #{self.address}) #{moment().format('hh:mm DD-MM-YYYY')}"
        return callback null, ppm

  readSensor: ()->
    self = @
    if @.i2c1?
      async.eachSeries @.detectors,
        (detector, next)->
          switch detector.type
            when 'co2'
              self.readCO2 (err, co2)->
                console.error "CO2 READ ERROR", err if err?
                if !err? && co2?
                  self.processSensorValue(detector, co2, next)
            else
              return next "Detector type not implemented"
        (err) ->
          console.error "CO2 err", err if err?
          logger.error err if err?
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
module.exports = MHZ16Sensor