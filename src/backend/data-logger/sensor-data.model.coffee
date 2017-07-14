async = require('async')
mongoose = require('mongoose')

Schema = mongoose.Schema
ObjectId = Schema.ObjectId

sensorDataSchema = mongoose.Schema({
  sensor: {
    type: ObjectId,
    ref: 'Sensor',
    required: true
  },
  detectorType: String,
  value: Number,
  timestamp: {
    type: Date,
    default: Date.now
  }
})

exports.getSchema = ()-> sensorDataSchema
exports.getModel = ()->
  try
    mongoose.model('SensorData')
  catch err
    mongoose.model('SensorData', sensorDataSchema)

