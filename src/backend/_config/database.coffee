#config/database.js
module.exports = (environment) ->
  if(environment=='test')
    return {'url' : "mongodb://localhost/TEST_gh", 'authdb':"admin"}

  else
    return {'url' : process.env.MONGODB_URL, 'authdb':process.env.MONGODB_ADMIN || 'admin'}