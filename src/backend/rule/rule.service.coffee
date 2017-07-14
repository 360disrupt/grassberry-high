inspect = require('util').inspect
chalk = require('chalk')
debugRules = require('debug')('rules')

mongoose = require('mongoose')
async = require('async')
moment = require('moment')
_ = require('lodash')

RuleModel = require('./rule.model.js').getModel()


self = @

exports.getRules = (options, callback)->
  filter = options.filter || {}
  debugRules "filter", filter
  RuleModel.find(filter).exec (err, rulesFound) ->
    return callback err if err?
    return callback null, rulesFound

exports.upsertRule = (upsertRule, callback)->
  upsertRule._id = new mongoose.mongo.ObjectID() if !upsertRule._id
  RuleModel.findOneAndUpdate({_id: upsertRule._id}, _.omit(upsertRule, '_id'), {'upsert': true, 'new': true}).exec (err, result) ->
    return callback err if err?
    return callback null, result

exports.removeRule = (_id, callback)->
  RuleModel.remove({_id: _id}).exec (err, result) ->
    return callback err if err?
    return callback null, result
