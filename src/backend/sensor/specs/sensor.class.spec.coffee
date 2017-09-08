inspect = require('util').inspect
chalk = require('chalk')

moment = require('moment')
proxyquire =  require('proxyquire').noCallThru()

applicationDir = '../../.tmp/serve/'

ObjectId = require('mongoose').Types.ObjectId

testSettings = require('./test.spec-settings.js')
loggerServiceStub = testSettings.loggerStub()
seedService = proxyquire(applicationDir + 'backend/seed/seed.js', '../_logger/logger.js': loggerServiceStub)
testSettings.connectDB()
comparisonHelper = require(applicationDir + 'backend/_helper/comparison.helper.js')

sensorDummies = require(applicationDir + 'backend/seed/sensors.seed.json')
rulesDummies = require(applicationDir + 'backend/seed/rules.seed.json')
outputServiceStub = {}
ruleServiceStub = {}
socketIoMessengerStub = {}

SensorClass = proxyquire(applicationDir + 'backend/sensor/sensor.class.js', '../output/output.service.js': outputServiceStub, '../rule/rule.service.js': ruleServiceStub, '../_socket-io/socket-io-messenger.js':socketIoMessengerStub)

ruleServiceStub.getRules = (options, callback)->
  rules = [{ _id: "123" }]
  return callback null, rules

socketIoMessengerStub.sendMessage = (recipient, message)->
  return

outputServiceStub.getOutputById = (id, callback)->
  output = {
    name: "dummyOutput",
    state:0
  }
  return callback null, output

outputServiceStub.operateOutput = (outputId, operation, info, detectorId, callback)->
  return callback()

describe '>>>>>>>>>>>>>>>>>>>>>>>>>  SENSOR FUNCTIONS  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<', () ->
  beforeAll (done)->
    seedService.deleteNSeed(['sensors', 'sensorData'],done)

  describe '>>>>>>>>>>>>>>>>>>>>>>>>>  SENSOR PROCESS, WRITE & BROADCAST  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<', () ->
    sensor = null
    beforeEach (next)->
      sensor = new SensorClass(sensorDummies[0], next)

    it('should be able to get the sensor',  () ->
      receivedSensor = sensor.getSensor()
      expect(receivedSensor._id).toBe("588a427d617fff11d79b3049")
    )

    it('check write should be true if not blocked',  () ->
      detector = {
        lastWrite: null
      }
      checkWrite = sensor.checkWrite(detector)
      expect(checkWrite).toBe(true)
    )

    it('check write should be true if exceeded blocked',  () ->
      detector = {
        lastWrite: moment().subtract(2*sensor.sensorWriteIntervall)
      }
      checkWrite = sensor.checkWrite(detector)
      expect(checkWrite).toBe(true)
    )

    it('check write should be false if blocked',  () ->
      detector = {
        lastWrite: moment().subtract(0.8*sensor.sensorWriteIntervall)
      }
      checkWrite = sensor.checkWrite(detector)
      expect(checkWrite).toBe(false)
    )

    it('check push should be true if not blocked',  () ->
      detector = {
        lastPush: null
      }
      checkPush = sensor.checkPush(detector)
      expect(checkPush).toBe(true)
    )

    it('check push should be true if exceeded blocked',  () ->
      detector = {
        lastPush: moment().subtract(2*sensor.sensorPushIntervall)
      }
      checkPush = sensor.checkPush(detector)
      expect(checkPush).toBe(true)
    )

    it('check push should be false if blocked',  () ->
      detector = {
        lastPush: moment().subtract(0.8*sensor.sensorPushIntervall)
      }
      checkPush = sensor.checkPush(detector)
      expect(checkPush).toBe(false)
    )

    it('should change the sensors time unit',  (done) ->
      sensor.changeSensorTimeUnit 'minutes', (err, receivedSensor)->
        expect(err).toBe(null)
        if receivedSensor?
          expect(receivedSensor._id).toBe("588a427d617fff11d79b3049")
          expect(receivedSensor.sensorPushIntervall).toBe(60000) #1min in ms
        else
          expect(receivedSensor).toBeDefined()
        done()
    )

    it('should broadcast the current sensor history' , ()->
      spyOn(socketIoMessengerStub, 'sendMessage')
      sensor.broadcastSensorHistory()
      expect(socketIoMessengerStub.sendMessage).toHaveBeenCalled()
    )

    it('should normalize sensor values to buffer swings' , ()->
      detector = { shortBuffer: [1,1,1,1,1] }
      value = 10
      adjustedValue = sensor.adjustValue(detector, value)
      expect(adjustedValue).toBe(2.5)
    )

    it('should process a sensor value' , (done)->
      spyOn(sensor, 'adjustValue').and.returnValue 24
      spyOn(sensor, 'applyRules')
      spyOn(sensor, 'sensorSaveValueToDb').and.callFake( (a,b, callback)-> return callback() )
      newValue = 24
      detector = { history: [] }
      sensor.processSensorValue detector, newValue, (err)->
        expect(err).toBe(null)
        expect(detector.history.pop()['y']).toBe(newValue)
        expect(detector.currentValue['y']).toBe(newValue)
        expect(sensor.adjustValue).toHaveBeenCalled()
        expect(sensor.applyRules).toHaveBeenCalled()
        expect(sensor.sensorSaveValueToDb).toHaveBeenCalled()
        done()
    )


  describe '>>>>>>>>>>>>>>>>>>>>>>>>>  SENSOR READ  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<', () ->
    sensor = null
    data = []
    beforeEach (next)->
      sensor = new SensorClass(sensorDummies[0], next)
      data = [
        { timestamp: moment().subtract(0.5, 'hours'), value: 10 }
        { timestamp: moment().subtract(0.5, 'minutes'), value: 10 }
        { timestamp: moment().subtract(0.5, 'seconds'), value: 10 }
      ]


    it('should filter history, minimum step seconds',  (done) ->
      sensor.timeUnit = 'seconds'
      sensor.filterSensorHistory data, (err, filteredData)->
        expect(filteredData.length).toBe(3)
        done()
    )

    it('should filter history, minimum step minutes',  (done) ->
      sensor.timeUnit = 'minutes'
      sensor.filterSensorHistory data, (err, filteredData)->
        expect(filteredData.length).toBe(2)
        done()
    )

    it('should filter history, minimum step hours',  (done) ->
      sensor.timeUnit = 'hours'
      sensor.filterSensorHistory data, (err, filteredData)->
        expect(filteredData.length).toBe(1)
        done()
    )


    it("should read the sensor's history",  (done) ->
      detector = {
        type: 'temperature'
      }
      sensor.readSensorHistory detector, (err, filteredData)->
        expect(filteredData.length).toBe(1)
        done()
    )

  describe '>>>>>>>>>>>>>>>>>>>>>>>>>  SENSOR INIT APPLY  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<', () ->
    sensor = null
    beforeEach (next)->
      sensor = new SensorClass(sensorDummies[0], next)

    it("should init the sensor",  () ->
      detector = {}
      sensor.initRules detector
      expect(detector.rules.length).toBe(1)
    )

    it("should apply the sensor's rules if it is above onValue and output is off (on > off)",  () ->
      detector = {
        currentValue: { y:32 }
        rules: [rulesDummies[0]]
      }
      spyOn(outputServiceStub, 'operateOutput').and.callThrough()
      sensor.applyRules detector
      expect(outputServiceStub.operateOutput).toHaveBeenCalled()
    )

    it("should NOT apply the sensor's rules if is NOT above onValue",  () ->
      detector = {
        currentValue: { y:28 }
        rules: [rulesDummies[0]]
      }
      spyOn(outputServiceStub, 'operateOutput').and.callThrough()
      sensor.applyRules detector
      expect(outputServiceStub.operateOutput).not.toHaveBeenCalled()
    )
    it("should apply the sensor's rules if it is below onValue and output is off (on < off)",  () ->
      detector = {
        currentValue: { y:9 }
        rules: [rulesDummies[1]]
      }
      spyOn(outputServiceStub, 'operateOutput').and.callThrough()
      sensor.applyRules detector
      expect(outputServiceStub.operateOutput).toHaveBeenCalled()
    )

    it("should NOT apply the sensor's rules if it is NOT below onValue (on < off)",  () ->
      detector = {
        currentValue: { y:11 }
        rules: [rulesDummies[1]]
      }
      spyOn(outputServiceStub, 'operateOutput').and.callThrough()
      sensor.applyRules detector
      expect(outputServiceStub.operateOutput).not.toHaveBeenCalled()
    )
#//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
return