inspect = require('util').inspect
chalk = require('chalk')

MHZ16 = 77

#mhz16
IOCONTROL   = 0x0e << 3
FCR         = 0x02 << 3
LCR         = 0x03 << 3
DLL         = 0x00 << 3
DLH         = 0x01 << 3
THR         = 0x00 << 3
RHR         = 0x00 << 3
TxLVL       = 0x08 << 3
RxLVL       = 0x09 << 3

exports.open = (bus, callback)->
  bus = {
    scan: (callback)->
      devices = [64, 77, 32, 33] #humidty/temp, co2, relais controller
      return callback null, devices

    readByte: (address, command, callback)->
      switch address
        when 77
          switch command
            when TxLVL
              bytes = 9
            when RxLVL
              bytes = 9
            else
              bytes = 0
          return callback null, bytes
        else
          bytes = 0
          return callback null, bytes

    writeByte: (address, register, byte, callback)->
      return callback null

    sendByte: (address, byte, callback)->
      return callback null

    receiveByte: (address, callback)->
      setTimeout ()->
        return callback null, 0
      , 500

    writeI2cBlock: (address, register, blockLength, block, callback)->
      buffer = Buffer.from([0,1,2,3,4,5,6,7,8])
      return callback null, buffer.length, buffer

    readI2cBlock: (address, register, readLength, readBuffer, callback)->
      readBuffer = Buffer.from([0xff,0x9c,0x00,0x00,0x05,0x08,0x00,0x00,0x57])
      return callback null
  }
  setTimeout callback, 500
  return bus

exports.adressInActiveDevices = (address)->
  return true