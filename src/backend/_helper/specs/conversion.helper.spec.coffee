inspect = require('util').inspect
chalk = require('chalk')

moment = require("moment")
proxyquire =  require('proxyquire').noCallThru()

applicationDir = '../../.tmp/serve/'

ObjectId = require('mongoose').Types.ObjectId

testSettings = require('./test.spec-settings.js')
loggerServiceStub = testSettings.loggerStub()
seedService = proxyquire(applicationDir + 'backend/seed/seed.js', '../_logger/logger.js': loggerServiceStub)
testSettings.connectDB()
idDummies = testSettings.getIdDummies()
getUserDummy = testSettings.getUserDummy

systemReadStub = {}
conversionHelper = proxyquire(applicationDir + 'backend/_helper/conversion.helper.js', '../system/system.read.js': systemReadStub)
systemReadStub.getSystem = (options, callback)->
  return callback null, {timeZone: "Europe/Amsterdam"}

describe('>>>>>>>>>>>>>>>>>>>>>>>>>  CONVERSION HELPER FUNCTIONS  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<', () ->
  beforeAll (done)->
    conversionHelper.setTimeZone done

  it('should transform system time to local user time', () ->
    format = "YYYY-MM-DD hh:mm"
    dateTime = moment("2017-10-09T00:00:00.000Z")
    localTime = conversionHelper.formatTimeToLocalTime dateTime, format
    expect(localTime).toBe('2017-10-09 02:00')
  )
#//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
)
return