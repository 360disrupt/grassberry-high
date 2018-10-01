inspect = require('util').inspect
chalk = require('chalk')

routesService = require("./routes.service.js")
userService = require('../user/user.service.js')

module.exports = (app, passport, user, environment) ->
#==================================================== USERS ====================================================
  app.post('/createUser',routesService.loggedIn, routesService.clean, routesService.onShowModeBlocked, (req, res) ->
    userService.createUser(req.user, req.body.userData, (err, userId) ->
      if (err)
        return res.json({ err: err })
      return res.json(userId: userId)# return all todos in JSON format
    )
  )

  app.post('/getUsers',routesService.loggedIn, routesService.clean, (req, res) ->
    userService.getUsers(req.user, req.body.filter, {}, null, (err, users) ->
      if (err)
        return res.json({ err: err })
      return res.json(users: users)# return all todos in JSON format
    )
  )

  app.get('/getUsersAutocomplete/:term',routesService.loggedIn, routesService.clean, (req, res) ->
    userService.getUsers(req.user, {lastName: getRegex(req.params.term)}, {_id:1, lastName:1, field:1}, 30, (err, users) ->
      if (err)
        return res.json({ err: err })
      return res.json(users: users)# return all todos in JSON format
    )
  )


  app.delete('/deleteUser/:userId',routesService.loggedIn, routesService.clean, routesService.onShowModeBlocked, (req, res) ->
    userService.deleteUser(req.user, req.params.userId, (err, success) ->
      if (err)
        return res.json({ err: err })
      return res.json(success: success)# return all todos in JSON format
    )
  )