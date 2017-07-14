angular.module "adminMenu", ['myAdminMenuService', 'tsd.stretchFlexbox']
  .controller "AdminMenuCtrl", ($scope, $rootScope, authUserService, adminMenuService) ->
    self = @
    @.user = {}
    @.initialData = {}
    @.buttonDisabled = false

    @.getUser  = ()->
      authUserService.getUserData('all').then (user)->
        self.user = user

    @.checkPermission = (permissions)->
      authUserService.checkPermission(permissions)

    $rootScope.$on("loggedIn", ()->
      self.getUser()
    )
    @.getUser()
    $rootScope.$on('loggedOut', (event) ->
      # console.log "$on loggedOut"
      self.user = {}
    )

    adminMenuService.getMsgOptionsCoinAcceptor().then (commands)->
      self.msgOptions = commands
      return

#////////////////////////////////////////////////////////////////////////////////
    return