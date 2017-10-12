SESSION_SECRET = 'myCatEatsPizza2015'
COOKIE_MAX_AGE = null

inspect = require('util').inspect
chalk = require('chalk')
require('longjohn') if process.env.NODE_ENV != 'production' || process.env.LONG_ERROR_TRACES
debugBoot = require('debug')('boot')

async = require('async')
moment = require('moment')
startProcessTime = moment()

environment = require('./backend/_config/config.js')()
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

morgan       = require('morgan')
require('pretty-error').start()

http = require('http')
portHTTP = process.env.PORT_HTTP || 80
portHTTPS = process.env.PORT_HTTPS || null #gulp serve need to be started with sudo!, if null => http will be started

io = require('socket.io')

express  = require('express')
cookieParser = require("cookie-parser")
session = require("express-session")
bodyParser = require("body-parser")
compress = require('compression')

parseurl = require('parseurl')

passport = require('passport')
require('./backend/_config/passport')(passport) #pass passport for configuration
ConnectRoles = require('connect-roles')

user = new ConnectRoles(
  failureHandler: (req, res, action) ->
    # optional function to customise code that runs when
    # user fails authorisation
    accept = req.headers.accept or ''
    res.status 403
    if !!~accept.indexOf('html')
      res.render 'access-denied', action: action
    else
      res.send 'Access Denied - You don\'t have permission to: ' + action
    return
  userProperty: 'user'
)

#Database ======================================================================
configDB = require('./backend/_config/database.js')(environment)
mongoose.connect(configDB.url,{auth:{authdb:configDB.authdb}}, (err)->
  if (err)
    console.log('Database Error: ',err)
)
db = mongoose.connection
db.on('error', console.error.bind(console, 'connection error:'))
db.once 'open', () ->
  console.log "Database established"
  require('./backend/_logger/logger.js').launchLogger db.db, (err, logger)->
    #App & Session ======================================================================
    MongoStore = require("connect-mongo")(session)

    app = express()
    app.use( compress() )
    app.use( cookieParser(SESSION_SECRET) )
    # app.use( bodyParser.json() )
    # app.use( bodyParser.urlencoded({extended:true}) )
    app.use(bodyParser.urlencoded({
      extended: false,
      parameterLimit: 10000,
      limit: 1024 * 1024 * 10
    }))
    app.use(bodyParser.json({
      extended: false,
      parameterLimit: 10000,
      limit: 1024 * 1024 * 10
    }))
    mySession = session( {
      secret:SESSION_SECRET,
      resave: true,
      saveUninitialized: false,
      rolling: true,
      store: new MongoStore({mongooseConnection:db}),
      cookie: {
        httpOnly: false,
        secure: false,
        maxAge:COOKIE_MAX_AGE
      }
    })
    app.use(mySession)
    app.use(passport.initialize())
    app.use(passport.session()) # persistent login sessions
    app.use(user.middleware())


    #//////////////////////////////////// USER RIGHTS /////////////////////////
    #TODO Own Modules

    #anonymous users can only access the home page
    #returning false stops any more rules from being
    #considered
    user.use (req, action) ->
      if !req.isAuthenticated()
        console.log "is not Authenticated"
        return action == 'login'
      return

    user.use 'user', (req) ->
      if req.user.permissionLevel == 'user'
        return true
      return

    user.use 'admin', (req) ->
      if req.user.permissionLevel == 'admin'
        return true
      return

    user.use 'superAdmin', (req) ->
      if req.user.permissionLevel == 'superAdmin'
        return true
      return

    user.use (req) ->
      if req.user.permissionLevel == 'superAdmin'
        return true
      return

    # Routes ======================================================================

    rootPath = __dirname + '/../../'
    app.use('/bower_components', express.static(rootPath + 'bower_components'))
    app.use('/partials', express.static(__dirname + '/../partials'))
    require('./backend/_routes/routes.js')(app, passport, user, environment)

    socketIoMessenger = require('./backend/_socket-io/socket-io-messenger.js')
    #//////////////////////////////////////////// LAUNCH SERVER ///////////////////////////////////////////
    if portHTTPS != null
      console.log "getting certificate from: #{__dirname + '/config/ssl/'}"
      fs = require('fs')
      sslOptions = {
        key: fs.readFileSync(__dirname + '/config/ssl/server.key'),
        cert: fs.readFileSync(__dirname + '/config/ssl/server.crt'),
        ca: fs.readFileSync(__dirname + '/config/ssl/ca.crt'),
        requestCert: true,
        rejectUnauthorized: false
      }
      srvHTTPs = https.createServer(sslOptions,app).listen(portHTTPS, () ->
        logger.info("Secure Express server listening on port #{portHTTPS} environment: #{environment}")
        io = io.listen(srvHTTPs)
        logger.setIo io, ()->
          startSeeding ()->
            logRoutes(app) if environment == 'development'
            socketIoMessenger.initSocketListener(io)
            # cronConfig.launchCrons(environment) if !process.env.NO_CRONS?
            console.log "Booting took #{moment().diff(startProcessTime, 'seconds')} seconds"
      )
    else
      systemUpdate = require('./backend/system/system.update.js')
      conversionHelper = require('./backend/_helper/conversion.helper.js')
      srvHTTP = http.createServer(app).listen(portHTTP, () ->
        logger.info("Express server listening on port #{portHTTP} environment: #{environment}")
        io = io.listen(srvHTTP)
        async.series [
          (next)->
            conversionHelper.setTimeZone next
          (next)->
            debugBoot "-->IO<--"
            logger.setIo io, next
          (next)->
            debugBoot "-->Socket Messanger<--"
            socketIoMessenger.initSocketListener(io)
            startSeeding next
          (next)->
            debugBoot "-->License<--"
            options = {}
            systemUpdate.getLicenseInformation options, (err)->
              console.error err if err?
              return next()
          (next)->
            debugBoot "-->I2C<--"
            require('./backend/i2c/i2c.js').bootI2C next
          (next)->
            debugBoot "-->Sensors & Outputs<--"
            bootOptions = {}
            require('./backend/_helper/ouputAndSensorBoot.helper.js').bootSensorsAndOutputs bootOptions, next
        ], (err)->
          logger.error "Failed to boot", err if err?
          socketIoMessenger.sendMessage('system', {payload: 'booted'})
          systemUpdate.bootLicenseCronjob()
          systemUpdate.bootSoftwareUpdateCronjob() if process.env.OS != 'MAC OSX'
          debugBoot "-->Boot Completed<--"
          debugBoot "Booting took #{moment().diff(startProcessTime, 'seconds')} seconds"
          debugBoot "\n================================= BOOTED #{conversionHelper.getLocalTime 'DD.MM HH:mm:ss'} ========================\n"
      )

#Error Handling
if process.env.HEAP_SNAPSHOT == 'true'
  snapShotPath = __dirname + '/../../logs/snapshot/'
  mkdirp = require('mkdirp')
  mkdirp snapShotPath, (err)->
    return if err?
    console.info snapShotPath
    crap = require('oh-crap')(snapShotPath, onerror)
    onerror = (err)->
      console.error "CREATING A HEAP", err.stack
      setTimeout ()->
        console.error 'exiting'
        process.exit(1)
      , 1000


process.on 'error', (err)->
  if environment == 'development'
    throw err
  else
    console.error chalk.bgRed "ERR", err

logRoutes = (app)->
  app._router.stack.forEach (r)->
    if r.route && r.route.path
      console.log(r.route.path)
    return
  return

startSeeding = (callback)->
  require('./backend/seed/seed.js').startSeeding (err)->
    console.log err if err?
    return callback err if err?
    return callback()