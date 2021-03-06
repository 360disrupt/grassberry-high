angular.module("mySensorService", ['ngLodash']).service("sensorService", ($http, $rootScope, $q, $log, lodash) ->
  self = @

  @.getSensors = ()-> #get sensors registered in the system
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

  @.getSensorsRaw = (filter, options)-> #basic sensor information
    $http
      url: "/getSensorsRaw"
      method: "POST"
      data:
        filter: filter || {}
        options: options || {}
    .then (response) ->
      if response.data.sensors?
        return response.data.sensors
      else
        BootstrapDialog.alert({
          title: 'Could not get Sensors',
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
        BootstrapDialog.alert({
          title: 'Sensor saved',
          message: 'Your sensor has been saved',
          type: BootstrapDialog.TYPE_SUCCESS
        })
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


  @.removeSensor = (id)->
    $http
      url: "/removeSensor/#{id}"
      method: "DELETE"
    .then (response) ->
      if response.data?.success?
        BootstrapDialog.alert({
          title: 'Removed Sensor',
          message: 'Succesfuly removed sensor',
          type: BootstrapDialog.TYPE_SUCCESS
        })
        return true
      else
        BootstrapDialog.alert({
          title: 'Could not remove Sensor',
          message: response.data.err,
          type: BootstrapDialog.TYPE_DANGER
        })
        return false

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


  @.fillWithDummy = (sensor)->
    return sensor

#////////////////////////////////////////////////////////////////////
  return
)