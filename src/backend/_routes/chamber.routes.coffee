BAD_REQUEST = 400

inspect = require('util').inspect
chalk = require('chalk')

routesService = require("./routes.service.js")
chamberService = require('../chamber/chamber.service.js')

module.exports = (app, passport, user, environment) ->
  # chamber routes ===============================================================
  app.post('/getChambers', routesService.clean, (req, res) ->
    options = req.body.options || { lean: true, populate: {all: true} }
    chamberService.getChambers(options, (err, chambers) ->
      if (err)
        return res.json({ err: err })
      return res.json(chambers: chambers)
    )
  )

  app.post('/upsertChamber', routesService.clean, routesService.onShowModeBlocked, (req, res) ->
    return res.status(BAD_REQUEST).json({ err: "No chamber data" }) if !req.body.chamber?
    chamberService.upsertChamber(req.body.chamber, (err, upsertedChamber) ->
      if (err)
        return res.json({ err: err })
      return res.json(upsertedChamber: upsertedChamber)
    )
  )
  #////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  return


