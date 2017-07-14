if process.env.OS == "MAC OSX"
  APP_PATH = __dirname + '/../../../'
else
  APP_PATH = '/home/pi/app/'
CRONJOB_LICENSE_PATTERN = "0 0 0 * * *"
CRONJOB_UPDATE_PATTERN = "0 0 1 * * *"
inspect = require('util').inspect
chalk = require('chalk')
debugSystem = require('debug')('system')

fs = require('fs')
request = require('request')
mongoose = require('mongoose')
async = require('async')
moment = require('moment')

logger = require('../_logger/logger.js').getLogger()
SystemModel = require('./system.model.js').getModel()
CronJob = require('cron').CronJob

shellService = require('../shell/shell.service.js')
restHelper = require('../_api/rest.helper.js')
apiEndpoints = require('../_api/api-endpoints.js')()
outputAndSensorBootHelper = require('../_helper/ouputAndSensorBoot.helper.js')

self = @

#--------------------------- Cronjobs -----------------------------
exports.bootLicenseCronjob = ()->
  newCronjob = new CronJob( CRONJOB_LICENSE_PATTERN
    () ->
      options = {}
      self.getLicenseInformation options, (err)->
        logger.error err if err?
        return
    () ->
      # console.log 'cron xyz'
    true
    'Europe/Amsterdam'#http://momentjs.com/timezone/ #TODO TIMEZONE & LANGUAGE SETTING
  )

exports.bootSoftwareUpdateCronjob = ()->
  newCronjob = new CronJob( CRONJOB_UPDATE_PATTERN
    () ->
      options = {}
      self.updateSoftware options, (err)->
        logger.error err if err?
        return
    () ->
      # console.log 'cron xyz'
    true
    'Europe/Amsterdam'#http://momentjs.com/timezone/ #TODO TIMEZONE & LANGUAGE SETTING
  )

#--------------------------- License -----------------------------
exports.getLicenseInformation = (options, callback)->
  async.waterfall [
    (next)->
      shellService.getSerial next
    (serial, next)->
      method = 'GET'
      url = "#{apiEndpoints['license']}/#{serial}"
      data = {}
      debugSystem "getting license for serial #{serial}"
      restHelper.emit method, url, data, (err, license)->
        return next err, serial, license
    (serial, license, next)->
      debugSystem "License", license
      return next() if !license.payload?.validTill?
      SystemModel.findOneAndUpdate({}, { validTill: license.payload.validTill, serial: serial }, {upsert: true}).exec next
  ], (err)->
    return callback err

#--------------------------- Software Updates -----------------------------
downloadSoftware = (update, callback)->
  path = APP_PATH + 'newVersion.tar.gz'
  file = fs.createWriteStream path
  debugSystem "Start download from #{path}"
  request.get(update.url)
    .on 'response', (res) ->
      # debugSystem res
      contentType = res.headers['content-type']
      statusCode = res.statusCode
      if statusCode != 200
        return callback "Error downloading update #{res.statusCode}"
      else if !/^application\/octet-stream/.test(contentType)
        return callback "Error downloading update wrong content #{contentType}"

      res
        .on 'err', (err) ->
          return callback err
        .on 'data', (data) ->
          file.write data
        .on 'end', () ->
          file.end()
          debugSystem "Update downloaded"
          stats = fs.stat path, (err, stat)->
            return callback err if err?
            debugSystem "Stat", stat
            if stat.size < 25000000 #25mb santiy check
              fs.unlink path, (err)->
                errMsg = "Downloaded tar does not fit checksum size, was #{stat.size} expected #{update.checksum}"
                errMsg += "and could not unlink file #{err}" if err?
                return callback errMsg
            else
              return callback null, update
    .on 'error', (err)->
      return callback err

exports.updateSoftware = (callback)->
  async.waterfall [
    (next)->
      shellService.getSerial next
    (serial, next)->
      fs.readFile __dirname + '/../../version.txt', 'utf-8', (err, version)->
        return next err, serial, version
    (serial, version, next)->
      method = 'GET'
      url = "#{apiEndpoints['download']}/#{encodeURIComponent(serial)}/#{encodeURIComponent(version)}"
      data = {}
      debugSystem "Requesting update from #{url} with version #{version} & serial #{serial}"
      restHelper.emit method, url, data, next
    (response, next)->
      debugSystem response
      if !response.payload?.update?.url?
        debugSystem "Aborting no update available"
        return next "abort"

      update = response.payload.update
      downloadSoftware update, next
    (update, next)->
      debugSystem "Updating system"
      SystemModel.findOneAndUpdate({}, {version: update.version}).exec (err)->
        return next err
    (next)->
      debugSystem "Deploying new version"
      shellService.installNewVersion(next) #actually does not get called in case of success
  ], (err)->
    msg = null
    if err == 'abort'
      err = null
      msg = "Already up-to-date"
    return callback err, msg

#--------------------------- Settings Updates -----------------------------
exports.updateSystem = (appUser, data, options, callback)->
  #sanitize
  allowedUpdates = ['region', 'timeZone',  'units', 'wifi']
  for key of data
    if allowedUpdates.indexOf(key) == -1
      delete data[key]

  SystemModel.findOne({}).exec (err, system)->
    return callback err if err?
    if !system?
      system = new SystemModel()
    for key, value of data
      system[key] = value
    system.save (err, system)->
      return callback err if err?
      bootOptions = { noCrons: true }
      outputAndSensorBootHelper.bootSensorsAndOutputs bootOptions, (err)->
        return callback err, system