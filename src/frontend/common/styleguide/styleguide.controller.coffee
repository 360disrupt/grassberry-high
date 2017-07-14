angular.module "grassberryHigh"
  .controller "StyleGuideCtrl", ($scope, authUserService) ->
    @.checkPermission = (permission) ->
      authUserService.checkPermission(permission)

    return