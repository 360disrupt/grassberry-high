async = require('async')
mongoose = require('mongoose')

Schema = mongoose.Schema
ObjectId = Schema.ObjectId

sessionSchema = mongoose.Schema({
  _id: String
  session: String
  expires: Date
})

exports.getSchema = ()-> sessionSchema
exports.getModel = ()->
  try
    mongoose.model('Session')
  catch err
    mongoose.model('Session', sessionSchema)