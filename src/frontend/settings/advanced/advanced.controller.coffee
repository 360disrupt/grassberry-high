angular.module "advanced", ['mySettingService', 'myChamberService', 'mySensorService', 'myOutputService', 'myRuleService', 'mySystemService', 'tsd.tutorial', 'tsd.unitFilter', 'cfp.hotkeys', 'ngLodash' , 'download', 'ngFileUpload']
  .controller "AdvancedCtrl", ($rootScope, $scope, $timeout, $resource, $filter, settingService, chamberService, outputService, sensorService, ruleService, hotkeys, authUserService, systemService, lodash, download, Upload) ->
    self = @
    @.chambers = []
    @.detectorOptions = []
    @.outputOptions = []

    @.cycleOptions = [{id: "mother" , name: "Mother/Clone" }, {id: "vegetation" , name: "Vegetation" }, {id: "bloom" , name: "Bloom" }, {id: "drying" , name: "Drying" }]
    @.conditionOptions = [{label:"goes above value (>)", rule:"above"}, {label:"goes below value (<)", above:"below"}]
    @.timeHourOptions = [0..23]
    @.timeMinuteOptions = [0..60]
    @.timer = null
    @.activeDevices = []
    @.units = { temperature: 'celsius' }
    @.blockedTillOptions = [{ value: 1, label:'1 minute' }, { value: 15, label:'15 minutes' }, { value: 30, label:'30 minutes' }, { value: 60, label:'1 hour' }, { value: 60*24, label:'1 day' }]
    #=============================== TUTORIAL ================================
    @.tutorialTexts = []
    $resource('./frontend/settings/advanced/advanced-tutorial.json').get (data)->
      self.tutorialTexts = data.texts

    #=============================== CHAMBERS ================================

    @.addNewChamber = ()->
      @.chambers.push {
        strains:[{}],
        light:{output: {}, startTime:new Date()},
        rules: [],
      }
      @.addNewRule @.chambers[@.chambers.length-1], 'fan'
      @.addNewRule @.chambers[@.chambers.length-1], 'pump'
      return

    #------------------------------- Strains------------------------------
    @.addNewStrain = (chamber, newStrain)->
      chamber.strains = [] if !chamber.strains?
      if !newStrain?
        newStrain = {name:null, daysToHarvest: null}
      else
        newStrain = JSON.parse JSON.stringify newStrain
      chamber.strains.push(newStrain)
      return

    #------------------------------- Rules------------------------------
    @.filterRules = (chamber, includedDevices)->
      return chamber.rules.filter (rule)->
        return includedDevices.some (device) -> rule.device == device

    @.addNewRule = (chamber, newRule)->
      chamber.rules = [] if !chamber.rules?
      if typeof newRule == 'string'
        newRule = {sensor:{}, output: {}, device: newRule}
        newRule.durationMBlocked = 60 if newRule.device == 'pump'
      else
        newRule = JSON.parse JSON.stringify newRule
        delete newRule._id
      chamber.rules.push(newRule)
      return

    @.removeOrClear = (chamber, rule, index)->
      removeIndex = _.findIndex chamber['rules'], (comparisonRule) -> _.isEqual(comparisonRule, rule)

      if chamber._id && chamber['rules'][removeIndex]._id?
        ruleService.removeRule(chamber._id, chamber['rules'][removeIndex]._id).then ->
      if index > 0
        chamber['rules'].splice(removeIndex,1)
      else
        newRule = {sensor:{}, output: {}, device: chamber['rules'][removeIndex].device}
        chamber['rules'][removeIndex] = newRule
      return

    #------------------------------- Outputs ------------------------------
    @.assignOutput = (parent)->
      filteredOutputs = @.outputOptions.filter (outputOption)->
        return outputOption._id == parent.output._id
      if filteredOutputs.length == 1
        parent.output = JSON.parse JSON.stringify filteredOutputs[0]
      return

    @.updateOutputOption = (output)->
      index = lodash.findIndex @.outputOptions, {_id: output._id}
      if index != -1
        @.outputOptions[index] = JSON.parse JSON.stringify output
      return

    @.reAssignOutputs = ()->
      for chamber in @.chambers
        @.assignOutput chamber.light
        @.assignOutput chamber.water
        for rule in chamber.rules
          @.assignOutput rule

    #------------------------------- Sensors/Detectors ------------------------------
    @.refreshSensor = (rule)->
      for detectorOption in @.detectorOptions
        if detectorOption['detectorId'] == rule['detectorId']
          for key, value of detectorOption
            rule[key] = value
          return
      return

    @.updateDetectorName = (rule)->
      $timeout.cancel(@.timer)
      @.timer = $timeout ()->
        $timeout.cancel(self.timer)
        sensorService.updateDetectorName(rule.detectorId, rule.detectorName).then ->
      , 1000
      return

    #================================ DUMMY HOTKEY ==============================
    hotkeys.add({
      combo: 'alt+d',
      description: 'Fill with dummy',
      callback: () ->
        chamberService.fillChamberWithDummy self.chambers[0]
    })

    #=============================== CRUD ================================
    #------------------------------- Chamber------------------------------
    @.getChambers = ()->
      chamberService.getChambers().then (chambers)->
        self.chambers = chambers
        if self.chambers.length == 0
          self.addNewChamber()
        else
          for chamber in self.chambers
            if !chamber.strains? || chamber.strains.length == 0
              self.addNewStrain(chamber)
            chamber.rules = [] if !chamber.rules?
            basicDevices = ['fan', 'pump']
            for device in basicDevices
              if !chamber.rules.some((rule)-> return rule.device == device)
                self.addNewRule(chamber, device)
        return

    @.upsertChamber = (chamber)->
      chamberService.upsertChamber(chamber).then (success)->
        if success == true
          self.getChambers()
        return

#----------------------------------- Export/Import --------------------------

    @.exportChamber = (chamber)->
      name = "settings.json"
      name = chamber._id + "_" + name if chamber._id?
      download.fromData(JSON.stringify(chamber), "application/json", name)

    @.fileChanged = ()->
      reader = new FileReader()
      reader.onload = ()->
        try
          importedChamber = JSON.parse(reader.result)
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

        index = lodash.findIndex self.chambers, {_id: importedChamber._id}
        if index != -1
          self.chambers[index] = importedChamber
        else
          self.chambers.push importedChamber


      reader.readAsText(self.file)
      return

    #------------------------------- Outputs------------------------------
    @.getOutputs = (callback)->
      outputService.getOutputs().then (outputs)->
        self.outputOptions = lodash.orderBy outputs, 'label'
        return callback()

    @.upsertOutputName = (output)->
      $timeout.cancel(@.timer)
      @.timer = $timeout ()->
        $timeout.cancel(self.timer)
        self.upsertOutput output
      , 1000
      return

    @.upsertOutput = (output)->
      outputService.upsertOutput(output).then ()->
        self.getOutputs ()->
          self.reAssignOutputs()
        return

    #------------------------------- Sensors------------------------------
    @.filterDetectors = (types)->
      return self.detectorOptions.filter (detector)->
        return types.some (type) -> detector.type == type

    @.getSensors = (callback)->
      sensorService.getSensors().then (sensors)->
        for sensor in sensors
          for index in [0...sensor.detectors.length]
            #if the sensor has more than one detector, make it appear as two or more separate sensors
            self.detectorOptions.push {sensor: { _id: sensor._id }, model: sensor.model}
            self.detectorOptions[self.detectorOptions.length-1].label = sensor.detectors[index].label
            self.detectorOptions[self.detectorOptions.length-1].type = sensor.detectors[index].type
            self.detectorOptions[self.detectorOptions.length-1].detectorName = sensor.detectors[index].name
            self.detectorOptions[self.detectorOptions.length-1].detectorId = sensor.detectors[index]._id
            self.detectorOptions[self.detectorOptions.length-1].forDetector = sensor.detectors[index].type

        return callback()

    @.upsertSensor = (sensor)->
      sensorService.upsertSensor(sensor).then ()->
        self.getSensors ()->
          # self.reAssignSensors()
        return

    #================================= INIT ==================================
    @.getChambers()
    @.getSensors(->)
    @.getOutputs(->)
    settingService.getActiveDevices().then (activeDevices)->
      self.activeDevices = activeDevices
      return

    systemService.getSystem().then (system)->
      if system?
        self.system = system
        self.units.temperature = $filter('unitFilter')('temperature', system.units.temperature) if system.units?
#///////////////////////////////////////////////////////////////////
    return