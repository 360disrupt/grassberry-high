inspect = require('util').inspect
chalk = require('chalk')

mkdirp = require('mkdirp')
fs = require('fs')
proxyquire =  require('proxyquire').noCallThru()

applicationDir = '../../.tmp/serve/'

testSettings = require('./test.spec-settings.js')
loggerServiceStub = testSettings.loggerStub()
seedService = proxyquire(applicationDir + 'backend/seed/seed.js', '../../_logger/logger.js': loggerServiceStub)
testSettings.connectDB()
dummies = require(applicationDir + 'backend/_spec-helpers/dummies.js')

restHelperStub = {}
shellServiceStub = {}
systemSupport = proxyquire(applicationDir + 'backend/system/system.support.js', '../shell/shell.service.js': shellServiceStub, '../_api/rest.helper.js': restHelperStub)

shellServiceStub.mongoDump = (callback)->
  return callback null, "RESULT"

shellServiceStub.getSerial = (callback)->
  return callback null, "123456789"

shellServiceStub.zipLogs = (callback)->
  fs.writeFile applicationDir + '/logs/logs.gz', 'Hello Node.js', (err) ->
    return callback err

restHelperStub.emit = (method, url, data, callback)->
  return callback null

describe('>>>>>>>>>>>>>>>>>>>>>>>>>  SYSTEM SUPPORT FUNCTIONS  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<', () ->
  beforeAll (done)->
    mkdirp applicationDir + "/logs", (err)->
      throw err if err?
      seedService.deleteNSeed([],done)

  it('should be able to send support request',  (done) ->
    options = {}
    systemSupport.sendLogs options, (err)->
      expect(err).toBe(null)
      done()
  )
#//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
)
return