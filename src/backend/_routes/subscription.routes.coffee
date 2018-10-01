BAD_REQUEST = 400

inspect = require('util').inspect
chalk = require('chalk')
debugRoutes = require('debug')('routes:subscription')

async = require('async')

routesService = require("./routes.service.js")
restHelper = require('../_api/rest.helper.js')
apiEndpoints = require('../_api/api-endpoints.js')()
shellService  = require('../shell/shell.service.js')

module.exports = (app, passport, user, environment) ->
  # sensor routes ===============================================================
  app.post('/sendSubscription', routesService.clean, (req, res) ->
    subscription = req.body
    debugRoutes inspect req.body
    debugRoutes inspect subscription
    return res.status(BAD_REQUEST).json({ err: "Something went wrong" }) if !subscription.stripeToken?
    async.waterfall [
      (next)->
        shellService.getSerial next
      (serial, next)->
        subscription.serial = serial
        method = 'POST'
        url = apiEndpoints['subscription']
        restHelper.emit method, url, subscription, next
    ], (err)->
      if err?
        debugRoutes inspect err
        return res.redirect("/#!/subscription?err=#{JSON.stringify err}")
      return res.redirect('/#!/subscription?success=true')
  )
  #////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  return