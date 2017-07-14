inspect = require('util').inspect
chalk = require('chalk')
debugBoot = require('debug')('boot')

async = require('async')

outputService = require('../output/output.service.js')
sensorService = require('../sensor/sensor.service.js')
cronjobService = require('../cronjob/cronjob.service.js')

exports.bootSensorsAndOutputs = (options, callback)->
  async.parallel
    sensors: (next)->
      return next() if options.noSensors == true
      debugBoot "-->Booting Sensors<--"
      sensorService.bootSensors(options, next)
    outputs: (next)->
      return next() if options.noOutputs == true
      debugBoot "-->Booting Outputs<--"
      outputService.bootOutputs(options, next)
    cronjobs: (next)->
      return next() if options.noCrons == true
      return next() if process.env.NO_CRONS?
      debugBoot "-->Booting Cronjobs<--"
      cronjobService.launchCronjobs next
    callback
