angular.module("myOutputService", ['websockets', 'ngLodash']).service("outputService", ($http, $rootScope, $q, $log, chatSocket, lodash) ->
  self = @
#=============================== CRUD ================================
  @.broadcastOutputs = ()->
    $http
      url: "/broadcastOutputs"
      method: "GET"
    .then (response) ->
      if response.data.success? && response.data.success == true
        return true
      else
        console.error "NOT WORKING", response
        return false

  @.getOutputs = ()->
    $http
      url: "/getOutputs"
      method: "POST"
    .then (response) ->
      if response.data.outputs?
        return response.data.outputs
      else
        BootstrapDialog.alert({
          title: 'Could not get Output Information',
          message: response.data.err || '',
          type: BootstrapDialog.TYPE_DANGER
        })
        return []

  @.upsertOutput = (output)->
    $http
      url: "/upsertOutput"
      method: "POST"
      data:
        output: output
    .then (response) ->
      if response.data.success?
        return true
      else
        BootstrapDialog.alert({
          title: 'Could not save/update output information',
          message: response.data.err || '',
          type: BootstrapDialog.TYPE_DANGER
        })
        return false
    , (response) ->
      if response.data.err?
        BootstrapDialog.alert({
          title: 'Could not save/update output information',
          message: response.data.err,
          type: BootstrapDialog.TYPE_DANGER
        })
      else if response.data.warning?
        BootstrapDialog.alert({
          title: 'Could not save/update output information',
          message: response.data.warning,
          type: BootstrapDialog.TYPE_WARNING
        })

  @.operateOutput = (id, operation)->
    $http
      url: "/operateOutput"
      method: "PUT"
      data:
        id: id
        operation: operation
    .then (response) ->
      if response.data.success?
        return response.data.success
      else
        BootstrapDialog.alert({
          title: 'Could not toggle Output',
          message: response.data.err || '',
          type: BootstrapDialog.TYPE_DANGER
        })
        return []
    , (response) ->
      BootstrapDialog.alert({
        title: 'Could not toggle Output',
        message: response.data.err,
        type: BootstrapDialog.TYPE_DANGER
      })
      return []
#=============================== WEBSOCKETS ================================
  @.updateOutputValues = (chambers, outputData)->
    return null if chambers.length == 0
    for chamber in chambers
      if chamber.allOutputs?
        index = lodash.findIndex chamber.allOutputs, {_id: outputData._id}
        if index != -1
          chamber.allOutputs[index].state = outputData.state
    return
#////////////////////////////////////////////////////////////////////
  return
)