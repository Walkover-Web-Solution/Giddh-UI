settings = require('../util/settings')
router = settings.express.Router()

router.get '/:uniqueName', (req, res) ->
  authHead =
    headers:
      'Auth-Key': req.session.authKey
      'X-Forwarded-For': res.locales.remoteIp
  hUrl = settings.envUrl + 'users/' + req.params.uniqueName
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
  hUrl = settings.envUrl + 'users/' + req.params.uniqueName + '/transactions'
  settings.client.get hUrl, authHead, (data, response) ->
    if data.status == 'error'
      res.status(response.statusCode)
    res.send data

module.exports = router