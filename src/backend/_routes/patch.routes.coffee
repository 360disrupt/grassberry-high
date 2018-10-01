BAD_REQUEST = 400

inspect = require('util').inspect
chalk = require('chalk')

async = require('async')

routesService = require("./routes.service.js")
patchService = require("../patch/patch.service.js")

module.exports = (app, passport, user, environment) ->
  app.get('/addOutputs', routesService.clean, (req, res) ->
    patchService.addOutputs (err)->
      return res.json({ err: err }) if (err)
      return res.json(success: true)
  )
  #////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  return