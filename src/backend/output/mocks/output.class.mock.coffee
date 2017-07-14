inspect = require('util').inspect
chalk = require('chalk')

Output = require('../output.class.js')

class OutputMock extends Output
  constructor: (options) ->
    that = @
    super(options)
    return

  createEvent: (state, info, callback)->
    return calback()

  switchOn: (info, detectorId, callback)->
    return calback()

  switchOff: (info, detectorId, callback)->
    return calback()

  broadcastOutput: ()->
    return

#/////////////////////////////////////////////////////////////////////////////////////////////////////
module.exports = OutputMock