inspect = require('util').inspect
chalk = require('chalk')

async = require('async')
moment = require('moment')

DataLogger = require('./data-logger.class.js')
dataLogger = new DataLogger()

exports.readEvents = dataLogger.readEvents
exports.clearEvents = dataLogger.clearEvents