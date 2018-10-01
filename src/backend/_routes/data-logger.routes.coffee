inspect = require('util').inspect
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

  app.post('/clearEvents', routesService.clean, (req, res) ->
    filterClearEvents = req.body.filterReadEvents || {}
    optionsClearEvents = req.body.optionsReadEvents || {}
    dataLoggerService.clearEvents filterClearEvents, optionsClearEvents, (err) ->
      if (err)
        return res.json({ err: err })
      return res.json({success: true})
  )

  #////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  return


