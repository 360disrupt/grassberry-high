inspect = require('eyespect').inspector({maxLength: null})
chalk = require('chalk')

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

    i2c.updateI2CAddress sensorType, oldAddress, newAddress, (err) ->
      return res.json({ err: err }) if err?
      return res.json({success: true})
  )


  #////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  return


