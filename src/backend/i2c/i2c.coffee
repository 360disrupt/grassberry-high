BUS = 1
SCAN_INTERVALL = 1000
RELAIS_CONTROLLER = 32

inspect = require('util').inspect
chalk = require('chalk')
debugI2c = require('debug')('busI2c')
debugI2cVerbose = require('debug')('busI2c:verbose')

_ = require('lodash')
mongoose = require('mongoose')
moment = require('moment')
async = require('async')
os = require('os')
if os.arch() == 'arm' #raspberrypi
  i2c = require('i2c-bus')
else
  debugI2c "Not using I2C", os.arch()
  i2c = require('./mocks/i2c.mock.js')

OutputModel = require('../output/output.model.js').getModel()
SensorModel = require('../sensor/sensor.model.js').getModel()

outputAndSensorBootHelper = require('../_helper/ouputAndSensorBoot.helper.js')

self = @
@.activeDevices = []

exports.bootI2C = (callback)->
  async.series [
    (next)->
      self.i2c1 = i2c.open BUS, next
    (next)->
      self.scan next
    (next)->
      watch next
    ], callback

watch = (callback)->
  activeDevicesTemp = self.activeDevices
  setInterval ()->
    self.scan ->
      if !_.isEqual activeDevicesTemp, self.activeDevices
        differenceLost = _.difference activeDevicesTemp, self.activeDevices
        differenceAdded = _.difference self.activeDevices, activeDevicesTemp
        debugI2c "LOST #{differenceLost}" if differenceLost.length > 0
        debugI2c "ADDED #{differenceAdded}" if differenceAdded.length > 0
        activeDevicesTemp = self.activeDevices
        if differenceAdded.length > 0
          bootOptions = { noCrons: true, additive: true, filterRead: {$in: differenceAdded} }
          bootOptions.noOutputs = true if differenceLost.indexOf(RELAIS_CONTROLLER) == -1 && differenceAdded.indexOf(RELAIS_CONTROLLER) == -1
          outputAndSensorBootHelper.bootSensorsAndOutputs bootOptions, ->
  , SCAN_INTERVALL
  return callback()

exports.scan = (callback)->
  if @.i2c1?
    @.i2c1.scan (err, devices)->
      if self.activeDevices.length == 0
        debugI2c "\n\n====================\nSCAN\n=======================\n#{err}"
      else
        debugI2cVerbose "\n#{inspect devices}"
      self.activeDevices = devices.sort()
      return callback err, devices
  else
    return callback "I2C not booted (#1)"

exports.adressInActiveDevices = (address)->
  return @.activeDevices.indexOf(address) != -1

exports.getI2cBus = ()->
  return @.i2c1

exports.getActiveDevices = (callback)->
  return callback [] if @.activeDevices.length == 0
  filterRead = {address: {$in: @.activeDevices}}
  activeDevicesDetail = []
  async.parallel
    outputs: (next)->
      if self.activeDevices.indexOf(0x20) != -1
        activeDevicesDetail = activeDevicesDetail.concat [{
            type:'output'
            address: 0x20
            name: "Relais Controller"
        }]
      return next()
    sensors: (next)->
      SensorModel.find(filterRead).lean().exec (err, sensors)->
        return next err if err?
        sensors = sensors.map (sensor)->
          sensor.type = 'sensor'
          return sensor
        activeDevicesDetail = activeDevicesDetail.concat sensors
        return next()
    (err)->
      return callback err if err?
      return callback null, activeDevicesDetail


#============================== REPROGRAM WATERSENSOR =========================

exports.updateI2CAddress = (sensorType, oldAddress, newAddress, callback)->
  @.i2c1 = i2c.open BUS
  switch sensorType
    when 'waterSensor'
      async.series [
        (next)->
          watersensorRegister = 0x01
          @.i2c1.writeByte oldAddress, watersensorRegister, newAddress, next
        (next)->
          commandReset = 0x06
          @.i2c1.writeByte oldAddress, watersensorRegister, newAddress, next
      ], (err)->
        return callback err

    else
      return callback "Only allowed for sensor type water sensor"


#via I2c Tools
#i2cdetect 1 #detects I2c Devices on bus 1
#i2cset -y 1 0x20 0x01 0x21 #wirtes new address to water sensor
#i2cset -y 1 0x20 0x06 #resets the water sensor