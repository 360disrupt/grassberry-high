HISTORY_LENGTH = 30
ONE_SECOND_IN_MILLISECONDS = 1000
ONE_MINUTE_IN_MILLISECONDS = 60 * ONE_SECOND_IN_MILLISECONDS
ONE_HOUR_IN_MILLISECONDS = 60 * ONE_MINUTE_IN_MILLISECONDS
STATISTIC_INTERVALL = HISTORY_LENGTH * 60 * 1000 #max time unit is hours

inspect = require('util').inspect
chalk = require('chalk')
debugSensor = require('debug')('sensor')
debugSensorSwitch = require('debug')('sensor:switch')

async = require('async')
_ = require('lodash')
moment = require('moment')
mongoose = require('mongoose')

ObjectId = require('mongoose').Types.ObjectId
SensorDataModel = require('../data-logger/sensor-data.model.js').getModel()

socketIoMessenger = require('../_socket-io/socket-io-messenger.js')
logger = require('../_logger/logger.js').getLogger()
ruleService = require('../rule/rule.service.js')
outputService = require('../output/output.service.js')

DataLogger = require('../data-logger/data-logger.class.js')
dataLogger = new DataLogger()

class Sensor
  constructor: (options, callback) ->
    # console.info "options", options
    that = @
    @._id = options._id || throw new Error("Id is required")
    @.model = options.model || throw new Error("Model is required")
    throw new Error("At least one detector is required") if !options.detectors? || options.detectors.length == 0
    @.detectors = options.detectors

    if options.technology == 'i2c'
      @.i2c1 = require('../i2c/i2c.js').getI2cBus()
      @.address = options.address || throw new Error("Address is required")

    @.sensorReadIntervall = 1000 #read sensor each s
    @.sensorPushIntervall = 5000 #push sensor each 5s
    @.sensorWriteIntervall = 5000 #write sensor each 5s
    @.timeUnit = 'seconds'
    @.modes = options.modes || {adjustValues: 5}

    async.eachSeries @.detectors,
      (detector, next)->
        detector.history = []
        detector.shortBuffer = []
        detector.currentValue = null
        detector.rules = []
        that.initRules(detector)
        that.readSensorHistory detector, (err, history)->
          detector.history = history || []
          return next err
      (err)->
        console.error err if err?
        that.buildStatistic()
        # logger.info "Activated Sensor  #{inspect options}"
        return callback err




  getSensor: ()->
    return @

#--------------------------- Database Operations -----------------------------
  sensorSaveValueToDb: dataLogger.createSensorData

#--------------------------- Statistic & Clean up --------------------------------------
  buildStatistic: ()-> # builds a statistic and removes values older than 48h
    self = @
    setTimeout ()->
      for detector in self.detectors
        #todo first build a statistic
        SensorDataModel.remove({sensor: @._id, detectorType: detector.type, timestamp: {$gt: moment().subtract(48, 'hours')}}).exec (err)->
          logger.error if err?
    , STATISTIC_INTERVALL

#--------------------------- Sensor Process, Write & Broadcast --------------------------------------
  checkWrite: (detector)->
    if !detector.lastWrite? || moment().diff(detector.lastWrite) >= @.sensorWriteIntervall
      detector.lastWrite = moment()
      return true
    else
      return false

  checkPush: (detector)->
    # console.log "#{detector.type} diff #{moment().diff(detector.lastPush)} #{@.timeUnit} #{@.sensorPushIntervall}"
    if !detector.lastPush? || moment().diff(detector.lastPush) >= @.sensorPushIntervall
      detector.lastPush = moment()
      return true
    else
      return false

  changeSensorTimeUnit: (newTimeUnit, callback)->
    self = @
    switch newTimeUnit
      when 'seconds'
        self.sensorPushIntervall = 5 * ONE_SECOND_IN_MILLISECONDS #ms
      when 'minutes'
        self.sensorPushIntervall = ONE_MINUTE_IN_MILLISECONDS
      when 'hours'
        self.sensorPushIntervall = ONE_HOUR_IN_MILLISECONDS
      else
        return callback new Error "Time unit is not valid"

    @.timeUnit = newTimeUnit
    async.each @.detectors,
      (detector, next)->
        self.readSensorHistory detector, (err, history)->
          history = history || []
          return next err if err?
          detector.history = history || []
          return next()
      (err)->
        return callback err if err?
        return callback null, self

  broadcastSensorHistory: ()->
    socketIoMessenger.sendMessage('sensorData', {'payload':@})

  adjustValue: (detector, value)->
    nrValues = @.modes.adjustValues
    if detector.shortBuffer.length >= nrValues
      value = (value + detector.shortBuffer.slice(detector.shortBuffer.length-nrValues).reduce( (prev, curr)->
        return prev + curr
      ))/(nrValues + 1)
      detector.shortBuffer.push value
      if detector.shortBuffer.length > nrValues
        detector.shortBuffer.shift()

    else
      detector.shortBuffer.push value

    return value


  processSensorValue: (detector, newValue, callback)->
    self = @
    return callback() if isNaN(newValue)
    if @.modes.adjustValues?
      newValue = @.adjustValue detector, newValue

    detector.currentValue = {x: moment().toDate(), y:newValue} #.startOf('minute')
    @.applyRules(detector)

    async.parallel
      sensorPush: (next)->
        return next() if !self.checkPush(detector)
        detector.history.push detector.currentValue
        if detector.history.length > HISTORY_LENGTH
          detector.history.shift()
        detector.history = _.orderBy detector.history, 'x'
        self.broadcastSensorHistory()
        next()
      sensorWrite: (next)->
        return next() if !self.checkWrite(detector)
        self.sensorSaveValueToDb self._id, detector, next
      callback

#--------------------------- Sensor Read --------------------------------------
  filterSensorHistory: (data, callback)->
    self = @
    data = _.sortBy(data, 'timestamp').reverse()
    lastEntry = moment(data[0].timestamp).add(5, self.timeUnit) #add 5 units to the last entry (for processing delay), works seconds & minutes
    data = data.filter (dataItem, index)->
      return false if lastEntry.diff(moment(dataItem.timestamp), self.timeUnit) <= 1 #if less than 1 time unit diff. reject
      lastEntry = moment(dataItem.timestamp)
      return true
    data = data.splice(0,HISTORY_LENGTH)
    data = data.map (dataItem)->
      return { x: moment(dataItem.timestamp).toDate(), y: dataItem.value }
    data.reverse()
    return callback null, data

  readSensorHistory: (detector, callback)->
    self = @

    switch @.timeUnit
      when 'seconds'
        since = moment().subtract((HISTORY_LENGTH + 1) * @.sensorReadIntervall, 'seconds').toISOString()
      else
        since = moment().subtract((HISTORY_LENGTH + 1), @.timeUnit).toISOString()

    filterReadSensor = {sensor: new ObjectId(@._id), detectorType: detector.type, timestamp: {$gt: since}}
    SensorDataModel.find(filterReadSensor).exec (err, data)->
      return callback err if err?
      return callback null, [] if !data? || data.length == 0
      return self.filterSensorHistory data, callback


#--------------------------- Init/apply Rules --------------------------------------
  initRules: (detector)->
    self = @
    options = {filter: {
      sensor: @._id
      forDetector: detector.type
    }}
    ruleService.getRules options, (err, rulesFound)->
      logger.error err if err?
      detector.rules = rulesFound
      return

  applyRules: (detector)->
    self = @
    for rule in detector.rules
      debugSensorSwitch "Currrent Value: #{detector.currentValue.y}", "rule", inspect rule
      info = "Because #{detector.currentValue.y.toFixed(2)} #{rule.forDetector} was "
      if rule.device == 'pump' && rule.onValue > detector.currentValue.y #pumps are triggered when water level is below 2 (moist)
        statusOn = true
        info = "Because soil was dry."
      else if rule.onValue > rule.offValue #treshld if exceeds
        if rule.onValue < detector.currentValue.y
          statusOn = true
          info += "higher then #{rule.onValue}"
        else if rule.offValue > detector.currentValue.y
          statusOff = true
          info += "lower then #{rule.offValue}"
      else
        if rule.onValue > detector.currentValue.y
          statusOn = true
          info += "lower then #{rule.onValue}"
        else if rule.offValue < detector.currentValue.y
          statusOff = true
          info += "higher then #{rule.offValue}"

      if statusOn
        operation = 'switchOn'
        counterOperation = 'switchOff'
        state = 1
      else if statusOff
        operation = 'switchOff'
        counterOperation = 'switchOn'
        state = 0
      else
        return null

      #check if it is already in the required state
      outputService.getOutputById rule.output, (err, output)->
        if !output?
          console.error "Could not find output #{rule.output}"
          return
        debugSensorSwitch output.name, "on #{rule.onValue} off #{rule.offValue} State change: #{output.state != state}"
        if output? && output.state != state && operation?
          return null if output.blockedBy? && output.blockedBy != detector._id
          return null if output.blockedTill? && moment(output.blockedTill).diff(moment(), 'seconds')
          return null if rule.device == 'pump' && (!rule.durationMSOn? || !rule.durationMBlocked?)
          debugSensorSwitch "SWITCHED #{operation}"
          #if different operate the output
          outputService.operateOutput rule.output, operation, info, detector._id, (err)->
            logger.error err if err?

            #if a duration exists, counter rule is applied
            if rule.durationMSOn?
              outputService.blockOutput rule.output, rule.durationMBlocked, (err)->
                if err? #in case of error revert to prevent water damage
                  outputService.operateOutput rule.output, counterOperation, 'counter operation' ,detector._id, (err)->
                    logger.error err if err?
                else
                  setTimeout ()->
                    outputService.operateOutput rule.output, counterOperation, 'counter operation' ,detector._id, (err)->
                      logger.error err if err?
                  , rule.durationMSOn
    return

#///////////////////////////////////////////////////////////////////////////////////////////////////
module.exports = Sensor
