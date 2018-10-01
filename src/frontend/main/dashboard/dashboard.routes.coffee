angular.module "dashboard", ['chart.js', 'tsd.checkbox', 'myChamberService', 'myChartService', 'myOutputService', 'mySensorService','mySimulationService', 'myDataService', 'mySettingService', 'dndLists', 'tsd.output', 'tsd.sensor', 'tsd.csvExport']
  .constant('statesDashboard', [
    {
    name: "root.dashboard",
    options:
      url: "/dashboard"
      views:
        'container@':
          templateUrl: "main/dashboard/dashboard.html"
          controller: "DashboardCtrl"
          controllerAs: "dashboardController"
      resolve:
        UserQuery: ['$stateParams', ($stateParams)->
          return $stateParams.userQuery || ""
        ]
    }
  ])
  .config(['$stateProvider', 'ChartJsProvider', ($stateProvider, ChartJsProvider) ->
    ChartJsProvider.setOptions({ chartColors : [ '#803690', '#00ADF9', '#a2b6c4', '#46BFBD', '#FDB45C', '#949FB1', '#4D5360'] })
  ])