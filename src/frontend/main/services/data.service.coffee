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

  @.clearEvents = (filterReadEvents, optionsReadEvents)->
    $http
      url: "/clearEvents"
      method: "POST"
      data:
        filterReadEvents: filterReadEvents
        optionsReadEvents: optionsReadEvents
    .then (response) ->
      if response.data.err?
        console.error "Could not read events", response
      return null

#////////////////////////////////////////////////////////////////////
  return
)