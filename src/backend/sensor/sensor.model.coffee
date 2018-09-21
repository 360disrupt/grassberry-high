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
  technology: String #I2C or BLE
  model: String,
  address: {
    type: Number, #I2C & BLE sensor
    unique: true,
    sparse: true
  }
  uuid: {
    type: String, #BLE sensor
    unique: true,
    sparse: true
  }
  detectors: [detectorSchema]
})

#-----------------------------------------------  Sensor Validation ----------------------------------------
validate = (data, next) ->
  err = []
  switch data.technology
    when 'ble'
      if !data.uuid?
        err.push "uuid is required"
      delete data.address

    when 'i2c'
      if !data.address?
        err.push "I2C address is required"
      delete data.uuid
  return next err.join("\n") if err.length > 0
  return next()



hooks = (data, callback)->
  async.parallel
    validate: (next)->
      validate(data, next)
    (err)->
      return callback err if err?
      return callback()

sensorSchema.pre('save', (next) ->
  data = @
  hooks data, next
)

sensorSchema.pre('findOneAndUpdate', (next) ->
  data = @._update
  return next() if @._update.$set?
  hooks data, next
)

#-----------------------------------------------  Sensor Export ----------------------------------------

exports.getSchema = ()-> sensorSchema
exports.getModel = ()->
  try
    mongoose.model('Sensor')
  catch err
    mongoose.model('Sensor', sensorSchema)