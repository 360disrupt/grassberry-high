CMD_SWITCH_ON = 0x01
CMD_SWITCH_OFF = 0x00

inspect = require('util').inspect
chalk = require('chalk')

async = require('async')
moment = require('moment')
debugRelais = require('debug')('relais')

socketIoMessenger = require('../_socket-io/socket-io-messenger.js')
logger = require('../_logger/logger.js').getLogger()
DataLogger = require('../data-logger/data-logger.class.js')
dataLogger = new DataLogger()

class Output
  constructor: (options) ->
    # console.info "options", options
    @._id = options._id || throw new Error("Id is required")
    @.label = options.label || throw new Error("Label is required")
    @.name = options.name if options.name?
    @.address = options.address || throw new Error("Address is required")
    @.relaisController = options.relaisController || throw new Error("Relais controller is required")
    @.state = 0
    @.blockedBy = null
    @.blockedTill = null
    # logger.info "Registered Output  #{inspect options}"
    return

#--------------------------- Database Operations -----------------------------
  # getCurrentState: (callback)->
  #   #TODO QUERY RELAIS # @.state = ANSWER
  #   return callback null, @.state
  createEvent: (state, info, callback)->
    dataLogger.createEvent @, state, info, callback

  switchOn: (info, detectorId, callback)->
    self = @
    return callback() if @.state == 1

    @.relaisController.switchRelais CMD_SWITCH_ON, @.address, (err)->
      return callback err if err?
      debugRelais "Switched output #{self.name} (#{self._id}) address #{self.address} ON was #{self.state}"
      self.blockedBy = detectorId
      self.state = 1
      self.broadcastOutput()
      self.createEvent 'on', info, callback

  switchOff: (info, detectorId, callback)->
    self = @
    return callback() if @.state == 0
    @.relaisController.switchRelais CMD_SWITCH_OFF, @.address, (err)->
      return callback err if err?
      debugRelais "Switched output #{self.name} (#{self._id}) address #{self.address} OFF was #{self.state}"
      self.blockedBy = null
      self.state = 0
      self.broadcastOutput()
      self.createEvent 'off', info, callback

  broadcastOutput: ()->
    socketIoMessenger.sendMessage('outputData', {'payload':@})
    return

  #TODO check if outputs need to be corrected after a power cut


#///////////////////////////////////////////////////////////////////////////////////////////////////
module.exports = Output
