module.exports = ()->
  if process.env.NODE_ENV == 'production'
    root = 'https://grassberry-high.com'

  else
    root = 'http://localhost:3000'

  endpoints =
   feedback: root + '/api/v1/send-feedback'
   license: root + '/api/v1/check-payment'
   download: root + '/api/v1/update-software'
   subscription: root + '/api/v1/subscription'
   support: root + '/api/v1/support'
  return endpoints