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

#---------------------------------- Softwareupdate -------------------------------------
  @.updateSoftware = (system)->
    $http
      url: "/updateSoftware"
      method: "GET"
    .then (response) ->
      if response.data.err?
        BootstrapDialog.alert({
          title: 'Failed to update Software',
          message: response.data.err,
          type: BootstrapDialog.TYPE_DANGER
        })
      else if response.data.warning?
        BootstrapDialog.alert({
          title: 'Failed to update Software',
          message: response.data.warning,
          type: BootstrapDialog.TYPE_WARNING
        })
      else if response.data.results?
        BootstrapDialog.alert({
          title: 'Info',
          message: response.data.results,
          type: BootstrapDialog.TYPE_INFO
        })
      return null



#---------------------------------- Reset -------------------------------------
  @.reset = ()->
    defer = $q.defer()
    BootstrapDialog.confirm({
      title: 'Do you want to reset the system?',
      message: 'Please choose:',
      type: BootstrapDialog.TYPE_DANGER,
      callback: (success)->
        if success
          $http
            url: "/reset"
            method: "GET"
          .then (response) ->
            if response.success?
              return success
            else
              BootstrapDialog.alert({
                title: 'Reset failed',
                message: response.data.err || '',
                type: BootstrapDialog.TYPE_DANGER
              })
              return null
        else
          $timeout ()->
            return defer.resolve(false)
    })
    return defer.promise

#////////////////////////////////////////////////////////////////////
  return
)