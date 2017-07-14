angular.module("myConfigService", []).service("configService", ($http, $rootScope, $state, $q, $log, chatSocket) ->
  self = @

#---------------------------------- Wifi -------------------------------------
  @.getWifiOptions = ()->
    $http
      url: "/getWifiOptions"
      method: "GET"
    .then (response) ->
      if response.data.wifiOptions?
        return response.data.wifiOptions
      else
        BootstrapDialog.alert({
          title: 'Could not get Wifi Information',
          message: response.data.err || '',
          type: BootstrapDialog.TYPE_DANGER
        })
        return []

  @.configureWifi = (wifi)->
    $http
      url: "/configureWifi"
      method: "POST"
      data:
        wifi: wifi
    .then (response) ->
      if response.success?
        return success
      else
        BootstrapDialog.alert({
          title: 'Could not Update Wifi Settings',
          message: response.data.err || '',
          type: BootstrapDialog.TYPE_DANGER
        })
        return null
    , (response) ->
      if response.data.err?
        BootstrapDialog.alert({
          title: 'Could not Update Wifi Settings',
          message: response.data.err,
          type: BootstrapDialog.TYPE_DANGER
        })
      else if response.data.warning?
        BootstrapDialog.alert({
          title: 'Could not Update Wifi Settings',
          message: response.data.warning,
          type: BootstrapDialog.TYPE_WARNING
        })
      return null

#---------------------------------- Date,Time & Timezone -------------------------------------
  @.configureDateTime = (dateTimeConfig)->
    $http
      url: "/configureDateTime"
      method: "POST"
      data:
        dateTimeConfig: dateTimeConfig
    .then (response) ->
      if response.success?
        BootstrapDialog.alert({
          title: 'Updated time zone',
          message: 'Your date/time information is now up-to-date',
          type: BootstrapDialog.TYPE_SUCCESS
        })
        return success
      else
        BootstrapDialog.alert({
          title: 'Could not Update Date & Time Setting',
          message: response.data.err || '',
          type: BootstrapDialog.TYPE_DANGER
        })
        return null
    , (response) ->
      if response.data.err?
        BootstrapDialog.alert({
          title: 'Could not Update Date & Time Setting',
          message: response.data.err,
          type: BootstrapDialog.TYPE_DANGER
        })
      else if response.data.warning?
        BootstrapDialog.alert({
          title: 'Could not Update Date & Time Setting',
          message: response.data.warning,
          type: BootstrapDialog.TYPE_WARNING
        })
      return null

#---------------------------------- Units -------------------------------------
  @.getSystem = (system)->
    $http
      url: "/getSystem"
      method: "GET"
    .then (response) ->
      if response.data.system?
        return response.data.system
      else
        return null
    , (response) ->
      if response.data.err?
        BootstrapDialog.alert({
          title: 'Could not Get System',
          message: response.data.err,
          type: BootstrapDialog.TYPE_DANGER
        })
      else if response.data.warning?
        BootstrapDialog.alert({
          title: 'Could not Get System',
          message: response.data.warning,
          type: BootstrapDialog.TYPE_WARNING
        })
      return null

  @.updateSystem = (system)->
    $http
      url: "/updateSystem"
      method: "POST"
      data:
        system: system
    .then (response) ->
      if response.success?
        return success
      else
        return null
    , (response) ->
      if response.data.err?
        BootstrapDialog.alert({
          title: 'Could not Update System Settings',
          message: response.data.err,
          type: BootstrapDialog.TYPE_DANGER
        })
      else if response.data.warning?
        BootstrapDialog.alert({
          title: 'Could not Update System Settings',
          message: response.data.warning,
          type: BootstrapDialog.TYPE_WARNING
        })
      return null


#////////////////////////////////////////////////////////////////////
  return
)