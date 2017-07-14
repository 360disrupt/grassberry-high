chalk = require('chalk')
inspect = require('util').inspect
async = require('async')
moment = require('moment')
mongoose = require('mongoose')
_ = require('lodash')

ObjectId = mongoose.Types.ObjectId

UserModel = require('../user/user.model.js').getModel()
ChamberModel = require('../chamber/chamber.model.js').getModel()
CronjobModel = require('../cronjob/cronjob.model.js').getModel()
SensorModel = require('../sensor/sensor.model.js').getModel()
SensorDataModel = require('../data-logger/sensor-data.model.js').getModel()
OutputModel = require('../output/output.model.js').getModel()
RuleModel = require('../rule/rule.model.js').getModel()

logger = require('../_logger/logger.js').getLogger()
userService = require('../user/user.service.js')

self = @

# _.mixin deeply: (map) ->
#   (object, fn) ->
#     map _.mapValues(object, (value) ->
#       if _.isPlainObject(value)
#         return _.deeply(map)(value, fn)
#       else if _.isArray(value)
#         return value.map (arrayValue)->
#           _.deeply(map)(arrayValue, fn)
#       else
#         return value
#     ), fn

# mongoosify = (item)->
#   _.deeply(_.mapValues)(item, (value, key)->
#     if typeof value == 'string' && value.match? && value.match(/^[A-Fa-f0-9]{24}$/)
#       item[key] = new ObjectId(value)
#     return item
#   )
#   return item
# #/////////////////////////////////////////////////////// CONTROLL ///////////////////////////////////////////////////////////////

exports.startSeeding = (callback) ->
  UserModel.find({permissionLevel:"autoLogin"}).limit(1).exec (err, userFound)->
    return callback err if err?
    if userFound.length > 0
    else
      self.seedUsers (err, users)->
        return callback err if err?

    return callback null, true if !process.env.SEED?

    toSeed = process.env.SEED.split(' ')
    self.deleteNSeed toSeed, callback


exports.deleteNSeed = (what, callback) ->
  async.parallel
    users: (next) ->
      if what.indexOf('users') != -1
        self.deleteUsers (err, success) ->
          return next err if err?
          self.seedUsers (err, success) ->
            return next err if err?
            next null, success
      else
        return next null, true
    chambers: (next) ->
      if what.indexOf('chambers') != -1
        self.deleteChambers (err, success) ->
          return next err if err?
          self.seedChambers (err, success) ->
            return next err if err?
            next null, success
      else
        return next null, true
    cronjobs: (next) ->
      if what.indexOf('cronjobs') != -1
        self.deleteCronjobs (err, success) ->
          return next err if err?
          self.seedCronjobs (err, success) ->
            return next err if err?
            next null, success
      else
        return next null, true
    sensors: (next) ->
      if what.indexOf('sensors') != -1
        self.deleteSensors (err, success) ->
          return next err if err?
          self.seedSensors (err, success) ->
            return next err if err?
            next null, success
      else
        return next null, true
    sensorData: (next) ->
      if what.indexOf('sensorData') != -1
        self.deleteSensorData (err, success) ->
          return next err if err?
          self.seedSensorData (err, success) ->
            return next err if err?
            next null, success
      else
        return next null, true
    outputs: (next) ->
      if what.indexOf('outputs') != -1
        self.deleteOutputs (err, success) ->
          return next err if err?
          self.seedOutputs (err, success) ->
            return next err if err?
            next null, success
      else
        return next null, true
    rules: (next) ->
      if what.indexOf('rules') != -1
        self.deleteRules (err, success) ->
          return next err if err?
          self.seedRules (err, success) ->
            return next err if err?
            next null, success
      else
        return next null, true
    (err, results) ->
      return callback err if err?
      console.log ""#to get a line break
      return callback null

getFakeAppUser = ()->
  appUser = {}
  appUser.is = (check) ->
    return true
  return appUser


#/////////////////////////////////////////////////////// DELETE ///////////////////////////////////////////////////////////////


exports.deleteUsers = (callback) ->
  UserModel.remove({}).exec (err) ->
    return callback err if err?
    return callback null, true

exports.deleteChambers = (callback) ->
  ChamberModel.remove({}).exec (err) ->
    return callback err if err?
    return callback null, true

exports.deleteCronjobs = (callback) ->
  CronjobModel.remove({}).exec (err) ->
    return callback err if err?
    return callback null, true

exports.deleteSensors = (callback) ->
  SensorModel.remove({}).exec (err) ->
    return callback err if err?
    return callback null, true

exports.deleteSensorData = (callback) ->
  SensorDataModel.remove({}).exec (err) ->
    return callback err if err?
    return callback null, true

exports.deleteOutputs = (callback) ->
  OutputModel.remove({}).exec (err) ->
    return callback err if err?
    return callback null, true

exports.deleteRules = (callback) ->
  RuleModel.remove({}).exec (err) ->
    return callback err if err?
    return callback null, true

#/////////////////////////////////////////////////////// MANUAL SEEDING ///////////////////////////////////////////////////////////////
exports.seedUsers = (callback) ->
  users = require('./users.seed.json')
  return callback "No users to seed" if !users? || users.length == 0
  async.each users,
    (user, next)->
      user.token = process.env.USER_SEED_TOKEN if  process.env.USER_SEED_TOKEN?
      newUser = new UserModel(user)
      newUser.save next
    (err)->
      return callback err if err?
      console.log "#{users.length} users seeded"
      return callback()

exports.seedChambers = (callback) ->
  chambers = require('./chambers.seed.json')
  return callback "No chambers to seed" if !chambers? || chambers.length == 0
  async.each chambers,
    (chamber, next)->
      newChamber = new ChamberModel(chamber)
      newChamber.save next
    (err)->
      return callback err if err?
      console.log "#{chambers.length} chambers seeded"
      return callback()

exports.seedCronjobs = (callback) ->
  cronjobs = require('./cronjobs.seed.json')
  return callback "No cronjobs to seed" if !cronjobs? || cronjobs.length == 0
  async.each cronjobs,
    (cronjob, next)->
      newCronjob = new CronjobModel(cronjob)
      newCronjob.save next
    (err)->
      return callback err if err?
      console.log "#{cronjobs.length} cronjobs seeded"
      return callback()


exports.seedSensors = (callback) ->
  sensors = require('./sensors.seed.json')
  return callback "No sensors to seed" if !sensors? || sensors.length == 0
  async.each sensors,
    (sensor, next)->
      if process.env.NODE_ENV == 'production' && sensor.detectors?
        sensor.detectors = sensor.detectors.map (detector)->
          delete detector.name
          return detector
      newSensor = new SensorModel(sensor)
      newSensor.save next
    (err)->
      return callback err if err?
      console.log "#{sensors.length} sensors seeded"
      return callback()

exports.seedSensorData = (callback) ->
  sensorDataArray = require('./sensor-data.seed.json')
  return callback "No sensor data to seed" if !sensorDataArray? || sensorDataArray.length == 0
  async.each sensorDataArray,
    (sensorData, next)->
      if sensorData._timestamp?
        sensorData.timestamp = moment().subtract(sensorData._timestamp.amount, sensorData._timestamp.unit)
        delete sensorData._timestamp
      newSensorData = new SensorDataModel(sensorData)
      newSensorData.save next
    (err)->
      return callback err if err?
      console.log "#{sensorDataArray.length} sensor data seeded"
      return callback()

exports.seedOutputs = (callback) ->
  outputs = require('./outputs.seed.json')
  return callback "No outputs to seed" if !outputs? || outputs.length == 0
  if process.env.NODE_ENV == 'production'
    outputs = outputs.map (output)->
      delete output.name
      return output
  async.each outputs,
    (output, next)->
      newOutput = new OutputModel(output)
      newOutput.save next
    (err)->
      return callback err if err?
      console.log "#{outputs.length} outputs seeded"
      return callback()

exports.seedRules = (callback) ->
  rules = require('./rules.seed.json')
  return callback "No rules to seed" if !rules? || rules.length == 0
  async.each rules,
    (rule, next)->
      newRule = new RuleModel(rule)
      newRule.save next
    (err)->
      return callback err if err?
      console.log "#{rules.length} rules seeded"
      return callback()
