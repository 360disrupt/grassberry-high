HISTORY_LENGTH = 30

inspect = require('util').inspect
chalk = require('chalk')

moment = require('moment')
async = require('async')
debugTemp = require('debug')('sensor:temp')
debugHumidity = require('debug')('sensor:humidity')

SensorMock = require('./sensor.class.mock.js')
socketIoMessenger = require('../../_socket-io/socket-io-messenger.js')
logger = require('../../_logger/logger.js').getLogger()

simulation = {
  temperature: require('./simulation/temperature-simulation.json')
  humidity: require('./simulation/humidity-simulation.json')
}

class HDC1000SensorMock extends SensorMock #temperature/humidity
  constructor: (options, callback) ->
    debugTemp "Temp/Humdity sensor mock #{options._id}"
    that = @
    @.simulationCounter = HISTORY_LENGTH
    super options, (err)->
      async.eachSeries that.detectors,
        (detector, next)->
          switch detector.type
            when 'temperature'
              detector.min = 20
              detector.max = 40
            when 'humidity'
              detector.min = 50
              detector.max = 80
          detector.change = 100
          that.seedSensor detector, HISTORY_LENGTH, simulation[detector.type], ->
            that.boot (err)->
              that.readSensor()
              next()
        callback null, that

  boot: (callback)->
    return callback()

  readSensor: ()->
    self = @
    @.simulationCounter++
    if @.simulationCounter >= 999
      @.simulationCounter = 0
    async.eachSeries @.detectors,
      (detector, next)->
        switch detector.type
          when 'temperature'
            temperature = simulation.temperature[self.simulationCounter]
            debugTemp "TEMPERATURE: #{temperature} (adr #{self.address}) #{moment().format('hh:mm:ss DD-MM-YYYY')}"
            self.processSensorValue(detector, temperature, next)

          when 'humidity'
            humidity = simulation.humidity[self.simulationCounter]
            debugHumidity "HUMIDITY: #{humidity} (adr #{self.address})}  #{moment().format('hh:mm:ss DD-MM-YYYY')}"
            self.processSensorValue(detector, humidity, next)

          else
            return next "Detector type #{detector.type} not implemented"
      (err) ->
        logger.error "@hdc1000", err if err?
        setTimeout ()->
          self.readSensor()
        , self.sensorReadIntervall
        return



#/////////////////////////////////////////////////////////////////////////////////////////////////////
module.exports = HDC1000SensorMock