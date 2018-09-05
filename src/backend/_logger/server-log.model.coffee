ONE_WEEK = 60 * 60 * 24 * 7
mongoose = require('mongoose')

serverLogSchema = mongoose.Schema({
  message: {
    type: String
  },
  timestamp: {
    type: Date,
    required: true,
    default: Date.now,
    expires: ONE_WEEK
  },
  level: String,
  meta: {}
})

exports.getSchema = ()-> serverLogSchema
exports.getModel = ()->
  try
    mongoose.model('ServerLog')
  catch err
    mongoose.model('ServerLog', serverLogSchema)