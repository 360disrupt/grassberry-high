angular.module "general", ['myConfigService', 'ngResource', 'modal']
  .controller "GeneralCtrl", ($rootScope, $scope, $uibModal, configService, authUserService, Timezones) ->
    self = @
    @.buttonDisabled = false
    @.datepickers = {
      dateTime: false
    }
    @.system = {}
    @.toggleDatepicker = (which)->
      @.datepickers[which] = ! @.datepickers[which] if @.datepickers[which]?
#------------------------------------ wifi ---------------------------------------
    @.wifi = {}
    @.inputType = 'password'
    @.wifiOptions = []
    @.showManualWifi = false

    @.getWifiOptions = ()->
      configService.getWifiOptions().then (wifiOptions)->
        self.wifiOptions = wifiOptions

    @.toggleShowManualWifi = ()->
      @.showManualWifi = !@.showManualWifi

    @.configureWifi = ()->
      $scope.$broadcast('show-errors-check-validity')
      # console.log $scope.configDataForm
      if $scope.configWifiForm.$valid
        @.buttonDisabled = true
        @.openRebootModal()
        configService.configureWifi(@.wifi).then (success)->
          self.buttonDisabled = false if !success?

      else
        BootstrapDialog.alert({
          title: 'Please Fill In All the Forms',
          message: 'You need a wifi name and a wifi pass',
          type: BootstrapDialog.TYPE_DANGER
        })
      return

    @.openRebootModal = (parentSelector) ->
      parentElem = if parentSelector then angular.element($document[0].querySelector('.modal-demo ' + parentSelector)) else undefined
      @.modalInstance = $uibModal.open(
        animation: true
        ariaLabelledBy: 'modal-title'
        ariaDescribedBy: 'modal-body'
        templateUrl: 'settings/general/reboot.modal.html'
        size: 'lg'
        backdropClass: 'waiting'
        controller: 'ModalCtrl'
        controllerAs: '$ctrl'
        appendTo: parentElem
      )
      return

    @.reset = ()->
      configService.reset().then ->
        return

    @.getWifiOptions()
#------------------------------------ time zone , date & time ---------------------------------------
    @.timeZoneOptions = []
    @.regionTimezoneOptions = []
    @.system.region = 'US (Common)'
    @.system.dateTime = new Date()

    @.updateRegionTimezones = ()->
      self.regionTimezoneOptions = @.timeZoneOptions.filter((region)-> return region.group == self.system.region).map( (region)-> region.zones )[0] || []
      return

    @.configureDateTime = ()->
      $scope.$broadcast('show-errors-check-validity')

      if $scope.configDatetTimeForm.$valid
        @.buttonDisabled = true
        configService.configureDateTime(@.system).then (success)->
          self.buttonDisabled = false if !success?
      else
        BootstrapDialog.alert({
          title: 'Please Fill In All the Forms',
          message: 'Set a valid timeZone, date and time',
          type: BootstrapDialog.TYPE_DANGER
        })
      return

    @.initTimeOptions = ()->
      Timezones.query (timeZoneOptions) ->
        self.timeZoneOptions = timeZoneOptions
        self.regions = self.timeZoneOptions.map (region)->
          return region.group
        self.updateRegionTimezones()


    @.initTimeOptions()

#------------------------------------ units ---------------------------------------
    @.unitOptions = {
      'temperature': [
        { key: 'fahrenheit', label: 'Fahrenheit' }
        { key: 'celsius', label: 'Celsius' }
      ]
    }
    @.system.units = { temperature: 'celsius' }

    @.configureUnits = ()->
      $scope.$broadcast('show-errors-check-validity')

      if $scope.configUnits.$valid
        @.buttonDisabled = true

        configService.updateSystem(@.system).then (success)->
          self.buttonDisabled = false if !success?
      else
        BootstrapDialog.alert({
          title: 'Please Fill In All the Forms',
          message: 'Set valid units',
          type: BootstrapDialog.TYPE_DANGER
        })
      return

    configService.getSystem().then (system)->
      if system?
        system.dateTime = new Date()
        self.system = system
        self.updateRegionTimezones()

#---------------------------------- Softwareupdate -------------------------------------
    @.updateSoftware = ()->
      configService.updateSoftware().then ->
        return

#///////////////////////////////////////////////////////////////////
    return
  .factory 'Timezones', ($resource) ->
    return $resource('./frontend/settings/general/time-zones.json')