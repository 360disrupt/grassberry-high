module.exports = () ->
  #Environment
  env = process.env.NODE_ENV || 'development'
  # env = process.env.NODE_ENV || 'test'
  # env = process.env.NODE_ENV || 'production'
  return env