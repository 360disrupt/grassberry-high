inspect = require('util').inspect
chalk = require('chalk')

logger = require('../_logger/logger.js').getLogger()

self = @
#================================================== LOG & ERROR HELPERS ============================
exports.powerLog = (what)->#require('.backend/_helper/helper.service.js').powerLog(response)
  for i in [0..5]
    console.log '#######################################################################'
    console.log '\n\n\n'
  console.log what
  for i in [0..5]
    console.log '#######################################################################'
    console.log '\n\n\n'

exports.dumpError = (err) ->
  if typeof err == 'object'
    if err.message
      console.log '\nMessage: ' + err.message
    if err.stack
      console.log '\nStacktrace:'
      console.log '===================='
      console.trace err
      logger.error err.stack
  else
    console.log 'dumpError :: argument is not an object'
  return

exports.errorHelper = (err, propertyTranslator, callback) ->
  return callback [] if !err?
  #If it isn't a mongoose-validation error, just throw it.
  if err.name != 'ValidationError'
    return callback(err)
  messages =
    'required': '%s wird benötigt.'
  #A validationerror can contain more than one error.
  errors = []
  #Loop over the errors object of the Validation Error
  Object.keys(err.errors).forEach (field) ->
    eObj = err.errors[field]
    #If we don't have a message for `type`, just push the error through
    if eObj.kind == 'user defined'
      errors.push eObj.message
    else if !messages.hasOwnProperty(eObj.kind)
      errors.push eObj.kind
    else
      msg = require('util').format(messages[eObj.kind], eObj.path)
      msg = msg.replace(eObj.path, propertyTranslator[eObj.path]) if propertyTranslator[eObj.path]?
      errors.push msg
    return
  callback {errors: errors}