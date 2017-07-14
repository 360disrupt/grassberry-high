angular.module("mySystemService", []).service("systemService", ($http, $rootScope, $state, $q, $log, chatSocket) ->
  self = @

#---------------------------------- Wifi -------------------------------------
  @.getSystem = ()->
    $http
      url: "/getSystem"
      method: "GET"
    .then (response) ->
      if response.data?.system?
        return response.data.system
      else
        return null
    , (response) ->
      if response.data?.err?
        BootstrapDialog.alert({
          title: 'Did not Get System',
          message: response.data.err,
          type: BootstrapDialog.TYPE_DANGER
        })
      else if response.data?.warning?
        BootstrapDialog.alert({
          title: 'Did not Get System',
          message: response.data.warning,
          type: BootstrapDialog.TYPE_WARNING
        })
      return null

  @.checkLicense = ()->
    $http
      url: "/getLicenseInformation"
      method: "GET"
    .then (response) ->
      if response.data?.success?
        self.getSystem().then (response) ->
          BootstrapDialog.alert({
            title: 'License has been checked',
            message: 'If something is wrong please contact us.',
            type: BootstrapDialog.TYPE_INFO
          })
          return response
    , (response) ->
      if response.data?.err?
        BootstrapDialog.alert({
          title: 'Did not Get License',
          message: response.data.err,
          type: BootstrapDialog.TYPE_DANGER
        })
      else if response.data?.License?
        BootstrapDialog.alert({
          title: 'Did not Get System',
          message: response.data.warning,
          type: BootstrapDialog.TYPE_WARNING
        })
      return null

  @.reboot = ()->
    BootstrapDialog.confirm({
      title: 'Reboot',
      message: 'Are you sure? This will shutdown and reboot the system.',
      type: BootstrapDialog.TYPE_INFO
      callback: (success)->
        if success
          $http
            url: "/reboot"
            method: "GET"
          .then (response) ->
            if response.data?.err?
              BootstrapDialog.alert({
                title: 'Could not reboot',
                message: response.data.err,
                type: BootstrapDialog.TYPE_DANGER
              })
            return null
    })

#////////////////////////////////////////////////////////////////////
  return
)