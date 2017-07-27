HISTORY_LENGTH = 30

inspect = require('util').inspect
chalk = require('chalk')

moment = require('moment')

Sensor = require('../sensor.class.js')

socketIoMessenger = require('../../_socket-io/socket-io-messenger.js')
logger = require('../../_logger/logger.js').getLogger()
ruleService = require('../../rule/rule.service.js')
outputService = require('../../output/output.service.js')

class SensorMock extends Sensor
  constructor: (options, callback) ->
    that = @
    super options, (err)->
      return callback err

#--------------------------- Simulation Mode ----------------------------------
  readSensorHistory: (detector, callback)->
    return callback()

  randomNumber: (min,max)->
    Math.floor((Math.random() * max) + min)

  randSensorValue: (detector)->
    return detector.history[detector.history.length-1] if @.randomNumber(0 ,100) < 95 && detector.history.length > 0
    lastValue = if detector.history.length > 0 then detector.history[detector.history.length-1].y else (detector.min + detector.max)/2
    newValue = Math.round(100 * (lastValue + (@.randomNumber(-10,20)/detector.change)))/100
    if newValue < detector.max
      return detector.max
    else if  detector.min > newValue
      return detector.min
    newValue = Math.round(newValue) if detector.round == true
    return newValue

  seedSensor: (detector, times, simulatonStack, callback)->
    self = @
    return callback() if detector.history.length >= times
    scale = 'seconds' # 'minutes'
    time = moment().subtract(times * @.sensorReadIntervall/1000, scale).add(times-detector.history.length * @.sensorReadIntervall/1000, scale).toDate() #.startOf(scale)
    if simulatonStack?
      y = simulatonStack[detector.history.length]
    else
      y = @.randSensorValue(detector)
    detector.currentValue = {x: time, y:y, seed: true}
    detector.history.unshift detector.currentValue
    setTimeout ()->
      self.seedSensor(detector, times, simulatonStack, callback)
    , 0

#///////////////////////////////////////////////////////////////////////////////////////////////////
module.exports = SensorMock
