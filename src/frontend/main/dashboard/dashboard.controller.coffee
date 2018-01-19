angular.module "dashboard"
  .controller "DashboardCtrl", ($rootScope, $scope, $http, $timeout, $cookies, Flash, chartService, simulationService, chamberService, outputService, sensorService, dataService, settingService, authUserService) ->
    self = @
    $scope.developer = $cookies.get('developer') == 'true'
    @.infoHidden = false
    @.activeDevices = []
    @.chambers = []
    @.sensors = []
    @.fakeWarnings = simulationService.getFakeWarnings()
    # @.today = new Date()

    @.toggleInfo = (chamber)->
      chamber.hidden = !chamber.hidden

    @.convertTimestamp = (timestamp)->
      moment(timestamp).format('DD.MM HH:mm:ss')

#=============================== GROW ================================
    @.getStrainInfo = (strain)->
      return strain.link || "https://www.leafly.com/search?q=#{strain.name}&typefilter=strain"


    @.buildLightBar = (light)->
      mmtMidnight = moment().startOf('day')
      projectedTime = moment().startOf('day').add(light.startTime.hours(), 'hours').add(light.startTime.minutes(), 'minutes')
      diffMinutes = projectedTime.diff(mmtMidnight, 'minutes')
      dayMinutes = 24 * 60
      bars = []

      offsetStart = Math.round(diffMinutes / dayMinutes * 100)
      onTime = Math.round(light.durationH * 60 / dayMinutes * 100)
      offTime = 100 - onTime - offsetStart

      if offTime < 0
        offsetStart = offsetStart + offTime
        onTime = 100 - offsetStart + offTime


      bars.push({value:-offTime, type: "on"}) if offTime < 0
      bars.push({value:offsetStart, type: "off"}) if offsetStart > 0
      bars.push({value:onTime, type: "on"}) if onTime > 0
      bars.push({value:offTime, type: "off"}) if offTime > 0
      return bars



#=============================== CRUD ================================
    @.updateSensorTimeUnit = (chart, newTimeUnit)->
      chartService.updateSensorTimeUnit(chart, newTimeUnit)
      return

    #------------------------------- Chamber------------------------------
    @.getChambers = ()->
      chamberService.getChambers().then (chambers)->
        self.chambers = chambers
        self.loaded = true
        for chamber in chambers
          chamber.stream = true #TODO get from sett
          chamber.light.startTime = moment(chamber.light.startTime) if chamber.light.startTime?
          chartService.initCharts chamber
          self.getEvents(chamber)
          chamber.light.bars = self.buildLightBar chamber.light if chamber.light?
        $timeout ()->
          outputService.broadcastOutputs()
          sensorService.broadcastSensors()
        , 1000
        return

    #------------------------------- Data ------------------------------
    @.getEvents = (chamber)->
      filterReadEvents = {}  # { outputIds: "aaa"}
      optionsReadEvents = { populate: {output: true} ,  limit: 5}
      dataService.readEvents(filterReadEvents, optionsReadEvents).then (events)->
        chamber.events = events

    @.clearEvents = (chamber)->
      filterClearEvents = {}
      optionsClearEvents = {}
      dataService.readEvents(filterClearEvents, optionsClearEvents).then ->
        chamber.events = []
        return


    #------------------------------- Chamber------------------------------
    @.operateOuptut = (id, state)->
      if state == 0
        operation = 'switchOn'
      else
        operation = 'switchOff'
      outputService.operateOutput id, operation

#=============================== WEBSOCKETS ================================
    $rootScope.$on "socket:outputData", (event, message) ->
      outputService.updateOutputValues self.chambers, message.payload
      return

    $rootScope.$on "socket:eventData", (event, message) ->
      console.info "received event data", message.payload
      for chamber in self.chambers
        if chamber.allOutputs? && chamber.allOutputs.some((output)->output._id == message.payload.output._id)
          chamber.events.unshift message.payload
          chamber.events.pop
      # self.updateEvents message.payload
      return

#================================= LISTENER ============================
    $scope.$watch ()->
      return $cookies.get('developer') == 'true'
    , (newValue)->
      $scope.developer = newValue
      return

#================================= INIT ==================================
    @.getChambers()
    settingService.getActiveDevices().then (activeDevices)->
      self.activeDevices = activeDevices
      return
#///////////////////////////////////////////////////////////////////
    return