inspect = require('util').inspect
chalk = require('chalk')

_ = require('lodash')

exports.compareObjects = (a, b)->
  _.reduce a, ((result, value, key) ->
    if _.isEqual(value, b[key]) then result else result.concat(key)
  ), []