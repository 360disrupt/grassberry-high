KB = 1024 #kilobyte
MB = 1024 * 1024 #megabyte

inspect = require('util').inspect
chalk = require('chalk')

_ = require('lodash')
mongoose = require('mongoose')

SensorData = require('../data-logger/sensor-data.model.js').getModel()

exports.getDbSize = (collection, callback)->
  scale = MB
  switch collection
    when 'sensordata'
      SensorData.collection.stats {scale: scale}, (err, results) ->
        return callback err if err?
        return callback null, results.storageSize
    else
      return callback "Operation not supported for collection #{collection}"