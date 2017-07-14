angular.module("myFeedbackService", []).service "feedbackService", ($http, $rootScope, $log) ->
  self = @

  @.getDummies = (feedbackData) ->
    feedbackData.type = "Bug"
    feedbackData.description = "What a feedback, but it is very short so I write something a bit more precise. Let me tell you that"
    feedbackData.mood = 'awesome'
    return feedbackData

#-------------------------------------- REST --------------------------
  @.sendFeedback = (feedback)->
    $http
      url: "/sendFeedback"
      method: "POST"
      data:
        feedback: feedback
    .then (response) ->
      console.log response
      if response.data.battle? && !response.data.err
        BootstrapDialog.alert({
          title: 'Alrigthy',
          message: 'We got notified!',
          type: BootstrapDialog.TYPE_SUCCESS
        })
        return response.data.battle
      else if response.data.err?
        BootstrapDialog.alert({
          title: 'Error',
          message: response.data.err,
          type: BootstrapDialog.TYPE_DANGER
        })
      return []
    , (response) ->
      if response.data.err?
        BootstrapDialog.alert({
          title: 'Error',
          message: response.data.err,
          type: BootstrapDialog.TYPE_DANGER
        })

#/////////////////////////////////////////////////////////////////////////////////////////
  return