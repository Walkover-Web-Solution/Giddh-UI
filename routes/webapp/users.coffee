settings = require('../util/settings')
router = settings.express.Router()

router.get '/:uniqueName', (req, res) ->
  authHead =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
      'X-Forwarded-For': res.locales.remoteIp
  hUrl = settings.envUrl + 'users/' + req.params.uniqueName
  settings.client.get hUrl, authHead, (data, response) ->
    if data.status == 'error'
      res.status(response.statusCode)
    res.send data

#Delete sub user
router.delete '/:uniqueName', (req, res) ->
  authHead =
    headers:
      'Auth-Key': req.session.authKey
      'X-Forwarded-For': res.locales.remoteIp
  hUrl = settings.envUrl + 'users/' + req.params.uniqueName
  settings.client.delete hUrl, authHead, (data, response) ->
    if data.status == 'error'
      res.status(response.statusCode)
    res.send data

# create sub user
router.post '/:uniqueName/sub-user', (req, res) ->
  authHead =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
      'X-Forwarded-For': res.locales.remoteIp
    data: req.body
  hUrl = settings.envUrl + 'users/' + req.params.uniqueName+ '/sub-user'
  settings.client.post hUrl, authHead, (data, response) ->
    if data.status == 'error'
      res.status(response.statusCode)
    res.send data

# get sub user authkey
router.get '/:uniqueName/auth-key/sub-user', (req, res) ->
  authHead =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
      'X-Forwarded-For': res.locales.remoteIp
    parameters:
      uniqueName: req.query.uniqueName
  hUrl = settings.envUrl + 'users/auth-key'
  settings.client.get hUrl, authHead, (data, response) ->
    if data.status == 'error'
      res.status(response.statusCode)
    res.send data

router.get '/auth-key/:uniqueName', (req, res) ->
  data = {
    status: "success"
    body: req.session.authKey
  }
  res.send(data)

router.put '/:uniqueName/generate-auth-key', (req, res) ->
  authHead =
    headers:
      'Auth-Key': req.session.authKey
      'X-Forwarded-For': res.locales.remoteIp
  hUrl = settings.envUrl + 'users/' + req.params.uniqueName + '/generate-auth-key'
  settings.client.put hUrl, authHead, (data, response) ->
    if data.status == 'error'
      res.status(response.statusCode)
    else
      req.session.authKey = data.body.authKey
    res.send data

router.get '/:uniqueName/subscribed-companies', (req, res) ->
  authHead =
    headers:
      'Auth-Key': req.session.authKey
      'X-Forwarded-For': res.locales.remoteIp
  hUrl = settings.envUrl + 'users/' + req.params.uniqueName + '/subscribed-companies'
  settings.client.get hUrl, authHead, (data, response) ->
    if data.status == 'error'
      res.status(response.statusCode)
    res.send data

router.get '/:uniqueName/transactions', (req, res) ->
  authHead =
    headers:
      'Auth-Key': req.session.authKey
      'X-Forwarded-For': res.locales.remoteIp
    parameters:
      page: req.query.page
  hUrl = settings.envUrl + 'users/' + req.params.uniqueName + '/transactions'
  settings.client.get hUrl, authHead, (data, response) ->
    if data.status == 'error'
      res.status(response.statusCode)
    res.send data

router.get '/:uniqueName/available-credit', (req, res) ->
  authHead =
    headers:
      'Auth-Key': req.session.authKey
      'X-Forwarded-For': res.locales.remoteIp
  hUrl = settings.envUrl + 'users/' + req.params.uniqueName + '/available-credit'
  settings.client.get hUrl, authHead, (data, response) ->
    if data.status == 'error'
      res.status(response.statusCode)
    res.send data

# delete auto payee self service
router.put '/:uniqueName/delete-payee', (req, res) ->
  authHead =
    headers:
      'Auth-Key': req.session.authKey
      'X-Forwarded-For': res.locales.remoteIp
      'Content-Type': 'application/json'
    data: req.body
  hUrl = settings.envUrl + 'users/' + req.params.uniqueName + '/delete-payee'
  settings.client.put hUrl, authHead, (data, response) ->
    if data.status == 'error'
      res.status(response.statusCode)
    res.send data

# add balance in wallet
router.post '/:uniqueName/balance', (req, res) ->
  hUrl = settings.envUrl + 'users/' + req.params.uniqueName + '/balance'
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

# add mobile number
router.post '/system_admin/verify-number', (req, res) ->
  console.log req.body
  authHead =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
      'X-Forwarded-For': res.locales.remoteIp
    data: req.body
  hUrl = settings.envUrl + 'users/system_admin/verify-number'
  settings.client.post hUrl, authHead, (data, response) ->
    if data.status == 'error'
      res.status(response.statusCode)
    res.send data

# verify mobile number
router.put '/system_admin/verify-number', (req, res) ->
  authHead =
    headers:
      'Auth-Key': req.session.authKey
      'X-Forwarded-For': res.locales.remoteIp
      'Content-Type': 'application/json'
    data: req.body
  hUrl = settings.envUrl + 'users/system_admin/verify-number'
  settings.client.put hUrl, authHead, (data, response) ->
    if data.status == 'error'
      res.status(response.statusCode)
    res.send data

module.exports = router