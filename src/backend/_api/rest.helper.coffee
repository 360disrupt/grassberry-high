inspect = require('util').inspect
chalk = require('chalk')

_ = require('lodash')
request = require('request')

ObjectId = require('mongoose').Types.ObjectId

logger = require('../_logger/logger.js').getLogger()
debugApi = require('debug')('api')

token = process.env.API_TOKEN || 'newKidsOntheBlock'
self = @

exports.bsonToJson = (bson) ->
  #mongoose object
  if bson.toObject?
    bson = bson.toObject('depopulate':true)

  #mongoose ID
  else if bson instanceof ObjectId
    bson = bson.toString()

  if ['array', 'object'].indexOf(comparisonHelper.determineType(bson)) != - 1
    bson = _.forEach bson, (value, key)->
      if value?
        bson[key] = self.bsonToJson bson[key]
      else
        delete bson[key]
      return

  return bson

addMethod = (method, url)->
  switch method.toLowerCase()
    when 'post'
      return request.post url
    when 'get'
      return request.get url
    when 'update'
      return request.update url
    when 'delete'
      return request.delete url
    else
      throw new Error("method not supported")

addData = (emitRequest, method, data)->
  switch method.toLowerCase()
    when 'post'
      return emitRequest.json data
    when 'get'
      return emitRequest
    when 'update'
      return emitRequest.json data
    when 'delete'
      return emitRequest
    else
      throw new Error("method not supported")

exports.emit = (method, url, data, callback) ->
  emitRequest = addMethod(method, url).auth null, null, true, token
  emitRequest = addData(emitRequest, method, data)
    .on('response', (res) ->
      if res.statusCode == 200
        data = ""
        res.on('data', (chunk) ->
          data += chunk
          # debugApi chunk + "\n"
        )
        res.on('end', () ->
          try
            data = JSON.parse(data.toString())
            return callback "No response #{url}, #{method.toUpperCase()}" if !data?
            return callback data.err if data.err?
            return callback null, data
          catch err
            require('../_helper/log-error.helper.js').dumpError(err)
            return callback "Response invalid #{err}}, #{url}, #{method.toUpperCase()}"
        )
      else
        logger.warn "Error: #{res.statusCode}, #{url}, #{method.toUpperCase()}", {data: data}
        return callback "Error: #{res.statusCode}, #{url}, #{method.toUpperCase()}"
      )
      .on('error', (err) ->
        logger.warn "Error no connection #{url}, #{method.toUpperCase()}", {err: err}
        return callback "Error no connection #{url}, #{method.toUpperCase()}"
      )