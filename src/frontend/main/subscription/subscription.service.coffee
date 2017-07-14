angular.module("mySubscriptionService", []).service "subscriptionService", ($http, $rootScope, $log) ->
  self = @

  @.getDummies = (subscriptionData) ->
    console.log "Dummies"
    angular.element('form input[type=email]').value= "a.geissinger@gmx.de"
    angular.element('form input[type=tel]').value= "4242424242424242"
    return subscriptionData

#-------------------------------------- REST --------------------------
  @.sendSubscription = (subscription)->
    $http
      url: "/sendSubscription"
      method: "POST"
      data:
        subscription: subscription
    .then (response) ->
      if response.data.status? && !response.data.err
        return true
      else if response.data.err?
        BootstrapDialog.alert({
          title: 'Error',
          message: response.data.err,
          type: BootstrapDialog.TYPE_DANGER
        })
      return false

#/////////////////////////////////////////////////////////////////////////////////////////
  return