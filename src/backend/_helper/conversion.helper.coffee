inspect = require('util').inspect
chalk = require('chalk')

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
    return callback()


exports.formatTimeToLocalTime = (dateTime, format)->
  if timeZone?
    return moment.tz(dateTime, timeZone).format(format)
  return moment(dateTime).format(format)

exports.getLocalTime = (format)->
  self.formatTimeToLocalTime moment(), format