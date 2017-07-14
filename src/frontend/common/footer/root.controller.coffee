angular.module "root", ['ngFlash']
  .controller "RootCtrl", ($rootScope, $scope, $http, $state, $timeout, Flash, authUserService) ->
    self = @

    @.getUser = ()->
      authUserService.getUserData('all').then (user)->
        self.user = user
        return self.user

    $rootScope.$on("loggedIn", ()->
      $timeout self.getUser()
      ,100
    )

    $scope.$on '$viewContentLoaded', () ->
      window.callPhantom() if typeof window.callPhantom == 'function'
      return

    $rootScope.$on("socket:userMessage", (event, data)->
      console.log "socket:userMessage", data
      type = data.type || 'danger'
      self.flashId = Flash.create(type, data.message, 100000, {class:"alert-fixed #{data.type}"}, true)
    )
#////////////////////////////////////////
    return