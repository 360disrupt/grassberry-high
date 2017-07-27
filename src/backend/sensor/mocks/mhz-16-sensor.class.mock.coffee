HISTORY_LENGTH = 30

inspect = require('util').inspect
chalk = require('chalk')

moment = require('moment')
async = require('async')
debugCO2 = require('debug')('sensor:co2')

SensorMock = require('./sensor.class.mock.js')

typeTransformerService = require('../../_helper/type-transformer.service.js')
socketIoMessenger = require('../../_socket-io/socket-io-messenger.js')
logger = require('../../_logger/logger.js').getLogger()

simulation = {
  co2: require('./simulation/co2-simulation.json')
}

class MHZ16SensorMock extends SensorMock #co2
  constructor: (options, callback) ->
    debugCO2 "CO2 sensor mock #{options._id}"
    that = @
    @.simulationCounter = HISTORY_LENGTH
    super options, (err)->
      async.eachSeries that.detectors,
        (detector, next)->
          detector.min = 550
          detector.max = 2000
          detector.change = 1
          that.seedSensor detector, HISTORY_LENGTH, simulation[detector.type], ->
            that.boot (err)->
              that.readSensor()
              next()
        callback null, that


  boot: (callback)->
    self = @
    return callback()

  readSensor: ()->
    self = @
    @.simulationCounter++
    if @.simulationCounter > 999
      @.simulationCounter = 0
    async.eachSeries @.detectors,
      (detector, next)->
        switch detector.type
          when 'co2'
            co2 = simulation.co2[self.simulationCounter]
            debugCO2 "CO2: PPM  #{co2} (adr #{self.address}) #{moment().format('hh:mm:ss DD-MM-YYYY')}"
            self.processSensorValue(detector, co2, next)
          else
            return next "Detector type not implemented"
      (err) ->
        console.error "CO2 err", err if err?
        logger.error err if err?
        setTimeout ()->
          self.readSensor()
        , self.sensorReadIntervall
        return



#/////////////////////////////////////////////////////////////////////////////////////////////////////
module.exports = MHZ16SensorMock