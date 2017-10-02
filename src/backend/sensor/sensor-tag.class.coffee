TemperatureSensorIndex = 0
HumiditySensorIndex = 1

inspect = require('util').inspect
chalk = require('chalk')
debugSensorTag = require('debug')('sensorTag')
debugSensorTagTemperature = require('debug')('sensorTag:temperature')
debugSensorTagHumidity = require('debug')('sensorTag:humidity')

async = require('async')
_ = require('lodash')
moment = require('moment')

Sensor = require('./sensor.class.js')
SensorTag = require('sensortag')

class SensorTagSensor extends Sensor
  constructor: (options, callback) ->
    debugSensorTag "options", options
    that = @
    for key, value of options
      @[key] = value
    @.bootStatus = false
    super options, (err)->
      that.discoverById()
      return callback null, that

#---------------------- READ functions ------------------------------------------------
  readBatteryLevel: (sensorTag, callback)->
    sensorTag.readBatteryLevel (error, batteryLevel)->
      debugSensorTag "Battery", error, "#{batteryLevel}%"
      return callback()

  readIrTemperature: (sensorTag, callback)->
    sensorTag.readIrTemperature (err, objectTemperature, ambientTemperature)->
      return callback err if err?
      return callback null, objectTemperature, ambientTemperature

#---------------------- LAUNCH devices ------------------------------------------------
  enableTemperature: (sensorTag, callback)->
    self = @
    async.series [
      (next)->
        sensorTag.enableIrTemperature next
      (next)->
        sensorTag.notifyIrTemperature next
      (next)->
        sensorTag.on 'irTemperatureChange', (objectTemperature, ambientTemperature)->
          debugSensorTagTemperature "objectTemperature #{objectTemperature}, ambientTemperature #{ambientTemperature}"
          self.processSensorValue self.detectors[TemperatureSensorIndex], ambientTemperature, ->
        return next()
    ], (err)->
      return callback err

  enableHumidity: (sensorTag, callback)->
    self = @
    async.series [
      (next)->
        sensorTag.enableHumidity next
      (next)->
        sensorTag.notifyHumidity next
      (next)->
        sensorTag.on 'humidityChange', (temperature, humidity)->
          debugSensorTagHumidity "temperature #{temperature}, humidity #{humidity}"
          self.processSensorValue self.detectors[HumiditySensorIndex], humidity, ->
        return next()
    ], (err)->
      return callback err

#--------------------------------------------------- Discover Sensors -------------------------------------------------------

  onDiscover: (sensorTag)=>
    self = @
    debugSensorTag "Discovered uuid: #{sensorTag.uuid}, address: #{sensorTag.address}, rssi #{sensorTag.rssi}, type: #{sensorTag.type}"#, inspect sensorTag

    sensorTag.once 'disconnect', (err)->
      debugSensorTag "Disconnected: ", err if err?

    #setup the found BLE sensor
    async.series [
      (next)->
        sensorTag.connectAndSetUp next
      (next)->
        self.readBatteryLevel sensorTag, next
      (next)->
        self.enableTemperature sensorTag, next
      (next)->
        self.enableHumidity sensorTag, next
    ], (err)->
      if err?
        debugSensorTag "#{}ERR", inspect err
      else
        self.bootStatus = true
    return

  discoverById: ()->
    console.log chalk.bgGreen "#{}", inspect @.uuid
    if @.uuid?
      SensorTag.discoverById @.uuid, @.onDiscover

  # discoverAll: (callback)->
  #   SensorTag.discoverAll(callback)
  #   return null

  # stopDiscoverAll: ()->
  #   SensorTag.stopDiscoverAll()
  #   return

#///////////////////////////////////////////////////////////////////////////////////////////////////
module.exports = SensorTagSensor
