angular.module 'tsd.reaper', ['mySerialService', 'mySystemService']
  .directive 'reaper', ($window, $rootScope, serialService, systemService) ->
    return {
      restrict: 'E',
      replace: true,
      templateUrl: '_directives/reaper/reaper.html'
      link: (scope, element, attrs) ->
        scope.timeLeftInHours = undefined
        systemService.getSystem().then (system)->
          timeLeftInHours = moment(system.validTill).diff(moment(), 'hours') if system?.validTill?
          scope.timeLeftInHours = timeLeftInHours if timeLeftInHours?
          scope.serial = system.serial
          return
#///////////////////////////////////////////////////////////////////////////////////////////
        return
    }