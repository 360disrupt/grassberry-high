inspect = require('util').inspect
chalk = require('chalk')
debugRoutesI2c = require('debug')('routes:i2c')

routesService = require("./routes.service.js")
i2c = require('../i2c/i2c.js')

module.exports = (app, passport, user, environment) ->
  # chamber routes ===============================================================
  app.get('/getActiveDevices', routesService.clean, (req, res) ->
    i2c.getActiveDevices (err, activeDevices) ->
      if (err)
        return res.json({ err: err })
      return res.json(activeDevices: activeDevices)
  )

  app.post('/updateI2CAddress', routesService.clean, (req, res) ->
    requiredFields = {
      sensorType: "Sensor type is required."
      oldAddress: "Old address is required."
      newAddress: "New address is required."
    }
    err = []
    for key of requiredFields
      err.push requiredFields[key] if !req.body[key]?
    return res.json({ err: err.join(" ") }) if err.length > 0

    debugRoutesI2c req.body
    i2c.updateI2CAddress req.body.sensorType, req.body.oldAddress, req.body.newAddress, (err) ->
      return res.json({ err: err }) if err?
      return res.json({success: true})
  )


  #////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  return


