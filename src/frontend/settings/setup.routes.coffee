angular.module "setup", ['general' , 'advanced', 'quick', 'ngResource']
  .constant('statesSetup', [
    {
    name: "root.advanced",
    options:
      url: "/advanced"
      views:
        'container@':
          templateUrl: "settings/advanced/advanced.html"
          controller: "AdvancedCtrl"
          controllerAs: "advancedController"
    },
    {
    name: "root.quick",
    options:
      url: "/quick"
      views:
        'container@':
          templateUrl: "settings/quick/quick.html"
          controller: "QuickCtrl"
          controllerAs: "quickController"
    }
    {
    name: "root.general",
    options:
      url: "/general"
      views:
        'container@':
          templateUrl: "settings/general/general.html"
          controller: "GeneralCtrl"
          controllerAs: "generalController"
    }
  ])