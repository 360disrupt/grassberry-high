inspect = require('util').inspect
chalk = require('chalk')
debugSensorRemove = require('debug')('sensor:remove')

SensorModel = require('./sensor.model.js').getModel()
self = @

exports.removeSensor = (id, options, callback)->
  SensorModel.remove({_id: id}).exec (err) ->
    return callback err