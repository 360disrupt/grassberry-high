inspect = require('util').inspect
chalk = require('chalk')

mongoose = require('mongoose')

LocalStrategy = require('passport-local').Strategy
InstagramStrategy = require('passport-instagram').Strategy
UserModel = require('../user/user.model.js').getModel()

module.exports = (passport) ->
  passport.serializeUser (user, done) ->
    done null, user._id
    return

  passport.deserializeUser (id, done) ->
    UserModel.findOne({_id: id}).exec (err, user) ->
      done err, user
      return
    return
#////////////////////////////////// LOCAL SIGNUP //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  passport.use 'local-signup', new LocalStrategy({
    usernameField: 'invitationCode'
    passwordField: 'password'
    passReqToCallback: true
  }, (req, invitationCode, password, done) ->
    process.nextTick ->
      UserModel.findOne({invitationCode: invitationCode, 'active': false}).exec (err, user) ->
        if err?
          return done(err)
        if !user?
          user.password = userService.generateHash(password)
          user.active = true
          user.save (err) ->
            if err
              throw err
            return done null, user
        else
          return done(null, false, { message: 'invitationCode ungültig oder bereits verwendet' })
  )
#////////////////////////////////// LOCAL LOGIN //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  passport.use 'local-login', new LocalStrategy({
    usernameField: 'email'
    passwordField: 'password'
    passReqToCallback: true
  }, (req, email, password, done) ->
    return done(null, false, {message: 'Non valid user'}) if !email? || email == ""
    UserModel.findOne( { 'email': email.toLowerCase(), 'active': true }).exec (err, user) ->
      if err
        return done(err)
      if !user?
        return done(null, false, {message: 'Non valid user'})
      if !user.validPassword(password)
        return done(null, false, {message: 'Non valid password'})

      return done null, user
    return
  )
#////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  return