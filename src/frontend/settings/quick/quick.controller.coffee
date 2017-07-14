angular.module "quick", ['mySettingService', 'myChamberService', 'mySensorService', 'myOutputService', 'tsd.tutorial', 'cfp.hotkeys', 'ngLodash', 'ngMaterial']
  .controller "QuickCtrl", ($rootScope, $scope, $timeout, settingService, chamberService, outputService, sensorService, hotkeys, authUserService, lodash) ->
    self = @
    @.chambers = []
    imagePath = 'assets/images/'
    $scope.imagePaths = {
      basic: "#{imagePath}card-basic.jpg"
      advanced: "#{imagePath}card-advanced.jpg"
    }
    @.addChamber = ()->
      BootstrapDialog.alert({
        title: 'Not avilable in Demo Mode',
        message: "Only available in the full version",
        type: BootstrapDialog.TYPE_DANGER
      })

#///////////////////////////////////////////////////////////////////
    return
  .config ($mdThemingProvider) ->
    $mdThemingProvider.theme('dark-grey').backgroundPalette('grey').dark()
    $mdThemingProvider.theme('dark-orange').backgroundPalette('orange').dark()
    $mdThemingProvider.theme('dark-purple').backgroundPalette('deep-purple').dark()
    $mdThemingProvider.theme('dark-blue').backgroundPalette('blue').dark()
