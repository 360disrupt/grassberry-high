angular.module "error", []
  .controller "ErrorCtrl", ($scope, errorObj) ->
    console.log "ERROR", errorObj
    @.error = errorObj
    return