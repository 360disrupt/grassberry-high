angular.module "subscriptionMain", ['ui.bootstrap', "ui.bootstrap.showErrors", 'ngFlash', 'cfp.hotkeys', 'subscription', 'tsd.radioBtnGroup', 'myAuthUserService', 'tsd.markRequired', 'mySubscriptionService']
  .controller "SubscriptionCtrl", ($scope, $rootScope, $stateParams, $timeout, Flash, subscriptionService, authUserService, hotkeys) ->
    self = @
    @.buttonDisabled = false
    @.subscription = {date: new Date()}
    $scope.emailRegex = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
    $scope.loaded = false

#-------------------------------------- HELPER --------------------------

    hotkeys.add({
      combo: ['ctrl+d', 'alt+d'],
      description: 'Fill with dummies',
      callback: () ->
        subscriptionService.getDummies(self.subscription)
    })

#-------------------------------------- REST -----------------------------

    @.sendSubscription = ()->
      $scope.$broadcast('show-errors-check-validity')
      if $scope.subscriptionForm.$valid
        @.buttonDisabled = true
        subscriptionService.sendSubscription(@.subscription).then (response) ->
          self.buttonDisabled = false
          BootstrapDialog.alert({
            title: 'Awesome',
            message: 'Thank you very much, you will get an email with further instructions soon!',
            type: BootstrapDialog.TYPE_SUCCESS
          })
        , (response)->
          BootstrapDialog.alert({
            title: 'Something went wrong',
            message: response.data.err,
            type: BootstrapDialog.TYPE_DANGER
          })
      else
        console.error $scope.subscriptionForm
        BootstrapDialog.alert({
          title: 'Missing fields',
          message: 'Please fill in the fields!',
          type: BootstrapDialog.TYPE_DANGER
        })
      return
#-------------------------------------- USER ------------------------------

    @.getUser  = ()->
      authUserService.getUserData('all').then (user)->
        self.user = user
        self.bugData.user = user.facebook.id if user.facebook.id?

    @.checkPermission = (userType) ->
      authUserService.checkPermission(userType)

#-------------------------------------- INIT --------------------------
    if $stateParams.success == 'true'
      BootstrapDialog.alert({
        title: 'Marvelous',
        message: 'Thank you very much, your account will be extended soon!',
        type: BootstrapDialog.TYPE_SUCCESS
      })
    else if $stateParams.err?
      BootstrapDialog.alert({
        title: 'Something went wrong',
        message: $stateParams.err,
        type: BootstrapDialog.TYPE_DANGER
      })

    $timeout ()->
      $scope.loaded = true
    , 1000

#/////////////////////////////////////////////////////////////////////////////////////////////////
    return