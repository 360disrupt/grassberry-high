angular.module "adminMenu", ['myAdminMenuService', 'tsd.stretchFlexbox']
  .controller "AdminMenuCtrl", ($scope, $rootScope, authUserService, adminMenuService) ->
    self = @
    @.buttonDisabled = false

    @.checkPermission = (permissions)->
      authUserService.checkPermission(permissions)


    adminMenuService.getDbSize('sensordata').then (response)->
      self.dataSizeSensorData = response.data.dbSize if response.data?.dbSize?
      return


#////////////////////////////////////////////////////////////////////////////////
    return