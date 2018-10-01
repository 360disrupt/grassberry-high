BAD_REQUEST = 400

inspect = require('util').inspect
chalk = require('chalk')

moment = require('moment')

routesService = require("./routes.service.js")
outputService = require('../output/output.service.js')
conversionHelper = require('../_helper/conversion.helper.js')

module.exports = (app, passport, user, environment) ->
  # output routes ===============================================================
  app.get('/broadcastOutputs', routesService.clean, (req, res) ->
    outputService.broadcastOutputs((err) ->
      if (err)
        return res.json({ err: err })
      return res.json(success: true)
    )
  )

  app.post('/getOutputs', routesService.clean, (req, res) ->
    options = req.body.options || {}
    outputService.getOutputs(options, (err, outputs) ->
      if (err)
        return res.json({ err: err })
      return res.json(outputs: outputs)
    )
  )

  app.post('/upsertOutput', routesService.clean, routesService.onShowModeBlocked, (req, res) ->
    return res.status(BAD_REQUEST).json({ err: "No output data" }) if !req.body.output?
    outputService.upsertOutput(req.body.output, (err, success) ->
      if (err)
        return res.json({ err: err })
      return res.json(success: success)
    )
  )

  app.put('/operateOutput', routesService.clean, (req, res) ->
    return res.status(BAD_REQUEST).json({ err: "Id is required" }) if !req.body.id?
    return res.status(BAD_REQUEST).json({ err: "Operation is required" }) if !req.body.operation?
    info = "Due user command #{conversionHelper.getLocalTime 'DD.MM HH:mm:ss'}"
    outputService.operateOutput(req.body.id, req.body.operation, info, null, (err, success) ->
      if (err)
        return res.json({ err: err })
      return res.json({success: true})
    )
  )
  #////////////////////////////////////////////////////////////ONLY ADMIN///////////////////////////////////////////////////////////////////////////////////////
  app.post('/operateRelayController', routesService.clean, routesService.isAdmin, (req, res) ->
    return res.status(BAD_REQUEST).json({ err: "Address is required" }) if !req.body.address?
    return res.status(BAD_REQUEST).json({ err: "Command is required" }) if !req.body.command?
    outputService.operateRelayController req.body.address, req.body.command, (err, success) ->
      if (err)
        return res.json({ err: err })
      return res.json({success: true})
  )

  #////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  return


