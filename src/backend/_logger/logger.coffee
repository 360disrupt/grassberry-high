inspect = require('eyespect').inspector({maxLength: null})
chalk = require('chalk')
debugLogger = require('debug')('logger')

moment = require('moment')
winston = require('winston')
mkdirp = require('mkdirp')
blocked = require('blocked')

require('winston-mongodb').MongoDB

envrionment = require('../_config/config.js')()

socketIoMessenger = require('../_socket-io/socket-io-messenger.js')
environment = require('../_config/config.js')()

logger = null
io = null

exports.launchLogger = (db, callback)->
  mkdirp('logs', (err) ->
    console.log err if err?
  )
  debugLogger "Db is #{db}"
  winston.emitErrs = true
  logger = new winston.Logger({
    transports: [
      new winston.transports.MongoDB({
          label: 'mongoLogger'
          level: 'debug'
          db : db,
          collection: 'serverlogs'
          handleExceptions: false
          colorize: false
          timestamp: true
        }),
      new winston.transports.Console({
        label: 'consoleLogger'
        level: 'debug'
        handleExceptions: false
        json: false
        colorize: true
      })
    ],
    exitOnError: false
  })
  winston.level = 'error'
  winston.handleExceptions(new winston.transports.File({ filename: 'logs/uncaughtExceptions.log', colorize: false })) if envrionment != 'development'

  winston.exitOnError = false

  logger.stream = {
    write: (message, encoding) ->
      logger.info(message)
  }

  logger.on('logging', (transport, level, message, meta) ->
    timestamp = moment().toISOString()
    # console.log "[#{message}] and [#{JSON.stringify(meta)}] have now been logged (#{transport.label}) at level: [#{level}] at #{timestamp}"
    if io != null && transport.label == 'mongoLogger'
      switch level
        when 'info'
          socketIoMessenger.sendLog('userLog', {'message':message, 'level':level, 'meta':meta, 'timestamp':timestamp})
          socketIoMessenger.sendLog('adminLog', {'message':message, 'level':level, 'meta':meta, 'timestamp':timestamp})
        else
          socketIoMessenger.sendLog('adminLog', {'message':message, 'level':level, 'meta':meta, 'timestamp':timestamp})
    return null
  )

  logger.setIo = (newIo, callback2) ->
    debugLogger "setIO"
    io = newIo
    return callback2 null


  blocked (ms) ->
    if ms > 10000
      logger.error "Event Loop was blocked for #{ms}"
    else
      logger.warn "Event Loop was blocked for #{ms}"
  , {threshold:1000}

  return callback null, logger

exports.getLogger = ()->
  if logger == null
    console.log "!!! attention logger is not connected to database yet"
  return logger
