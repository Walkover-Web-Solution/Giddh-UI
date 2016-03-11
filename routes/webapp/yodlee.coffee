settings = require('../util/settings')
router = settings.express.Router()

# router.get '/login-register', (req, res) ->
#   authHead =
#     headers:
#       'Auth-Key': req.session.authKey
#       'X-Forwarded-For': res.locales.remoteIp
#   hUrl = settings.envUrl + 'yodlee/login-register'
#   settings.client.get hUrl, authHead, (data, response) ->
#     if data.status == 'error'
#       res.status(response.statusCode)
#     res.send data


# router.get '/company/:companyUniqueName/accounts', (req, res) ->
#   authHead =
#     headers:
#       'Auth-Key': req.session.authKey
#       'X-Forwarded-For': res.locales.remoteIp
#   hUrl = settings.envUrl + 'yodlee/company/' + req.params.companyUniqueName + '/accounts'
#   settings.client.get hUrl, authHead, (data, response) ->
#     if data.status == 'error'
#       res.status(response.statusCode)
#     res.send data

router.post '/company/:companyUniqueName/add-giddh-account', (req, res) ->
  hUrl = settings.envUrl + 'yodlee/company/' + req.params.companyUniqueName + '/add-giddh-account'
  authHead =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
      'X-Forwarded-For': res.locales.remoteIp
    data: req.body
  settings.client.post hUrl, authHead, (data, response) ->
    if data.status == 'error'
      res.status(response.statusCode)
    res.send data

router.post '/company/:companyUniqueName/verify-mfa', (req, res) ->
  hUrl = settings.envUrl + 'yodlee/company/' + req.params.companyUniqueName + '/verify-mfa'
  authHead =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
      'X-Forwarded-For': res.locales.remoteIp
    data: req.body
  console.log authHead.data 
  settings.client.post hUrl, authHead, (data, response) ->
    if data.status == 'error'
      res.status(response.statusCode)
    res.send data

router.get '/company/:companyUniqueName/all-site-account', (req, res) ->
  authHead =
    headers:
      'Auth-Key': req.session.authKey
      'X-Forwarded-For': res.locales.remoteIp
  hUrl = settings.envUrl + 'yodlee/company/' + req.params.companyUniqueName + '/all-site-account'
  settings.client.get hUrl, authHead, (data, response) ->
    if data.status == 'error'
      res.status(response.statusCode)
    res.send data


# get ledger transactions
router.get '/company/:companyUniqueName/accounts/:accountUniqueName/transactions', (req, res) ->
  authHead =
    headers:
      'Auth-Key': req.session.authKey
      'X-Forwarded-For': res.locales.remoteIp
  hUrl = settings.envUrl + 'yodlee/company/' + req.params.companyUniqueName + '/accounts/' + req.params.accountUniqueName + '/transactions'
  settings.client.get hUrl, authHead, (data, response) ->
    if data.status == 'error'
      res.status(response.statusCode)
    res.send data

module.exports = router