BAD_REQUEST = 400

inspect = require('util').inspect
chalk = require('chalk')

async = require('async')

routesService = require("./routes.service.js")
restHelper = require('../_api/rest.helper.js')
apiEndpoints = require('../_api/api-endpoints.js')()
shellService  = require('../shell/shell.service.js')

module.exports = (app, passport, user, environment) ->
  # sensor routes ===============================================================
  app.post('/sendFeedback', routesService.clean, (req, res) ->
    return res.status(BAD_REQUEST).json({ err: "No feedback data" }) if !req.body.feedback?
    async.waterfall [
      (next)->
        shellService.getSerial next
      (serial, next)->
        method = 'POST'
        url = apiEndpoints['feedback']
        data = { feedback: req.body.feedback, serial: serial }
        restHelper.emit method, url, data, next
    ], (err)->
      return res.json({ err: err }) if (err)
      return res.json(success: true)
  )
  #////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  return