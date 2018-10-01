inspect = require('util').inspect
chalk = require('chalk')

routesService = require("./routes.service.js")
debugHelper = require("../_helper/debug.helper.js")

module.exports = (app, passport, user, environment) ->
  app.get('/getDbSize/:collection', (req, res)->
    debugHelper.getDbSize req.params.collection, (err, dbSize)->
      return res.json({ err: err }) if err?
      return res.json(dbSize: dbSize)
  )
  #////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  return

