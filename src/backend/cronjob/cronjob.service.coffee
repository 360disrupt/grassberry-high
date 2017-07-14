inspect = require('util').inspect
chalk = require('chalk')
debugCronjobs = require('debug')('cronjobs')

mongoose = require('mongoose')
moment = require('moment')
_ = require("lodash")

CronJob = require('cron').CronJob
CronjobModel = require('./cronjob.model.js').getModel()

logger = require('../_logger/logger.js').getLogger()
outputService = require('../output/output.service.js')
cronjobs = []
self = @

getTimeFromCronjob = (cronTime)->
  cronTime = cronTime.split(' ').splice(0,3).reverse().join(':')
  return moment(cronTime, "hh:mm:ss", 'en')

afterCurrentTime = (isotime)->
  isotime = moment("2017-02-01T19:30:00.000")
  timeProjected = moment(isotime.format('HH:mm'), "HH:mm")
  return moment().diff(timeProjected, 'minutes') < 0

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
      if grouped[outputId].switchOff.diff(grouped[outputId].switchOn, 'hours') > 0 && afterCurrentTime grouped[outputId].switchOn && !afterCurrentTime grouped[outputId].switchOff
        action = 'switchOn'
      # off is before on trigger, on time is reached, off not: |ON|OFF*|ON* or OFF*|ON*
      else if grouped[outputId].switchOff.diff(grouped[outputId].switchOn, 'hours') < 0 && afterCurrentTime grouped[outputId].switchOn
        action = 'switchOn'
      else
        action = 'switchOff'
    else if grouped[outputId].switchOn?
      action = 'switchOn'
    else if grouped[outputId].switchOff?
      action = 'switchOff'

    if action?
      debugCronjobs "Bootcronjob triggers #{outputId} command #{action}"
      info = "Due to boot #{moment().format('DD.MM HH:mm:ss')}"
      outputService.operateOutput outputId, action, info, null, (err)->
        logger.error err if err?

  return

exports.launchCronjobs = (callback)->
  CronjobModel.find({}).populate('output', {}).exec (err, cronjobsFound) ->
    return callback err if err?
    self.bootStatus cronjobsFound
    for cronjob in cronjobsFound
      debugCronjobs inspect cronjobsFound
      debugCronjobs "Launching for output #{cronjob.output}, #{cronjob.cronPattern} #{cronjob.action}"
      newCronjob = new CronJob( cronjob.cronPattern
        () ->
          info = "Due to cronjob #{moment().format('DD:MM HH:mm:ss')}"
          outputService.operateOutput cronjob.output._id, cronjob.action, info, null, (err)->
            logger.error err if err?
        () ->
          # console.log 'cron xyz'
        true
        'Europe/Amsterdam'#http://momentjs.com/timezone/ #TODO TIMEZONE & LANGUAGE SETTING
      )
      cronjobs.push newCronjob
    return callback null, true

exports.createCronjob = (cronjob, callback)->
  newCronjob = new CronjobModel(cronjob)
  newCronjob.save callback

exports.removeCronjobs = (ids, callback)->
  CronjobModel.remove({_id: {$in:ids}}).exec callback
