inspect = require('util').inspect
chalk = require('chalk')
debugChamber = require('debug')('chamber')
debugChamberSetup = require('debug')('chamber:setup')

mongoose = require('mongoose')
async = require('async')
moment = require('moment')
_ = require('lodash')

ChamberModel = require('./chamber.model.js').getModel()
Chamber = require('./chamber.class.js')

sensorService = require('../sensor/sensor.service.js')
outputService = require('../output/output.service.js')
ruleService = require('../rule/rule.service.js')
cronJobService = require('../cronjob/cronjob.service.js')
i2cService = require('../i2c/i2c.js')
outputAndSensorBootHelper = require('../_helper/ouputAndSensorBoot.helper.js')
self = @

# #sensor id was populated and needs now to be split for diff. devices
# mapDevicesToRules = (chambers)->
#   for chamber in chambers
#     if chamber.rules?
#       for rule in chamber.rules
#         rule.sensor.detectors = rule.sensor.detectors.filter((detector)-> rule.forDetector == detector.type)[0]
#         for key, value of rule.sensor.detectors
#           rule.sensor[key] = value
#         delete rule.sensor.detectors

addListOfActiveSensors = (chambers)->
  for chamber in chambers
    chamber.activeSensors = []
    if chamber.rules?
      for rule in chamber.rules
        chamber.activeSensors.push rule.sensor
    if chamber.displays?
      for display in chamber.displays
        chamber.activeSensors.push display

    if chamber.activeSensors?
      chamber.activeSensors = _.uniqBy chamber.activeSensors, '_id'
      chamber.activeSensors = chamber.activeSensors.filter (activeSensor)->
        return false if !activeSensor?._id?
        return sensorService.sensorRegistered activeSensor.address
    debugChamber "activeSensors", chamber.activeSensors
  return chambers

addListOfOutputs = (chambers)->
  for chamber in chambers
    chamber.allOutputs = []
    if chamber.light?.output?._id?
      currentState = outputService.getOutputState chamber.light.output._id
      chamber.allOutputs.push {_id: chamber.light.output._id, name: chamber.light.output.name || chamber.light.output.label, device: 'light', state: currentState}
    for rule in chamber.rules
      if rule.output?._id?
        currentState = outputService.getOutputState rule.output._id
        chamber.allOutputs.push {_id: rule.output._id, name: rule.output.name || rule.output.label, device: rule.device, state: currentState}
    if chamber.allOutputs?
      chamber.allOutputs = _.uniqBy(chamber.allOutputs, '_id')
    debugChamber "allOutputs", chamber.allOutputs
  return chambers


exports.getChambers = (options, callback)->
  Query = ChamberModel.find({})
  if options.populate?.all?
    Query.populate([{path:'light.output'}, {path:'displays'}]).deepPopulate(['rules', 'rules.sensor', 'rules.output'])
  if options.lean?
    Query.lean()

  Query.exec (err, chambersFound) ->
    return callback err if err?
    return callback null, [] if !chambersFound?
    debugChamber "chambersFound", chambersFound
    addListOfActiveSensors chambersFound
    addListOfOutputs chambersFound
    return callback null, chambersFound


addRules = (rules, callback)->
  return next() if !rules?
  rulesIds = []
  async.each rules,
    (upsertRule, next)->
      delete upsertRule.__v
      debugChamberSetup "upsertRule: before", upsertRule
      upsertRule.onValue = parseFloat(upsertRule.onValue) if upsertRule.onValue?
      upsertRule.offValue = parseFloat(upsertRule.offValue) if upsertRule.offValue?
      upsertRule.output = upsertRule.output._id if upsertRule.output?._id?
      upsertRule.detectorId = upsertRule.detectorId if upsertRule.detectorId?
      upsertRule.sensor = upsertRule.sensor._id if upsertRule.sensor?._id?

      debugChamberSetup "upsertRule: after", upsertRule
      ruleService.upsertRule upsertRule, (err, upsertedRule)->
        return next err if err?
        rulesIds.push upsertedRule._id
        return next null
    (err)->
      return callback err if err?
      return callback err, rulesIds

addLight = (upsertChamber, light, callback)->
  debugChamberSetup "light", light
  delete light.__v
  return callback() if !light?
  async.series [
    (next)->#delete old light cronjobs for this relais
      ChamberModel.findOne({_id: upsertChamber._id}).select({cronjobs:1}).lean().exec (err, chamberFound)-> #loading the old chamber
        return next err if err?
        cronJobService.removeCronjobs chamberFound.cronjobs if chamberFound?.cronjobs? && chamberFound.cronjobs.length > 0
        return next null

    (next)->#add new cronjob
      onPattern = [moment(light.startTime).seconds(), moment(light.startTime).minutes(), moment(light.startTime).hours(), '*', '*', '*'].join(' ')
      debugChamberSetup "light.durationH", light.durationH, " #{moment(light.startTime).add(light.durationH, 'hours').hours()} #{moment(light.startTime).hours()}"
      offPattern = [moment(light.startTime).seconds(), moment(light.startTime).minutes(), moment(light.startTime).add(light.durationH, 'hours').hours(), '*', '*', '*'].join(' ')
      cronjobs = [
        {output: light.output._id, action:'switchOn', cronPattern: onPattern},
        {output: light.output._id, action:'switchOff', cronPattern: offPattern}
      ]
      debugChamberSetup "cronjobs", cronjobs
      cronjobIds = []
      async.each cronjobs,
        (createCronjob, next)->
          cronJobService.createCronjob createCronjob, (err, cronjob)->
            return next err if err?
            cronjobIds.push cronjob
            return next()
        (err)->
          return next err if err?
          return next err, cronjobIds

  ], (err, results)->
    return callback err, results[1] #cronjobs

exports.spliceRule = (chamberId, ruleId, callback)->
  ChamberModel.update( {_id: chamberId}, { $pullAll: {rules: [ruleId] } } ).exec callback

exports.upsertChamber = (upsertChamber, callback)->
  debugChamberSetup "upsertChamber", upsertChamber
  delete upsertChamber.__v

  if upsertChamber.cycle == "drying"
    delete upsertChamber.light

  #split chamber properties
  if upsertChamber.rules?
    rules = JSON.parse JSON.stringify upsertChamber.rules.filter (rule)->
      return rule.output?._id? && rule.sensor?._id? && rule.detectorId?
    if upsertChamber.cycle == "drying"
      rules = rules.filter (rule)->
        return rule.forDetector != 'water'

  if upsertChamber.light?
    return callback "No light output selected (only allowed with drying mode)" if !upsertChamber.light.output?._id?
    light = JSON.parse JSON.stringify upsertChamber.light
    upsertChamber.light.output = upsertChamber.light.output._id

  if upsertChamber.strains?
    upsertChamber.strains = upsertChamber.strains.filter (strain)->
      return strain.name != null

  async.series [
    (next)-> # save rules
      return next null if !rules?
      addRules rules, next
    (next)-> # light (cronjobs)
      return next null if !light?
      addLight upsertChamber, light, next
  ], (err, results)->
    if err?
      debugChamberSetup "upsertedChamberErr", err
      return callback err
    upsertChamber.rules = results[0]
    upsertChamber.cronjobs = results[1]
    upsertChamber._id = new mongoose.mongo.ObjectID() if !upsertChamber._id
    ChamberModel.findOneAndUpdate({_id: upsertChamber._id},  _.omit(upsertChamber, '_id'), {'upsert': true, 'new': true}).exec (err, upsertedChamber) ->
      if err?
        debugChamberSetup "upsertedChamberErr", err
        return callback err
      debugChamberSetup "upsertedChamber", upsertedChamber
      bootOptions = { }
      outputAndSensorBootHelper.bootSensorsAndOutputs bootOptions, ->
      return callback null, upsertedChamber