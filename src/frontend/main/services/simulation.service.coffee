angular.module("mySimulationService", ['myChartService']).service("simulationService", ($http, $rootScope, $state, $cookies, $q, $log, chartService, chatSocket) ->
  self = @

#---------------------------------- Warnings -------------------------------------
  @.getFakeWarnings = ()->
    return ["Temperature reached 40C on #{moment().format('DD-MM-YYYY HH:mm')} , please lower the temperature"]

#////////////////////////////////////////////////////////////////////
  return
)