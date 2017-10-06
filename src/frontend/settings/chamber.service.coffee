angular.module("myChamberService", ['ngLodash']).service("chamberService", ($http, $rootScope, $q, $log, lodash) ->
  self = @
  @.daysToHarvest = (strain, day)->
    return strain.daysToHarvest - day

  @.getChambers = ()->
    $http
      url: "/getChambers"
      method: "POST"
    .then (response) ->
      if response.data.chambers?
        return response.data.chambers.map (chamber)->
          if chamber.light?.startTime?
            chamber.light.startTime = new Date(chamber.light.startTime)
          return chamber
      else
        BootstrapDialog.alert({
          title: 'Could not get Chamber Information',
          message: response.data.err || '',
          type: BootstrapDialog.TYPE_DANGER
        })
        return []

  cleanEmpty = (obj)->
    filtered = lodash.pick(obj, (v) ->
      v != '' and v != null
    )
    return filtered

    # _.cloneDeep filtered, (v) ->
    #   if v != filtered and _.isPlainObject(v) then filter(v) else undefined


  validateChamber = (chamber, callback)->
    err = ''
    err += '- Your chamber needs a name.\n' if !chamber.name?

    chamber = cleanEmpty chamber
    #clean non valid strains
    if chamber.strains? && chamber.strains.length > 0
      for index in [chamber.strains.length-1..0]
        if !chamber.strains[index].name? || chamber.strains[index].name == ""
          chamber.strains.splice(index, 1)

    if chamber.rules? && chamber.rules.length > 0
      for index in [chamber.rules.length-1..0]
        if !chamber.rules[index].sensor?._id? || !chamber.rules[index].onValue? || !chamber.rules[index].offValue? || !chamber.rules[index].output?._id?
          chamber.rules.splice(index, 1)
        else
          err += 'Every rule needs a condition and a value.\n'

    return callback 'From Giraffee to, well lets call you - human -:\n' + err if err != ''
    return callback null, chamber

  @.upsertChamber = (chamber)->
    validateChamber chamber, (err, chamberToSave)->
      if err == null
        $http
          url: "/upsertChamber"
          method: "POST"
          data:
            chamber: chamber
        .then (response) ->
          if response.data.upsertedChamber?
            BootstrapDialog.alert({
              title: 'Updated Chamber Information',
              message: 'Your chamber settings have been updated successfully.'
              type: BootstrapDialog.TYPE_INFO
            })
            chamber._id = response.data.upsertedChamber._id
            return true
          else
            BootstrapDialog.alert({
              title: 'Could not get Chamber Information',
              message: response.data.err || '',
              type: BootstrapDialog.TYPE_DANGER
            })
            return false
        , (response) ->
          if response.data.err?
            BootstrapDialog.alert({
              title: 'Could not Update Chamber',
              message: response.data.err,
              type: BootstrapDialog.TYPE_DANGER
            })
          else if response.data.warning?
            BootstrapDialog.alert({
              title: 'Could not Update Chamber',
              message: response.data.warning,
              type: BootstrapDialog.TYPE_WARNING
            })
      else
        BootstrapDialog.alert({
          title: 'Could not save/update Chamber',
          message: err,
          type: BootstrapDialog.TYPE_DANGER
        })
        return false


  @.fillChamberWithDummy = (chamber)->
    chamber.name = "Baby Bloomer" if !chamber.name?
    chamber.cycle = "bloom" if !chamber.cycle?
    if chamber.strains.length < 2 && chamber.strains[0].name != ""
      chamber.strains[0].name = "Amensia"
      chamber.strains[0].daysToHarvest = "61"

    if !chamber.light.output._id?
      chamber.light.output._id = "588a427d617fff11d79b304e"
      chamber.light.output.name = "NDL 400W"
      chamber.light.startTime = "2016-11-28T07:30:00.749Z"
      chamber.light.durationH = 18

    if chamber.rules.length < 2 && !chamber.rules[0].sensor?._id?
      chamber.rules[0] = {
        sensor: {
          _id: "588a427d617fff11d79b304a",
          name:"Temperatur (Top)"
        }
        onValue:"30"
        offValue:"26"
        unit: "C"
        output: {
          _id:"588a427d617fff11d79b304f"
          name:'Vent'
        }
      }

    if !chamber.water.output._id?
      chamber.water.output._id = "588a427d617fff11d79b3050"
      chamber.water.output.name = "Pump"
      chamber.water.sensor._id = "588a427d617fff11d79b304b"
      chamber.water.sensor.name = "Water Sensor"
      chamber.water.durationMSOn = "30"

    if !chamber.displays?
      chamber.displays = ["588a427d617fff11d79b304d"]

#////////////////////////////////////////////////////////////////////
  return
)