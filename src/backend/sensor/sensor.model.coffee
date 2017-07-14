async = require('async')
mongoose = require('mongoose')

Schema = mongoose.Schema
ObjectId = Schema.ObjectId

detectorSchema = {
  label: String,
  name: String,
  type: { type: String },
  unit: String
}

sensorSchema = mongoose.Schema({
  address: Number,
  model: String,
  detectors: [detectorSchema]
})

exports.getSchema = ()-> sensorSchema
exports.getModel = ()->
  try
    mongoose.model('Sensor')
  catch err
    mongoose.model('Sensor', sensorSchema)