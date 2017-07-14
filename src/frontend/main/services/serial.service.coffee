angular.module("mySerialService", []).service("serialService", ($http, $rootScope, $state, $q, $log, chatSocket) ->
  self = @

#---------------------------------- Wifi -------------------------------------
  @.getSerial = ()->
    $http
      url: "/getSerial"
      method: "GET"
    .then (response) ->
      if response.data.serial?
        return response.data.serial
      else
        return null
    , (response) ->
      if response.data.err?
        BootstrapDialog.alert({
          title: 'Did not Get Serial',
          message: response.data.err,
          type: BootstrapDialog.TYPE_DANGER
        })
      else if response.data.warning?
        BootstrapDialog.alert({
          title: 'Did not Get Serial',
          message: response.data.warning,
          type: BootstrapDialog.TYPE_WARNING
        })
      return null

#////////////////////////////////////////////////////////////////////
  return
)