BAD_REQUEST = 400

inspect = require('util').inspect
chalk = require('chalk')

async = require('async')

routesService = require("./routes.service.js")
sensorService = require('../sensor/sensor.service.js')
sensorCreateUpdate = require('../sensor/sensor.create-update.js')
sensorDelete = require('../sensor/sensor.delete.js')

module.exports = (app, passport, user, environment) ->
  # sensor routes ===============================================================
  app.get('/broadcastSensors', routesService.clean, (req, res) ->
    sensorService.broadcastSensors((err) ->
      if (err)
        return res.json({ err: err })
      return res.json(success: true)
    )
  )

  app.post('/getSensorsRaw', routesService.clean, (req, res) ->
    filter = req.body.filter || {}
    options = req.body.options || {}
    sensorService.getSensorsRaw(filter, options, (err, sensors) ->
      if (err)
        return res.json({ err: err })
      return res.json(sensors: sensors)
    )
  )

  app.post('/getSensors', routesService.clean, (req, res) ->
    options = req.body.options || {}
    sensorService.getSensors(options, (err, sensors) ->
      if (err)
        return res.json({ err: err })
      return res.json(sensors: sensors)
    )
  )

  app.post('/upsertSensor', routesService.clean, routesService.onShowModeBlocked, (req, res) ->
    return res.status(BAD_REQUEST).json({ err: "No sensor data" }) if !req.body.sensor?
    sensorCreateUpdate.upsertSensor(req.body.sensor, {}, (err, success) ->
      if (err)
        return res.json({ err: err })
      return res.json(success: success)
    )
  )

  app.post('/updateSensorTimeUnit', routesService.clean, routesService.onShowModeBlocked, (req, res) ->
    options = req.body.options || {}
    sensorId = req.body.sensorId || null
    newTimeUnit = req.body.newTimeUnit || null
    sensorService.updateSensorTimeUnit(sensorId, newTimeUnit, options, (err, sensor) ->
      if (err)
        return res.json({ err: err })
      return res.json(sensor: sensor)
    )
  )

  app.post('/updateDetectorName', routesService.clean, routesService.onShowModeBlocked, (req, res) ->
    return res.status(BAD_REQUEST).json({ err: "No new detector name" }) if !req.body.newDetectorName?
    options = req.body.options || {}
    detectorId = req.body.detectorId
    newDetectorName = req.body.newDetectorName
    sensorCreateUpdate.updateDetectorName(detectorId, newDetectorName, options, (err) ->
      if (err)
        return res.json({ err: err })
      return res.json(success: true)
    )
  )

  app.delete('/removeSensor/:id', routesService.clean, (req, res) ->
    return res.status(BAD_REQUEST).json({ err: "No sensor id" }) if !req.params.id?
    id = req.params.id
    async.series [
      (next)->
        sensorDelete.removeSensor id, {}, next
      (next)->
        sensorService.bootSensors {}, next
    ], (err)->
      return res.json({ err: err }) if err?
      return res.json({ success: true })
  )

  #////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  return


