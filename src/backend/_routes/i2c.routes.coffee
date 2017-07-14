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


  #////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  return


