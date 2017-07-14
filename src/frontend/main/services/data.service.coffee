angular.module("myDataService", ['websockets']).service("dataService", ($http, $rootScope, $state, $q, $log, lodash, chatSocket) ->
  self = @

#=============================== CRUD ================================
  @.readEvents = (filterReadEvents, optionsReadEvents)->
    $http
      url: "/readEvents"
      method: "POST"
      data:
        filterReadEvents: filterReadEvents
        optionsReadEvents: optionsReadEvents
    .then (response) ->
      if response.data.events?
        return response.data.events
      else
        console.error "Could not read events", response
        return []

#////////////////////////////////////////////////////////////////////
  return
)