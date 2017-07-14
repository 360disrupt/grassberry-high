angular.module "subscription", ["subscriptionMain"]
  .constant('statesSubscription', [
    {
    name: "root.subscription",
    options:
      url: "/subscription?err&success"
      views:
        'container@':
          templateUrl: "main/subscription/subscription.html"
          controller: "SubscriptionCtrl"
          controllerAs: "subscriptionController"
    }
  ])
  .config(['$stateProvider', ($stateProvider) ->])