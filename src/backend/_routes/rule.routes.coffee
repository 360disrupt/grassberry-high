BAD_REQUEST = 400

inspect = require('util').inspect
chalk = require('chalk')

async = require('async')

routesService = require("./routes.service.js")
chamberService = require('../chamber/chamber.service.js')
ruleService = require('../rule/rule.service.js')

module.exports = (app, passport, user, environment) ->
  # sensor routes ===============================================================
  app.delete('/removeRule/:chamberId/:ruleId', routesService.clean, (req, res) ->
    return res.status(BAD_REQUEST).json({ err: "No chamberId" }) if !req.params.chamberId?
    return res.status(BAD_REQUEST).json({ err: "No ruleId" }) if !req.params.ruleId?
    async.series [
      (next)->
        chamberService.spliceRule req.params.chamberId, req.params.ruleId, next
      (next)->
        ruleService.removeRule req.params.ruleId, next
    ], (err)->
      return res.json({ err: err }) if (err)
      return res.json(success: true)
  )
  #////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  return


