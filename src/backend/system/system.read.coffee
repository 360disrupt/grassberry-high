inspect = require('util').inspect
chalk = require('chalk')

mongoose = require('mongoose')
async = require('async')
moment = require('moment')

SystemModel = require('./system.model.js').getModel()
self = @

exports.getSystem = (options, callback)->
  filter = options.filter || {}
  SystemModel.findOne(filter).exec (err, system) ->
    return callback err if err?
    return callback null, system

exports.isValid = (callback)->
  options = {}
  self.getSystem options, (err, system)->
    return callback err if err?
    return callback null, false if !system?.validTill?
    return callback null, moment(system.validTill).diff(moment(), 'seconds') > 0