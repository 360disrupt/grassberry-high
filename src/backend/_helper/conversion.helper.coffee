inspect = require('util').inspect
chalk = require('chalk')
debugHelperConversion = require('debug')('helper:conversion')

_ = require('lodash')
moment = require('moment-timezone')

systemRead = require('../system/system.read.js')

timeZone = null
self = @

exports.setTimeZone = (callback)->
  options = {}
  systemRead.getSystem options ,(err, system)->
    return callback err if err?
    timeZone = system.timeZone if system.timeZone?
    debugHelperConversion "timeZone: ", timeZone
    return callback()


exports.formatTimeToLocalTime = (dateTime, format)->
  if timeZone?
    return moment.tz(dateTime, timeZone).format(format).toString()
  return moment(dateTime).format(format).toString()

exports.getLocalTime = (format)->
  localTime = self.formatTimeToLocalTime moment(), format
  debugHelperConversion "localTime", localTime
  return localTime