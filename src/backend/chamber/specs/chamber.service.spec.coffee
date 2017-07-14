OUTPUT_OFF = 0

inspect = require('util').inspect
chalk = require('chalk')

proxyquire =  require('proxyquire').noCallThru()

applicationDir = '../../.tmp/serve/'

ObjectId = require('mongoose').Types.ObjectId

testSettings = require('./test.spec-settings.js')
loggerServiceStub = testSettings.loggerStub()
seedService = proxyquire(applicationDir + 'backend/seed/seed.js', '../_logger/logger.js': loggerServiceStub)
testSettings.connectDB()
dummies = require(applicationDir + 'backend/_spec-helpers/dummies.js')
chamberDummies = dummies.chamberDummies()
comparisonHelper = require(applicationDir + 'backend/_helper/comparison.helper.js')

outputServiceStub = {}
ruleServiceStub = {}
cronJobServiceStub = {}
i2cServiceMock = require(applicationDir + 'backend/i2c/mocks/i2c.mock.js')

chamberService = proxyquire(applicationDir + 'backend/chamber/chamber.service.js', '../output/output.service.js': outputServiceStub, '../rule/rule.service.js': ruleServiceStub, '../cronjob/cronjob.service.js': cronJobServiceStub, '../i2c/i2c.js': i2cServiceMock)

outputServiceStub.getOutputState = ()->
  return OUTPUT_OFF

ruleServiceStub.upsertRule = (rule, callback)->
  upsertedRule = {_id: new ObjectId("588a427d617fff11d79b3054") }
  return callback null, upsertedRule

cronJobServiceStub.removeCronjobs = (cronjobs)->
  return

cronJobServiceStub.createCronjob = (createCronjob, callback)->
  return callback null, null

describe('>>>>>>>>>>>>>>>>>>>>>>>>>  CHAMBER FUNCTIONS  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<', () ->
  beforeAll (done)->
    seedService.deleteNSeed(['chambers', 'sensors', 'outputs', 'rules', 'cronjobs'],done)

  it('should be able to get the chambers and add allOutputs and allSensors',  (done) ->
    options = { lean: true }
    chamberService.getChambers options, (err, chambers)->
      expect(err).toBe(null)
      expect(chambers).toEqual([ chamberDummies.readMainBox ])
      done()
  )

  it('should be able to upsert an existing chamber',  (done) ->
    chamber = chamberDummies.upsertMainBox
    chamberService.upsertChamber chamber, (err, upsertedChamber)->
      expect(err).toBe(null)
      upsertedChamber = upsertedChamber.toObject()
      expect(upsertedChamber).toEqual(chamberDummies.upsertedMainBox)
      done()
  )
#//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
)
return