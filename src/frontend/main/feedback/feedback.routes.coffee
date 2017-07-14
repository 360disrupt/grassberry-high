angular.module "feedback", ["feedbackMain"]
  .constant('statesFeedback', [
    {
    name: "root.feedback",
    options:
      url: "/feedback"
      views:
        'container@':
          templateUrl: "main/feedback/feedback.html"
          controller: "FeedbackCtrl"
          controllerAs: "feedbackController"
    }
  ])
  .config(['$stateProvider', ($stateProvider) ->])