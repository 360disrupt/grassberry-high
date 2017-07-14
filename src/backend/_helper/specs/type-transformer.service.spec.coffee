inspect = require('util').inspect
chalk = require('chalk')

proxyquire =  require('proxyquire').noCallThru()

applicationDir = '../../.tmp/serve/'

ObjectId = require('mongoose').Types.ObjectId

testSettings = require('./test.spec-settings.js')
loggerServiceStub = testSettings.loggerStub()
seedService = proxyquire(applicationDir + 'backend/seed/seed.js', '../_logger/logger.js': loggerServiceStub)
testSettings.connectDB()
idDummies = testSettings.getIdDummies()
getUserDummy = testSettings.getUserDummy

typeTransformerService = require(applicationDir + 'backend/_helper/type-transformer.service.js')

describe('>>>>>>>>>>>>>>>>>>>>>>>>>  TYPE TRANSFORMER FUNCTIONS  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<', () ->

  it('should be able to transform a hex buffer to array', () ->
    buffer = Buffer.from "ff9c0000023300002f", 'hex'
    expectedArray = [ 255, 156, 0, 0, 2, 51, 0, 0, 47 ]
    result = typeTransformerService.toArray(buffer)
    expect(result).toEqual(expectedArray)
  )
#//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
)
return