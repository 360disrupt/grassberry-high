inspect = require('util').inspect
chalk = require('chalk')

async = require('async')
mongoose = require('mongoose')
deepPopulate = require('mongoose-deep-populate')(mongoose)

Schema = mongoose.Schema
ObjectId = Schema.ObjectId

lightSchema = {
  durationH: {type: Number, required: true}
  startTime: {type: Date, required: true}
  output: {
    type: ObjectId,
    ref: 'Output',
    required: true
  }
}

strainSchema = {
  name: String,
  daysToHarvest: Number
  leafly: String
}

chamberSchema = mongoose.Schema({
  name: String,
  cycle: String,
  displays:  [{
    type: ObjectId,
    ref: 'Sensor'
  }],
  light: lightSchema,
  rules: [{
    type: ObjectId,
    ref: 'Rule'
    validate:
      validator: (value) ->
        return value?
      message: "{VALUE} is not valid."
  }]
  strains: [strainSchema]
  cronjobs: [{
    type: ObjectId,
    ref: 'Cronjob'
  }]
})

chamberSchema.plugin(deepPopulate, {})

exports.getSchema = ()-> chamberSchema
exports.getModel = ()->
  try
    mongoose.model('Chamber')
  catch err
    mongoose.model('Chamber', chamberSchema)