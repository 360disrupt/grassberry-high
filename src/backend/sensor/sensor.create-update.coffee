inspect = require('util').inspect
chalk = require('chalk')
debugSensorCreate = require('debug')('sensor:create')
debugSensorCreateVerbose = require('debug')('sensor:create:verbose')

async = require('async')
mongoose = require('mongoose')
_ = require("lodash")

SensorModel = require('./sensor.model.js').getModel()
self = @

exports.upsertSensor = (upsertSensor, options, callback)->
  upsertSensor._id = new mongoose.mongo.ObjectID() if !upsertSensor._id
  SensorModel.findOneAndUpdate({_id: upsertSensor._id}, _.omit(upsertSensor,'_id'), {upsert: true}).exec (err, upsertSensor) ->
    return callback err if err?
    return callback null, upsertSensor

exports.updateDetectorName = (detectorId, newDetectorName, options, callback) ->
  errors = []
  errors.push new Error "DetectorId is required for this operation" if detectorId == null
  errors.push new Error "New detector name is required for this operation" if newDetectorName == null
  return callback errors if errors.length > 0
  SensorModel.update({'detectors._id': detectorId}, { $set: {'detectors.$.name':  newDetectorName} }).exec (err) ->
    return callback err