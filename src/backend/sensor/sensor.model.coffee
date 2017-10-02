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
  address: Number, #I2C & BLE sensor
  uuid: String, #BLE sensor
  model: String,
  detectors: [detectorSchema]
  technology: String #I2C or BLE
})

exports.getSchema = ()-> sensorSchema
exports.getModel = ()->
  try
    mongoose.model('Sensor')
  catch err
    mongoose.model('Sensor', sensorSchema)