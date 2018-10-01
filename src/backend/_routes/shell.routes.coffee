BAD_REQUEST = 400

inspect = require('util').inspect
chalk = require('chalk')

routesService = require("./routes.service.js")
shellService = require('../shell/shell.service.js')

module.exports = (app, passport, user, environment) ->
#==================================================== USERS ====================================================
  app.get('/getWifiOptions', routesService.clean, (req, res) ->
    shellService.getWifiOptions((err, wifiOptions) ->
      if (err)
        return res.json({ err: err })
      return res.json(wifiOptions: wifiOptions)
    )
  )

  app.post('/configureWifi', routesService.clean, routesService.onShowModeBlocked, (req, res) ->
    return res.status(BAD_REQUEST).json({ err: "No wifi" }) if !req.body.wifi?
    shellService.configureWifi(req.body.wifi, (err, success) ->
      if (err)
        return res.json({ err: err })
      return res.json(success: success)
    )
  )

  app.get('/getSerial', routesService.clean, (req, res) ->
    shellService.getSerial((err, serial) ->
      if (err)
        return res.json({ err: err })
      return res.json(serial: serial)
    )
  )

  app.get('/reboot', routesService.clean, routesService.onShowModeBlocked, (req, res) ->
    appUser = req.user || null
    options = {}
    shellService.reboot appUser, options, (err) ->
      return res.json({ err: err }) if err?
      return res.json({}) #never gets called
  )