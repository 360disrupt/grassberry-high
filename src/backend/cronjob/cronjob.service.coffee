inspect = require('util').inspect
chalk = require('chalk')
debugCronjobs = require('debug')('cronjobs')
debugBoot = require('debug')('boot')

mongoose = require('mongoose')
moment = require('moment')
_ = require("lodash")

CronJob = require('cron').CronJob
CronjobModel = require('./cronjob.model.js').getModel()

conversionHelper = require('../_helper/conversion.helper.js')
logger = require('../_logger/logger.js').getLogger()
outputService = require('../output/output.service.js')
cronjobs = []
self = @

getTimeFromCronjob = (cronTime)->
  cronTime = cronTime.split(' ').splice(0,3).reverse().join(':')
  return moment(cronTime, "hh:mm:ss", 'en')

afterCurrentTime = (isotime)->
  if !isotime? || typeof isotime.format != 'function'
    logger.error("wasn't able to project time: #{isotime}")
    return false
  timeProjected = moment(isotime.format('HH:mm:ss'), "HH:mm:ss")
  debugBoot "Projected time: #{timeProjected.toISOString()} diff: #{moment().diff(timeProjected, 'seconds')} curr:#{moment().format('HH:mm:ss')}"
  return moment().diff(timeProjected, 'seconds') > 0 #current time exceeded cronjob time

exports.bootStatus = (cronjobs)->
  #always two cronjobs per light in a chamber on & off
  grouped = {}
  for cronjob in cronjobs
    grouped[cronjob.output._id] = {} if !grouped[cronjob.output._id]?
    grouped[cronjob.output._id][cronjob.action] = getTimeFromCronjob(cronjob.cronPattern)

  for outputId of grouped
    action = null
    if grouped[outputId].switchOff? && grouped[outputId].switchOn?

      # on is before off trigger, on time is reached, off not: |OFF|ON*|OFF* or |ON*|OFF*|
      if grouped[outputId].switchOff.diff(grouped[outputId].switchOn, 'seconds') > 0 && afterCurrentTime(grouped[outputId].switchOn) && !afterCurrentTime(grouped[outputId].switchOff)
        debugBoot "Switching on => off: #{grouped[outputId].switchOff.format('HH:mm')} on: #{grouped[outputId].switchOn.format('HH:mm')} off after on #{grouped[outputId].switchOff.diff(grouped[outputId].switchOn, 'seconds') > 0 } on is after current #{afterCurrentTime grouped[outputId].switchOn} off is after current #{!afterCurrentTime grouped[outputId].switchOff}"
        action = 'switchOn'
      # off is before on trigger, on time is reached, off not: |ON|OFF*|ON* or OFF*|ON*
      else if grouped[outputId].switchOff.diff(grouped[outputId].switchOn, 'seconds') < 0 && afterCurrentTime(grouped[outputId].switchOn)
        debugBoot "Switching on => off: #{grouped[outputId].switchOff.format('HH:mm')} on: #{grouped[outputId].switchOn.format('HH:mm')} off before on #{grouped[outputId].switchOff.diff(grouped[outputId].switchOn, 'seconds') < 0 } on is after current: #{afterCurrentTime grouped[outputId].switchOn}"
        action = 'switchOn'
      else
        action = 'switchOff'
    else if grouped[outputId].switchOn?
      action = 'switchOn'
    else if grouped[outputId].switchOff?
      action = 'switchOff'

    if action?
      debugCronjobs "Bootcronjob triggers #{outputId} command #{action}"
      info = "Due to boot #{conversionHelper.getLocalTime 'DD.MM HH:mm:ss'}"
      outputService.operateOutput outputId, action, info, null, (err)->
        logger.error err if err?

  return

getCronFunction = (cronjob)->
  debugCronjobs "Creating cron function #{cronjob.output}, #{cronjob.cronPattern} #{cronjob.action}"
  return ()->
    info = "Due to cronjob #{conversionHelper.getLocalTime 'DD.MM HH:mm:ss'}"
    debugCronjobs "triggered cronjob #{cronjob.output}, #{cronjob.cronPattern} #{cronjob.action}"
    outputService.operateOutput cronjob.output._id, cronjob.action, info, null, (err)->
      logger.error err if err?

exports.launchCronjobs = (callback)->
  CronjobModel.find({}).populate('output', {}).exec (err, cronjobsFound) ->
    return callback err if err?
    self.bootStatus cronjobsFound
    for cronjob in cronjobsFound
      debugCronjobs "Launching for output #{cronjob.output}, #{cronjob.cronPattern} #{cronjob.action}"
      newCronjob = new CronJob(cronjob.cronPattern
        getCronFunction(cronjob)
        () ->
          debugCronjobs "stopped Cronjob #{@.cronTime.source}"
        true
      )
      cronjobs.push newCronjob
    return callback null, true

exports.stopCronjobs = ()->
  for index in [cronjobs.length-1..0] by -1
    cronjobs[index].stop()
    cronjobs.splice(index,1)
  return

exports.getActiveCronjobs = ()->
  return cronjobs


exports.createCronjob = (cronjob, callback)->
  newCronjob = new CronjobModel(cronjob)
  newCronjob.save callback

exports.removeCronjobs = (ids, callback)->
  CronjobModel.remove({_id: {$in:ids}}).exec callback
