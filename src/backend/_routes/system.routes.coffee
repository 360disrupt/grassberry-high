BAD_REQUEST = 400

inspect = require('util').inspect
chalk = require('chalk')

async = require('async')

routesService = require("./routes.service.js")
systemRead = require('../system/system.read.js')
systemUpdate = require('../system/system.update.js')
systemSupport = require('../system/system.support.js')
shellService = require('../shell/shell.service.js')

module.exports = (app, passport, user, environment) ->
  # chamber routes ===============================================================
  app.get('/getSystem', routesService.clean, (req, res) ->
    options = req.params.options || { }
    systemRead.getSystem(options, (err, system) ->
      if (err)
        return res.json({ err: err })
      return res.json(system: system)
    )
  )

  app.get('/getLicenseInformation', routesService.clean, (req, res) ->
    options = req.params.options || { }
    systemUpdate.getLicenseInformation(options, (err) ->
      if (err)
        return res.json({ err: err })
      return res.json({ success: true })
    )
  )

  app.get('/updateSoftware', routesService.clean, (req, res) ->
    options = {}
    systemUpdate.updateSoftware(options, (err, results) ->
      if (err)
        return res.json({ err: err })
      return res.json(results: results)
    )
  )

  app.post('/updateSystem', routesService.clean, (req, res) ->
    return res.status(BAD_REQUEST).json({ err: "No system" }) if !req.body.system?
    appUser = req.user || null
    data = req.body.system
    options = {}
    systemUpdate.updateSystem(appUser, data, options, (err, system) ->
      if (err)
        return res.json({ err: err })
      return res.json(system: system)
    )
  )

  app.post('/configureDateTime', routesService.clean, routesService.onShowModeBlocked, (req, res) ->
    return res.status(BAD_REQUEST).json({ err: "No date/time config" }) if !req.body.dateTimeConfig?
    appUser = req.user || null
    dateTimeConfig = req.body.dateTimeConfig
    async.series [
      (next)->
        options = {}
        systemUpdate.updateSystem appUser, dateTimeConfig, options, next
      (next)->
        shellService.configureDateTime dateTimeConfig, next
    ], (err)->
      return res.json({ err: err }) if (err)
      return res.json(success: success)
  )

  app.get('/sendLogs', routesService.clean, (req, res) ->
    options = req.params.options || { }
    systemSupport.sendLogs(options, (err) ->
      if (err)
        return res.json({ err: err })
      return res.json({status: "System report has been sent."})
    )
  )

  app.get('/reset', routesService.clean, routesService.onShowModeBlocked, (req, res) ->
    async.waterfall [
      (next)->
        systemUpdate.reset next
      (next)->
        shellService.reset next
    ], (err, success)->
      return res.json({ err: err }) if err?
      return res.json({ success: success }) #will never be called when raspi reboots
  )
  #////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  return


