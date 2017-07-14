async = require('async')
mongoose = require('mongoose')

Schema = mongoose.Schema
ObjectId = Schema.ObjectId

outputSchema = mongoose.Schema({
  address: Number,
  label: String,
  name: String
})

exports.getSchema = ()-> outputSchema
exports.getModel = ()->
  try
    mongoose.model('Output')
  catch err
    mongoose.model('Output', outputSchema)
