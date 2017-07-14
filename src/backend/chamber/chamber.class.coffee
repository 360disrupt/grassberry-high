inspect = require('util').inspect
chalk = require('chalk')

moment = require('moment')
mongoose = require('mongoose')
_ = require('lodash')

ChamberModel = require('../chamber/chamber.model.js').getModel()

socketIoMessenger = require('../_socket-io/socket-io-messenger.js')
logger = require('../_logger/logger.js').getLogger()

class Chamber
  constructor: (options) ->
    # console.info "options", options
    @._id = options._id || throw new Error("Id is required")
    @.name = options.name || throw new Error("Name is required")
    @.strains = options.strains || throw new Error("At least one strain is required")
    @.light = options.light || {}
    @.sensorIds = options.sensorIds || []
    @.day = options.day if options.day?
    @.cycle = options.cycle if options.cycle?


    logger.info "Registered Chamber  #{inspect options}"
    return

#--------------------------- Database Operations -----------------------------
  save: (callback)->
    console.info @
    chamber = new ChamberModel(@)
    chamber.save (err, chamber) ->
      logger.error err if err?
      return callback()

  update: (callback)->
    ChamberModel.findOneAndUpdate(@._id, @).exec (err, chamber) ->
      return callback new Error err if err?
      return callback null, chamber

  upsert: (callback)->
    ChamberModel.findOneAndUpdate(@._id,  _.omit(@, '_id'), {upsert: true}).exec (err, chamber) ->
      return callback new Error err if err?
      return callback null, chamber

  registerSensor: (sensorId, callback)->
    if @.sensors.indexOf != -1
      return callback new Error "This sensor was already registered"
    else
      @.sensors.push sensorId
      @.update callback

#///////////////////////////////////////////////////////////////////////////////////////////////////
module.exports = Chamber
