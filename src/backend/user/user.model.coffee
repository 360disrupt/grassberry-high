async = require('async')
mongoose = require('mongoose')

Schema = mongoose.Schema
ObjectId = Schema.ObjectId

userSchema = mongoose.Schema({
  active: Boolean
  email: String,
  hashedPassword: String,
  lastName: String,
  permissionLevel: String,
  token: String
})

exports.getSchema = ()-> userSchema

exports.getModel = ()->
  try
    mongoose.model('User')
  catch err
    mongoose.model('User', userSchema)

