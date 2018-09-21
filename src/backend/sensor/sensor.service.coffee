inspect = require('util').inspect
chalk = require('chalk')
debugSensorBoot = require('debug')('sensor:boot')
debugSensorBootVerbose = require('debug')('sensor:boot:verbose')

async = require('async')
mongoose = require('mongoose')
_ = require("lodash")

if process.env.SIMULATION == 'true'
  ChirpSensor = require('./mocks/chirp-sensor.class.mock.js')
  HDC1000Sensor = require('./mocks/hdc1000-sensor.class.mock.js')
  MHZ16Sensor = require('./mocks/mhz-16-sensor.class.mock.js')
else
  ChirpSensor = require('./chirp-sensor.class.js')
  HDC1000Sensor = require('./hdc1000-sensor.class.js')
  MHZ16Sensor = require('./mhz-16-sensor.class.js')

SensorTagSensor = require('./sensor-tag.class.js')

SensorModel = require('./sensor.model.js').getModel()


i2c = require('../i2c/i2c.js')

@.sensors = []
self = @

addSensor = (newSensor, callback)->
  self.sensors.push newSensor
  return callback()

exports.bootSensors = (options, callback)->
  filterRead = options.filterRead || {}
  SensorModel.find(filterRead).lean().exec (err, sensorsFound) ->
    return callback err if err?
    self.sensors = [] if options.additive != true
    async.eachSeries sensorsFound,
      (sensor, next)->
        return next() if !!~_.findIndex(self.sensors, { 'address': sensor.address }) #if already in stack
        debugSensorBoot "Sensor #{sensor.address} #{sensor.model} is active: #{i2c.adressInActiveDevices sensor.address}"
        debugSensorBootVerbose _.findIndex(self.sensors, { 'address': sensor.address }), self.sensors
        newSensor = null
        if sensor.technology == 'i2c' && i2c.adressInActiveDevices sensor.address
          switch sensor.model
            when 'chirp'
              new ChirpSensor sensor, (err, newSensor)->
                return next err if err?
                addSensor newSensor, next
            when 'hdc1000'
              newSensor = new HDC1000Sensor sensor, (err, newSensor)->
                return next err if err?
                addSensor newSensor, next
            when 'mhz16'
              newSensor = new MHZ16Sensor sensor, (err, newSensor)->
                return next err if err?
                addSensor newSensor, next
            else
              return next()
        else if sensor.technology == 'ble'
          switch sensor.model
            when 'sensorTag'
              newSensor = new SensorTagSensor sensor, (err, newSensor)->
                return next err if err?
                addSensor newSensor, next
            else
              return next()
        else
          return next()
      (err)->
        debugSensorBoot "booted #{self.sensors.length} sensors"
        return callback err

exports.getSensors = (options, callback)->
  return callback null, self.sensors

exports.sensorRegistered =  (address)->
  return !!~_.findIndex(@.sensors, {'address': address})

exports.broadcastSensors = (callback)->
  for sensor in @.sensors
    sensor.broadcastSensorHistory()
  return callback null, true

exports.updateSensorTimeUnit = (sensorId, newTimeUnit, options, callback) ->
  errors = []
  errors.push new Error "SensorId is required for this operation" if sensorId == null
  errors.push new Error "Time unit is required for this operation" if newTimeUnit == null
  return callback errors if errors.length > 0
  sensor = @.sensors.filter((sensor)-> sensor._id.toString() == sensorId)
  if sensor.length == 1
    sensor[0].changeSensorTimeUnit newTimeUnit, callback
