inspect = require('util').inspect
chalk = require('chalk')

sanitize = require("mongo-sanitize")

UNAUTHORIZED = 401

exports.clean = (req, res, next) ->
  req.body = sanitize(req.body) if req.body?
  req.params = sanitize(req.params) if req.params?
  next()

exports.loggedIn = (req, res, next) ->
  if (req.user)
    next()
  else
    res.status(UNAUTHORIZED).send('Unauthorized!')

exports.isAdmin = (req, res, next) ->
  if (req.user && req.user.permissionLevel == 'superAdmin')
    next()
  else
    res.status(UNAUTHORIZED).send('Unauthorized!')

exports.onShowModeBlocked = (req, res, next) ->
  if process.env.ON_SHOW_MODE_BLOCKED == "true" && (!req.user || req.user.permissionLevel != 'superAdmin')
    res.status(UNAUTHORIZED).send({ warning: 'Access is currently blocked! The device is on show mode.' })
  else
    next()

exports.getRegex = (term) ->
  try
    regex = new RegExp(term, "i")
  catch err
    regex = new RegExp('.*', "i")

# checkPermission = (req, res, next) ->
#   console.log "permission"
#   next()