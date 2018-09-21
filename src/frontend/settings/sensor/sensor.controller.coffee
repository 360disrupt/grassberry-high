angular.module "sensor", ['mySystemService', 'mySettingService', 'mySensorService', 'tsd.unitFilter', 'cfp.hotkeys', 'ngLodash' , 'download', 'ngFileUpload']
  .controller "SensorCtrl", ($rootScope, $scope, $timeout, $resource, $filter, systemService, settingService, $cookies, sensorService, hotkeys, authUserService, lodash, download, Upload) ->
    self = @
    $scope.developer = $cookies.get('developer') == 'true'

    @.sensors = []
    @.units = { temperature: 'celsius' }
    @.technologyOptions = [{longName:'I2C (Controll Everything)', shortName: 'i2c'}, {longName:'Bluetooth Low Energy', shortName: 'ble'}]

    @.modelOptions = {
      i2c: [ "hdc1000", "chirp", "mhz16" ]
      ble: [ "sensorTag" ]
    }

    @.typeOptions = {
      hdc1000: [ {longName:'Temperature', shortName: 'temperature'}, {longName:'Humidity', shortName: 'humidity'} ]
      chirp: [ {longName:'Water', shortName: 'water'} ]
      mhz16: [ {longName:'Co2', shortName: 'co2'} ]
      sensorTag: [ {longName:'Temperature', shortName: 'temperature'}, {longName:'Humidity', shortName: 'humidity'} ]
    }

    @.images = {
      hdc1000: 'hdc1000.png'
      chirp: 'chirp.png'
      mhz16: 'mhz16.png'
    }

    @.addNewSensor = ()->
      self.sensors.push { "technology": "i2c"}

    @.removeSensor = (sensor, index)->
      BootstrapDialog.confirm({
        title: 'Do you really want to delete this sensor?',
        message: 'Please choose:',
        type: BootstrapDialog.TYPE_DANGER,
        callback: (success)->
          if success
            sensorService.removeSensor(sensor._id).then (success)->
              self.sensors.splice(index, 1)
              return
      })

    @.addDetectors = (sensor)->
      switch sensor.model
        when 'hdc1000'
          sensor.detectors = [{type: 'temperature'}, {type: 'humidity'}]
        when 'chirp'
          sensor.detectors = [{type: 'water'}]
        when 'mhz16'
          sensor.detectors = [{type: 'co2'}]
      return

    #================================ DUMMY HOTKEY ==============================
    hotkeys.add({
      combo: 'alt+d',
      description: 'Fill with dummy',
      callback: () ->
        sensorService.fillWithDummy self.sensors[self.sensors.length-1]
    })

    #=============================== CRUD ================================
    #------------------------------- Sensor------------------------------
    @.getSensorsRaw = ()->
      sensorService.getSensorsRaw().then (sensors)->
        self.sensors = sensors
        if self.sensors.length == 0
          self.addNewSensor()
        else
          self.sensors = sensors
        return

    @.upsertSensor = (sensor)->
      sensorService.upsertSensor(sensor).then (success)->
        return

#----------------------------------- Export/Import --------------------------

    @.exportSensor = (sensor)->
      name = "sensor.json"
      name = sensor._id + "_" + name + "_" + sensor.model + ".json" if sensor._id?
      download.fromData(angular.toJson(lodash.omit(sensor, '__v')), "application/json", name)

    @.fileChanged = ()->
      reader = new FileReader()
      reader.onload = ()->
        try
          importedSensor = JSON.parse(reader.result)
          BootstrapDialog.alert({
            title: 'Imported Settings',
            message: 'Please review and save',
            type: BootstrapDialog.TYPE_INFO
          })
        catch err
          BootstrapDialog.alert({
            title: 'Could not Import Settings',
            message: err,
            type: BootstrapDialog.TYPE_DANGER
          })

        index = lodash.findIndex self.sensors, {_id: importedSensor._id}
        if index != -1
          self.sensors[index] = importedSensor
        else
          self.sensors.push importedSensor


      reader.readAsText(self.file)
      return

    #================================= LISTENER ============================
    $scope.$watch ()->
      return $cookies.get('developer') == 'true'
    , (newValue)->
      $scope.developer = newValue
      return

    #================================= INIT ==================================
    @.getSensorsRaw()

    systemService.getSystem().then (system)->
      if system?
        self.system = system
        self.units.temperature = $filter('unitFilter')('temperature', system.units.temperature) if system.units?
#///////////////////////////////////////////////////////////////////
    return