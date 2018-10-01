CMD_SWITCH_ON = 0x01
CMD_SWITCH_OFF = 0x00

inspect = require('util').inspect
chalk = require('chalk')
debugOutput = require('debug')('output')

mongoose = require('mongoose')
async = require('async')
moment = require('moment')
_ = require('lodash')

ObjectId = mongoose.Types.ObjectId
Output = require('./output.class.js')
OutputModel = require('./output.model.js').getModel()
if process.env.SIMULATION == 'true'
  RelaisController = require('./relais-controller/mocks/relais-controller.class.mock.js')
else
  RelaisController = require('./relais-controller/relais-controller.class.js')

systemRead = require('../system/system.read.js')
i2c = require('../i2c/i2c.js')

@.outputs = []
self = @

exports.bootOutputs = (options, callback)->
  relaisController = new RelaisController()
  self.outputs = [] if options.additive != true
  OutputModel.find({}).lean().exec (err, outputsFound) ->
    return callback err if err?
    return callback "No outputs found" if !outputsFound? || outputsFound.length == 0
    if i2c.adressInActiveDevices relaisController.address
      for output in outputsFound
        output.relaisController = relaisController
        newOutput = new Output(output)
        self.outputs.push newOutput if !~_.findIndex(self.outputs, { 'address': newOutput.address }) #if not already in stack
    debugOutput "booted #{self.outputs.length} outputs, #{outputsFound.length} are not active"
    return callback()

exports.getOutputById = (id, callback)->
  for output in @.outputs
    if output._id.toString() == id.toString()
      return callback null, output
  return callback "No ouptut with this ID"

exports.getActiveOutputs = ()->
  return @.outputs

exports.getOutputState = (id)->
  selectedOutput = @.outputs.filter (output)-> output._id.toString() == id.toString()
  return null if selectedOutput.length == 0
  return selectedOutput[0].state || 0

exports.getOutputs = (options, callback)->
  if options.filter?._id?
    for output in @.outputs
      if output._id.toString() == options.filter._id
        return callback null, [output]
  return callback null, @.outputs

exports.upsertOutput = (upsertOutput, callback)->
  upsertOutput._id = new mongoose.mongo.ObjectID() if !upsertOutput._id
  delete upsertOutput.__v
  OutputModel.findOneAndUpdate({_id: upsertOutput._id}, _.omit(upsertOutput,'_id'), {"upsert": true, "new": true}).exec (err, upsertOutput) ->
    return callback err if err?
    self.bootOutputs {}, ->
      return callback null, upsertOutput

exports.broadcastOutputs = (callback)->
  for output in @.outputs
    output.broadcastOutput()
  return callback null, true

exports.operateOutput = (outputId, operation, info, detectorId, callback)->
  return callback "Invalid operation" if !['switchOn', 'switchOff'].some (allowedOperations) -> allowedOperations == operation
  options = {filter: {id: new ObjectId(outputId)}}
  async.series [
    (next)->
      systemRead.isValid (err, validity)->
        return next err if err?
        debugOutput "validity", validity
        return next "No license or license has run out" if validity == false
        return next()
    (next)->
      self.getOutputById outputId, (err, output)->
        return next err if err?
        debugOutput "output", output
        return next err if !output?
        output[operation] info, detectorId, next
  ], callback


exports.blockOutput = (outputId, blockedTill, callback)->
  self.getOutputById outputId, (err, output)->
    return callback err if err?
    output.blockedTill = moment().add(blockedTill, 'minutes')
    debugOutput "#{output.device} #{outputId} is blocked till #{output.blockedTill.format('HH:mm DD.MM.YYYY')}"
    return callback null, output

#/////////////////////////////////////// only admin ///////////////////////////////////////////////
exports.operateRelayController = (command, address)->
  commands = {
    'on': CMD_SWITCH_ON
    'off': CMD_SWITCH_OFF
  }
  command = commands[command]
  return callback "Invalid operation choose on or off" if !command?
  return callback "Invalid number choose a number between 1-8" if !([1..8].some (nr)-> nr == relay)
  RelaisController.switchRelais command, address, callback
