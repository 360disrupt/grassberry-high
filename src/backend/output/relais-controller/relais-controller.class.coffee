RELAIS_CONTROLLER_ADDRESS = 0x20
BUS = 1
GPIO_REGISTER_ADDRESS = 0x09
IODIR_REGISTER_ADDRESS = 0x00
CMD_SWITCH_ON = 0x01
CMD_SWITCH_OFF = 0x00
#https://s3.amazonaws.com/controleverything.media/controleverything/Production%20Run%208/17_MCP23008_I2CR820/Mechanical/17_MCP23008_I2CR820_A.jpgƒ√

RELAIS_I = 0x01
RELAIS_II = 0x02
RELAIS_III = 0x03
RELAIS_IV = 0x04
RELAIS_V = 0x05
RELAIS_VI = 0x06
RELAIS_VII = 0x07
RELAIS_VIII = 0x08

inspect = require('util').inspect
chalk = require('chalk')
debugRelais= require('debug')('output:relais')

logger = require('../../_logger/logger.js').getLogger()

class RelaisController
  constructor: (options) ->
    @.i2c1 = require('../../i2c/i2c.js').getI2cBus()
    @.currentState = 0x00
    @.address = RELAIS_CONTROLLER_ADDRESS
    if process.env.RELAIS_MAPPING?
      @.addressMapping = process.env.RELAIS_MAPPING.split(',').map (entry)->
        return parseInt(entry)
    else
      @.addressMapping = [8, 6, 4, 2, 7, 5, 3, 1] #relais are position diff. to outlets
    @.bootRelaisController (err)->
      logger.error if err?

  bootRelaisController: (callback)->
    self = @
    return callback "I2c not booted" if !@.i2c1?
    # console.error "WRITNG: RELAIS_CONTROLLER_ADDRESS #{RELAIS_CONTROLLER_ADDRESS} #{typeof RELAIS_CONTROLLER_ADDRESS} IODIR_REGISTER_ADDRESS #{IODIR_REGISTER_ADDRESS} #{typeof IODIR_REGISTER_ADDRESS} 0x00"
    @.i2c1.writeByte RELAIS_CONTROLLER_ADDRESS, IODIR_REGISTER_ADDRESS, 0x00, (err)->
      return callback err if err?
      return callback()

  switchRelais: (command, address, callback)->
    self = @
    debugRelais "MAPPED #{address} => #{@.addressMapping[address-1]}"
    address = @.addressMapping[address-1]
    #1 = R1, 2 = R2, 4 = R3, R1+R2+R3 = 7
    amount = Math.pow(2, address-1)
    debugRelais "state #{@.currentState} address #{address} 2^#{address-1} = amount #{amount}"

    if command == CMD_SWITCH_ON
      debugRelais "SWITCH ON"
      @.currentState += amount

    else
      debugRelais "SWITCH OFF"
      @.currentState -= amount

    debugRelais "NEW STATE #{@.currentState}"
    if @.i2c1?
      debugRelais "SWITCHING I2C #{command} RELAIS #{self.currentState} \n\n"
      @.i2c1.writeByte RELAIS_CONTROLLER_ADDRESS, GPIO_REGISTER_ADDRESS, self.currentState, (err) ->
        return callback err if err?
        return callback()
    else
      return callback "I2C not booted"

#///////////////////////////////////////////////////////////////////////////////////////////////////
module.exports = RelaisController