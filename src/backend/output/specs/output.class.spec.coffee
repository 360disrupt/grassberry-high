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
outputDummies = require(applicationDir + 'backend/seed/outputs.seed.json')
socketIoMessengerStub = {}
DataLoggerMock = require(applicationDir + 'backend/data-logger/mocks/data-logger.class.mock.js')
RelaisControllerMock = require(applicationDir + 'backend/output/relais-controller/mocks/relais-controller.class.mock.js')
OutputClass = proxyquire(applicationDir + 'backend/output/output.class.js', '../_socket-io/socket-io-messenger.js': socketIoMessengerStub, '../data-logger/data-logger.class.js': DataLoggerMock)

socketIoMessengerStub.sendMessage = (recipient, message)->
  return


describe '>>>>>>>>>>>>>>>>>>>>>>>>>  OUPUT FUNCTIONS  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<', () ->
  beforeAll (done)->
    seedService.deleteNSeed(['outputs'],done)


  output = null
  beforeEach ()->
    outputOptions = outputDummies[0]
    outputOptions.relaisController = new RelaisControllerMock()
    output = new OutputClass(outputOptions)

  #TODO spy on instance of mocked class?
  # it('should be able to create an event',  (done) ->
  #   spyOn(dataLogger, 'createEvent')
  #   state = 0 #off
  #   info = "unit test"
  #   output.createEvent state, info, (err)->
  #     expect(dataLogger.createEvent).toHaveBeenCalled()
  # )

  it('should be able to switch an output on',  (done) ->
    spyOn(output, 'broadcastOutput')
    spyOn(output, 'createEvent').and.callFake( (a,b, callback)-> return callback() )
    detectorId = sensorDummies[0].detectors[0]._id
    info = "unit test"
    output.switchOn info, detectorId, (err)->
      expect(output.broadcastOutput).toHaveBeenCalled()
      expect(output.createEvent).toHaveBeenCalled()
      done()
  )

  it('should be able to switch an output off',  (done) ->
    output.state = 1 #on
    spyOn(output, 'broadcastOutput')
    spyOn(output, 'createEvent').and.callFake( (a,b, callback)-> return callback() )
    detectorId = sensorDummies[0].detectors[0]._id
    info = "unit test"
    output.switchOff info, detectorId, (err)->
      expect(output.broadcastOutput).toHaveBeenCalled()
      expect(output.createEvent).toHaveBeenCalled()
      done()
  )

  it('should not try to switch an output off which is already off',  (done) ->
    output.state = 0 #off
    spyOn(output, 'broadcastOutput')
    spyOn(output, 'createEvent').and.callFake( (a,b, callback)-> return callback() )
    detectorId = sensorDummies[0].detectors[0]._id
    info = "unit test"
    output.switchOff info, detectorId, (err)->
      expect(output.broadcastOutput).not.toHaveBeenCalled()
      expect(output.createEvent).not.toHaveBeenCalled()
      done()
  )

  it('should broadcast the current output' , ()->
    spyOn(socketIoMessengerStub, 'sendMessage')
    output.broadcastOutput()
    expect(socketIoMessengerStub.sendMessage).toHaveBeenCalled()
  )