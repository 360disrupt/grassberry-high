inspect = require('util').inspect
chalk = require('chalk')


Promise = require("bluebird")
Promise.config({
  longStackTraces: true
  warnings: {
    wForgottenReturn: false
  }
})
mongoose = require('mongoose')
mongoose.Promise = Promise
mongoose.set('error', true)
# mongoose.set('debug', true)

ObjectId = mongoose.Types.ObjectId

applicationDir = '../../.tmp/serve/'


self = @

#////////////////////////////// COMMON STUBS //////////////////////////////
exports.loggerStub = () ->
  logger = {
    silly: (msg)->
      console.log chalk.blue "blue: #{msg}"
      return
    info: (msg)->
      console.log chalk.green "info: #{msg}"
      return
    warn: (msg)->
      console.log chalk.yellow "warn: #{msg}"
      return
    error: (msg)->
      console.log chalk.red "error: #{msg}"
      return
    debug: (msg)->
      console.log chalk.magenta "debug: #{msg}"
      return
  }
  loggerWrapper = {}
  loggerWrapper.getLogger = ()->
    return logger
  return loggerWrapper

#////////////////////////////// DATABASE //////////////////////////////
exports.connectDB = () ->
  configDB = require(applicationDir + 'backend/_config/database.js')('test')

  if mongoose.connection.readyState == 0
    mongoose.connect(configDB.url,{auth:{authdb:configDB.authdb}}, (err)->
      console.log err if err?
    )
    db = mongoose.connection
    db.on('error', ()->
      console.error.bind(console, 'connection error:'))
    db.once('open', () ->
      return db
    )
    process.on('SIGINT', () ->
      db.close( () ->
        console.log 'Mongoose default connection disconnected through app termination'
        process.exit(0)
      )
    )
  else
    db = mongoose.connection
    return db

#////////////////////////////// DUMMIES //////////////////////////////
exports.getIdDummies = () ->
  idDummies =
    USER_SUPERADMIN_ID : new ObjectId('55a76400007f6a835badb81a')

exports.getUserDummy = (permissionLevel, institute) ->
  idDummies = self.getIdDummies()
  appUser = {}
  appUser.permissionLevel = permissionLevel

  appUser.is = (check) ->
    return check == this.permissionLevel

  switch permissionLevel
    when 'customer'
      appUser._id = idDummies.CUSTOMER_1
      break
    else
      appUser = {}

  return appUser