express  = require('express')

module.exports = (app, passport, user, environment) ->
  # normal routes ===============================================================
  # show the home page
  path = __dirname + '/../../'
  app.use(express.static(path))

  require('./login.routes.js')(app, passport, user, environment)
  require('./user.routes.js')(app, passport, user, environment)
  require('./development.routes.js')(app, passport, user, environment)
  require('./shell.routes.js')(app, passport, user, environment)
  require('./chamber.routes.js')(app, passport, user, environment)
  require('./output.routes.js')(app, passport, user, environment)
  require('./sensor.routes.js')(app, passport, user, environment)
  require('./rule.routes.js')(app, passport, user, environment)
  require('./data-logger.routes.js')(app, passport, user, environment)
  require('./i2c.routes.js')(app, passport, user, environment)
  require('./feedback.routes.js')(app, passport, user, environment)
  require('./system.routes.js')(app, passport, user, environment)
  require('./subscription.routes.js')(app, passport, user, environment)

#==================================================== DEV ====================================================

  #////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  return

