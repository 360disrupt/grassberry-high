inspect = require('util').inspect
chalk = require('chalk')

routesService = require("./routes.service.js")
logger = require('../_logger/logger.js').getLogger()
userService = require('../user/user.service.js')

module.exports = (app, passport, user, environment) ->
#==================================================== SIGNUP & LOGIN ====================================================
  app.get('/login/auto', (req, res)->
    userService.getAutoLoginUser (err, user)->
      return res.json({ err: err }) if err?
      return res.json({ err: "Kein User vorhanden" }) if !user?
      # console.log "user", user
      req.login user, ()->
        return res.json({ success: true })
  )

  app.post(
    '/signup',
    passport.authenticate(
      'local-signup',
      {
        successRedirect : '/',
        failureFlash : true
      })
  )

  app.post(
    '/login',
    passport.authenticate(
      'local-login',
      {
        failureMessage: "Invalid username or password"
      })
    (req, res) ->
      return res.json({ success: true })
  )


  app.get('/logout', (req, res) ->
    req.logout()
    res.redirect('/')
  )


  app.get('/getAppUser', (req, res) ->

    responseUser = {}
    # console.log "req.user", req.user
    if req.user?._id?
      responseUser._id = req.user._id
    if req.user?.lastName?
      responseUser.lastName = req.user.lastName
    if req.user?.firstName?
      responseUser.firstName = req.user.firstName
    if req.user?.permissionLevel?
      responseUser.permissionLevel = req.user.permissionLevel

    return res.json(responseUser)
  )

#====================================================  Instagram ====================================================

  app.get('/auth/instagram', passport.authenticate('instagram', { scope : ['basic', 'public_content'] }))

  app.get('/auth/instagram/callback', (req, res, next)->
    passport.authenticate('instagram', (err, user, info)->
      # console.log "err #{err} user #{user} info #{JSON.stringify(info)}"
      if info?.message?
        res.status(403)
        return res.redirect("/#/oauth-error/#{info.message}")
      else if user?
        req.login(user, (err, user)->
          # console.log "err #{err} user #{user}"
          return res.redirect("/")
        )
      else
        logger.error(err) if err?
        res.status(403)
        return res.redirect("/#/oauth-error/Es ist ein Fehler beim Login aufgetreten")
    )(req, res, next)
  )

  #////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  return
