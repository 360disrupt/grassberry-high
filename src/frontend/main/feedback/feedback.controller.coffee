angular.module "feedbackMain", ['ui.bootstrap', "ui.bootstrap.showErrors", 'ngFlash', 'cfp.hotkeys', 'feedback', 'tsd.radioBtnGroup', 'myAuthUserService', 'tsd.markRequired', 'myFeedbackService']
  .controller "FeedbackCtrl", ($scope, $rootScope, Flash, feedbackService, authUserService, hotkeys) ->
    self = @
    @.buttonDisabled = false
    @.feedback = {date: new Date()}
    @.typeOptions = ['Bug', 'Feature', 'Blog', 'Other']
    @.radioOptions = {
      mood: {angry:'👿', worried:'😱', notPleased:'😧', neutral:'😐', smiling:'😬', twinkle:'😉', awesome:'🦄'}
    }
    $scope.urlRegex = /^(https?:\/\/)?(.*)\.(\w{1,})(:\d*)?(\/.*)?/i


#-------------------------------------- HELPER --------------------------

    hotkeys.add({
      combo: ['ctrl+d', 'alt+d'],
      description: 'Fill with dummies',
      callback: () ->
        feedbackService.getDummies(self.feedback)
    })


#-------------------------------------- REST -----------------------------

    @.sendFeedback = ()->
      $scope.$broadcast('show-errors-check-validity')
      if $scope.feedbackForm.$valid
        @.buttonDisabled = true
        feedbackService.sendFeedback(@.feedback).then (response) ->
          self.buttonDisabled = false
          BootstrapDialog.alert({
            title: 'Awesome',
            message: 'Thank you very much, we will evaluate your feedback soon!',
            type: BootstrapDialog.TYPE_SUCCESS
          })
        , (response)->
          BootstrapDialog.alert({
            title: 'Something went wrong',
            message: response.data.err,
            type: BootstrapDialog.TYPE_DANGER
          })
      else
        console.error $scope.feedbackForm
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


#/////////////////////////////////////////////////////////////////////////////////////////////////
    return