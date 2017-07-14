angular.module("mySensorService", ['ngLodash']).service("sensorService", ($http, $rootScope, $q, $log, lodash) ->
  self = @

  @.getSensors = ()->
    $http
      url: "/getSensors"
      method: "POST"
    .then (response) ->
      if response.data.sensors?
        return response.data.sensors
      else
        BootstrapDialog.alert({
          title: 'Could not get Sensor Information',
          message: response.data.err,
          type: BootstrapDialog.TYPE_DANGER
        })
        return []

  @.updateSensorTimeUnit = (sensorId, newTimeUnit)->
    $http
      url: "/updateSensorTimeUnit"
      method: "POST"
      data:
        sensorId: sensorId
        newTimeUnit: newTimeUnit
    .then (response) ->
      if response.data.sensor?
        return response.data.sensor
      else
        BootstrapDialog.alert({
          title: 'Could not change sensor time unit',
          message: response.data.err || '',
          type: BootstrapDialog.TYPE_DANGER
        })
        return null
    , (response) ->
      if response.data.err?
        BootstrapDialog.alert({
          title: 'Could not Update Time Unit',
          message: response.data.err,
          type: BootstrapDialog.TYPE_DANGER
        })
      else if response.data.warning?
        BootstrapDialog.alert({
          title: 'Could not Update Time Unit',
          message: response.data.warning,
          type: BootstrapDialog.TYPE_WARNING
        })

  @.updateDetectorName = (detectorId, newDetectorName)->
    $http
      url: "/updateDetectorName"
      method: "POST"
      data:
        detectorId: detectorId
        newDetectorName: newDetectorName
    .then (response) ->
      if response.data.success?
        return response.data.success
      else
        BootstrapDialog.alert({
          title: 'Could not Update Detector Name',
          message: response.data.err || '',
          type: BootstrapDialog.TYPE_DANGER
        })
        return null
    , (response) ->
      if response.data.err?
        BootstrapDialog.alert({
          title: 'Could not Update Detector Name',
          message: response.data.err,
          type: BootstrapDialog.TYPE_DANGER
        })
      else if response.data.warning?
        BootstrapDialog.alert({
          title: 'Could not Update Detector Name',
          message: response.data.warning,
          type: BootstrapDialog.TYPE_WARNING
        })

  @.upsertSensor = (sensor)->
    $http
      url: "/upsertSensor"
      method: "POST"
      data:
        sensor: sensor
    .then (response) ->
      if response.data.success?
        return true
      else
        BootstrapDialog.alert({
          title: 'Could not save/update sensor information',
          message: response.data.err || '',
          type: BootstrapDialog.TYPE_DANGER
        })
        return false
    , (response) ->
      if response.data.err?
        BootstrapDialog.alert({
          title: 'Could not Update Chamber',
          message: response.data.err,
          type: BootstrapDialog.TYPE_DANGER
        })
      else if response.data.warning?
        BootstrapDialog.alert({
          title: 'Could not Update Chamber',
          message: response.data.warning,
          type: BootstrapDialog.TYPE_WARNING
        })

  @.broadcastSensors = ()->
    $http
      url: "/broadcastSensors"
      method: "GET"
    .then (response) ->
      if response.data.success? && response.data.success == true
        return true
      else
        console.error "NOT WORKING", response
        return false

#////////////////////////////////////////////////////////////////////
  return
)