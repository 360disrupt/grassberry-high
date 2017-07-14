angular.module("myRuleService", ['ngLodash']).service("ruleService", ($http, $rootScope, $q, $log, lodash) ->
  self = @
  @.removeRule = (chamberId, ruleId)->
    $http
      url: "/removeRule/#{chamberId}/#{ruleId}"
      method: "DELETE"
    .then (response) ->
      if response.data.success?
        return response.data.success
      else
        BootstrapDialog.alert({
          title: 'Could not remove this rule',
          message: response.data.err || '',
          type: BootstrapDialog.TYPE_DANGER
        })
        return null
    , (response) ->
      if response.data.err?
        BootstrapDialog.alert({
          title: 'Could not remove this rule',
          message: response.data.err,
          type: BootstrapDialog.TYPE_DANGER
        })
      else if response.data.warning?
        BootstrapDialog.alert({
          title: 'Could not remove this rule',
          message: response.data.warning,
          type: BootstrapDialog.TYPE_WARNING
        })

#////////////////////////////////////////////////////////////////////
  return
)