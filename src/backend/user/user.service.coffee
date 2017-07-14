bcrypt = require('bcrypt')
mongoose = require('mongoose')

UserModel = require('../user/user.model.js').getModel()

self = @
# /////////////////////////////////////////////////////////// CREATE ////////////////////////////////////////////////////////
exports.createUser = (appUser, userData, callback) ->
  if(userData.lastName? && userData.permissionLevel)

    if appUser.is('superAdmin')
    else
      return callback('Keine Berechtigung zum Erstellen dieser Rechtegruppen')

    #console.log newUser
    newUser = UserModel(userData)

    newUser.save (err) ->
      return callback err if err?
      return callback(err, newUser._id)
  else
    callback("Pflichtfelder fehlen!")

# /////////////////////////////////////////////////////////// READ ////////////////////////////////////////////////////////


exports.generateHash = (password) ->
  return bcrypt.hashSync(password, bcrypt.genSaltSync(8), null)

#checking if password is valid
exports.validPassword = (password) ->
  # console.log password, " " ,bcrypt.hashSync(password, bcrypt.genSaltSync(8), null)
  # console.log bcrypt.compareSync(password, this.password)
  return bcrypt.compareSync(password, this.password)

exports.validToken = (token) ->
  return token? && token != "" && token == this.token


exports.getUserDetail = (userId, detailQuery, callback) ->
  #console.log userId, detailQuery
  r.table('users').get(userId).limit(1).select(detailQuery).run (err, detail) ->
    return callback err if err?
    return callback null, detail

#Gets detail filter on base of user's permission level
getUserFilter = (appUser, filter, callbackGetUsers) ->

  if appUser.is('superAdmin')

  else
    return callbackGetUsers('Keine Berechtigung zum Lesen der User')

  #console.log "filter", filter
  callbackGetUsers(null, filter)


exports.getUsers = (appUser, filter, selector, limit, callback) ->

  filter = {} if !filter?
  if !limit?
    limit = 0 # unlimited

  if !selector? || selector == {}
    selector = {password: 0}

  getUserFilter appUser, filter, (err, newFilter) ->
    return callback(err) if err?
    #console.log "newFilter", newFilter
    UserModel.find(newFilter).select(selector).limit(limit).sort({lastName:-1}).exec (err, usersFound) ->
      return callback err if err?
      return callback null, usersFound

exports.getAutoLoginUser = (callback) ->
  UserModel.find({permissionLevel:'autoLogin'}).limit(1).exec (err, users) ->
    return callback err if err?
    return callback "Kein User vorhanden" if users.length == 0
    return callback null, users[0]



# /////////////////////////////////////////////////////////// UPDATE ////////////////////////////////////////////////////////
exports.updateUser = (appUser, updateData, callback) ->
  permissionSuperAdmin = ['superAdmin', 'user']
  permissionUser = ['patient', 'user']

  UserModel.findOne({_id:updateData._id}).exec (err, user) ->
    callback err if err

    if !user?
      return callback 'kein Benutzer mit der ID gefunden'

    if appUser.is('superAdmin')
      permissionArray = permissionSuperAdmin
      if !permissionArray.some((permission) -> permission == user.permissionLevel)
        return callback 'keine Berechtigung zum Editieren des Benutzers'

    else if appUser.is('user')
      permissionArray = permissionUser
      if appUser._id.toString() != user._id.toString()
        return callback 'Sie können nur sich selbst editieren'

    else
      return callback 'keine Berechtigung zum Editieren des Benutzers'


    user.gender = updateData.gender if updateData.gender?
    user.lastName = updateData.lastName if updateData.lastName?
    user.firstName = updateData.firstName if updateData.firstName?
    user.field = updateData.field if updateData.field?
    user.telephone = updateData.telephone if updateData.telephone?
    user.mobile = updateData.mobile if updateData.mobile?
    user.street = updateData.street if updateData.street?
    user.zipcode = updateData.zipcode if updateData.zipcode?
    user.city = updateData.city if updateData.city?

    #Can only be updated when within the appUsers permissionArray and not the user himself
    user.permissionLevel = updateData.permissionLevel if permissionArray.some((permission) -> permission == updateData.permissionLevel) && user._id.toString() != appUser._id.toString()

    #Password can be edited if the own password is correct
    if updateData.password?
      console.log appUser._id
      r.table('users').get(appUser._id).limit(1).run (err, foundAppUser) ->
        return callback err if err?
        if updateData.ownPassword? && self.validPassword(updateData.ownPassword)
          user.password = userService.generateHash(updateData.password)
          user.active = true
          r.table('users').collection.insert(user).run (err, updatedUser)->
            return callback err if err?
            return callback null, updatedUser
        else
          return callback 'Bitte überprüfen Sie ihr Passwort'


    else
      r.table('users').collection.insert(user).run (err, updatedUser)->
        return callback err if err?
        updatedUser = updatedUser || null
        return callback null, updatedUser




# /////////////////////////////////////////////////////////// DELETE ////////////////////////////////////////////////////////

exports.deleteUser = (appUser, userId, callback) ->
  #User cant delte users lower than their perission level, in other fields/institutions
  permissionSuperAdmin = ['user']
  permissionUser = ['user']

  UserModel.findOne({_id: userId}).run (err, user) ->
    return callback err if err?
    err = null if !err?

    if !user?
      return callback 'kein Benutzer mit der ID gefunden'+userId

    #Users can not delete users with lower permission level
    if appUser.is('superAdmin')
      if !permissionSuperAdmin.some((permission) -> permission == user.permissionLevel)
        return callback 'keine Berechtigung zum Löschen des Benutzers'

    else if appUser.is('user')
      if appUser._id.toString() != user._id.toString()
        return callback 'Sie können nur sich selbst löschen'

    else
      return callback 'keine Berechtigung zum Löschen des Benutzers'

    UserModel.remove({_id: userId}).exec (err, msg)->
      return callback err if err?
      err = null if !err?
      #console.log msg
      return callback null, true


