RELAIS_CONTROLLER_ADDRESS = 0x20

CMD_SWITCH_ON = 0x01
CMD_SWITCH_OFF = 0x00

inspect = require('util').inspect
chalk = require('chalk')

logger = require('../../../_logger/logger.js').getLogger()

class RelaisControllerMock
  constructor: (options) ->
    @.currentState = 0x00
    @.address = RELAIS_CONTROLLER_ADDRESS
    @.bootRelaisController (err)->
      logger.error if err?

  bootRelaisController: (callback)->
    return callback()

  switchRelais: (command, address, callback)->
    self = @
    amount = Math.pow(2, address-1)
    if command == CMD_SWITCH_ON
      console.log "SWITCH ON"
      @.currentState += amount

    else
      console.log "SWITCH OFF"
      @.currentState -= amount

    console.log "NEW STATE #{@.currentState}"

    return callback()


#///////////////////////////////////////////////////////////////////////////////////////////////////
module.exports = RelaisControllerMock