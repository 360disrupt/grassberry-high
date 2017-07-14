angular.module("mySettingService", ['ngLodash']).service("settingService", ($http, $rootScope, $q, $log, lodash) ->
  self = @
  @.getActiveDevices = ()->
    $http
      url: "/getActiveDevices"
      method: "GET"
    .then (response) ->
      if response.data.activeDevices?
        return response.data.activeDevices
      else
        BootstrapDialog.alert({
          title: 'Could not get Active Devices',
          message: response.data.err || '',
          type: BootstrapDialog.TYPE_DANGER
        })
        return []

#////////////////////////////////////////////////////////////////////
  return
)