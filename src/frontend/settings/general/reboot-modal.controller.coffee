angular.module "modal", ['ui.bootstrap']
  .controller "ModalCtrl", ($uibModalInstance, $window, $cookies, $rootScope) ->
    $rootScope.$on "socket:system", (event, data) ->
      if data.payload == 'booted'
        BootstrapDialog.alert({
          title: 'Your Grassberry is Now Connected to Your Local Network!',
          message: "No need to connect to the hotspot anymore. You can access it directly via grassberry.local with all devices in your wifi network",
          type: BootstrapDialog.TYPE_SUCCESS
        })
      $uibModalInstance.close()
      return null
#//////////////////////////////////////////////////////////////////////////////////////////////
    return