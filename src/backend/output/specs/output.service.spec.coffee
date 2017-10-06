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

outputDummies = require(applicationDir + 'backend/seed/outputs.seed.json')
socketIoMessengerStub = {}
RelaisControllerMock = require(applicationDir + 'backend/output/relais-controller/mocks/relais-controller.class.mock.js')
outputService = proxyquire(applicationDir + 'backend/output/output.service.js', './relais-controller/mocks/relais-controller.class.mock.js': RelaisControllerMock)


describe '>>>>>>>>>>>>>>>>>>>>>>>>>  OUPUT SERVICE FUNCTIONS  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<', () ->
  beforeAll (done)->
    seedService.deleteNSeed(['outputs'],done)


  # output = null
  # beforeEach ()->
  #   outputOptions = outputDummies[0]
  #   outputOptions.relaisController = new RelaisControllerMock()
  #   output = new OutputClass(outputOptions)

  it('should be able to block an output',  (done) ->
    spyOn(outputService, 'getOutputById').and.callFake (id, callback) ->
      return callback null, { _id:"someId" }
    outputService.blockOutput "someId", 10, (err, output)->
      expect(err).toBe(null)
      expect(moment(output.blockedTill).diff(moment(), 'minutes')).toBe(9)

      done()
  )
