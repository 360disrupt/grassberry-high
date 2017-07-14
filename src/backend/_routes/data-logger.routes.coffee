inspect = require('eyespect').inspector({maxLength: null})
chalk = require('chalk')

routesService = require("./routes.service.js")
dataLoggerService = require('../data-logger/data-logger.service.js')

module.exports = (app, passport, user, environment) ->
  # output routes ===============================================================
  app.post('/readEvents', routesService.clean, (req, res) ->
    console.time("readEvents")
    filterReadEvents = req.body.filterReadEvents || {}
    optionsReadEvents = req.body.optionsReadEvents || {}
    optionsReadEvents.limit = 10

    dataLoggerService.readEvents filterReadEvents, optionsReadEvents, (err, events) ->
      console.timeEnd("readEvents")
      if (err)
        return res.json({ err: err })
      return res.json(events: events)
  )

  #////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  return


