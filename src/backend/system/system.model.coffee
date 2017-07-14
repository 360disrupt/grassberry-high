async = require('async')
mongoose = require('mongoose')

Schema = mongoose.Schema
ObjectId = Schema.ObjectId

systemSchema = mongoose.Schema({
  validTill: Date
  version: String
  region: String
  timeZone: String
  units: {
    temperature: String
  }
  serial: String
  wifi: String
})

exports.getSchema = ()-> systemSchema
exports.getModel = ()->
  try
    mongoose.model('System')
  catch err
    mongoose.model('System', systemSchema)