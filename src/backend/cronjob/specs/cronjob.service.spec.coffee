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
cronjobDummies = dummies.cronjobDummies()
comparisonHelper = require(applicationDir + 'backend/_helper/comparison.helper.js')

outputServiceStub = {}
cronjobService = proxyquire(applicationDir + 'backend/cronjob/cronjob.service.js', '../output/output.service.js': outputServiceStub)

outputServiceStub.operateOutput = (outputId, action, info, detectorId, callback)->
  return callback null

describe('>>>>>>>>>>>>>>>>>>>>>>>>>  CRONJOB FUNCTIONS  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<', () ->
  beforeAll (done)->
    seedService.deleteNSeed(['outputs'],done)

  it('should be able to check cronjobs bootstatus',  () ->
    spyOn(outputServiceStub, 'operateOutput')
    cronjobService.bootStatus cronjobDummies
    expect(outputServiceStub.operateOutput).toHaveBeenCalled()
  )

  it('should be able to create cronjobs from DB',  (done) ->
    spyOn(cronjobService, 'bootStatus')

    cronjobService.launchCronjobs (err, success)->
      expect(err).toBe(null)
      expect(success).toBe(true)
      expect(cronjobService.bootStatus).toHaveBeenCalled()
      done()
  )


  it('should be able to stop cronjobs',  () ->
    cronjobService.stopCronjobs()
    expect(cronjobService.getActiveCronjobs().length).toBe(0)
  )
#//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
)
return