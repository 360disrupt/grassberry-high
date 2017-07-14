async = require('async')
mongoose = require('mongoose')

Schema = mongoose.Schema
ObjectId = Schema.ObjectId

cronjobSchema = mongoose.Schema({
  output: {
    type: ObjectId,
    ref: 'Output',
    required: true
  }
  action: String,
  cronPattern: String
})

exports.getSchema = ()-> cronjobSchema
exports.getModel = ()->
  try
    mongoose.model('Cronjob')
  catch err
    mongoose.model('Cronjob', cronjobSchema)
