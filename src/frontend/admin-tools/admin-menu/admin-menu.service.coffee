angular.module "myAdminMenuService", ['myAuthUserService']
  .service("adminMenuService", ($http, $rootScope, $log, $q, $filter, authUserService) ->
    self = @

    @.getDbSize = (collection)->
      $http
        url: "/getDbSize/#{collection}"
        method: "GET"
      .then (dbSize) ->
        return dbSize

#/////////////////////////////////////////////////////////////////////////////////
    return
  )