async = require('async')
mongoose = require('mongoose')

Schema = mongoose.Schema
ObjectId = Schema.ObjectId

eventSchema = mongoose.Schema({
  state: String,
  output: {
    type: ObjectId,
    ref: 'Output',
    required: true
  }
  info: String,
  timestamp: {
    type: Date,
    default: Date.now
    expires: 60 * 60 * 24 * 3 #expires after 3 days
  }
})

exports.getSchema = ()-> eventSchema
exports.getModel = ()->
  try
    mongoose.model('Event')
  catch err
    mongoose.model('Event', eventSchema)

