inspect = require('util').inspect
chalk = require('chalk')
debugSensorBoot = require('debug')('sensor:boot')

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
  SensorModel.find({}).lean().exec (err, sensorsFound) ->
    return callback err if err?
    self.sensors = [] if options.additive != true
    async.eachSeries sensorsFound,
      (sensor, next)->
        return next() if !!~_.findIndex(self.sensors, { 'address': sensor.address }) #if already in stack
        debugSensorBoot "Sensor #{sensor.address} #{sensor.model} is active: #{i2c.adressInActiveDevices sensor.address}"
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

exports.updateDetectorName = (detectorId, newDetectorName, options, callback) ->
  errors = []
  errors.push new Error "DetectorId is required for this operation" if detectorId == null
  errors.push new Error "New detector name is required for this operation" if newDetectorName == null
  return callback errors if errors.length > 0
  SensorModel.update({'detectors._id': detectorId}, { $set: {'detectors.$.name':  newDetectorName} }).exec (err) ->
    return callback err

exports.upsertSensor = (upsertSensor, callback)->
  upsertSensor._id = new mongoose.mongo.ObjectID() if !upsertSensor._id
  SensorModel.findOneAndUpdate({_id: upsertSensor._id}, _.omit(upsertSensor,'_id'), {upsert: true}).exec (err, upsertSensor) ->
    return callback err if err?
    return callback null, upsertSensor