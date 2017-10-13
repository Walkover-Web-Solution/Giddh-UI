settings = require('../util/settings')
router = settings.express.Router({mergeParams: true})

router.get '/accounts/:accountUniqueName', (req, res) ->
  authHead =
    headers:
      'Auth-Key': req.session.authKey
      'X-Forwarded-For': res.locales.remoteIp
  hUrl = settings.envUrl + 'v2/company/' + req.params.companyUniqueName +
      '/accounts/' + encodeURIComponent(req.params.accountUniqueName)
  settings.client.get hUrl, authHead, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    #console.log res
    res.send data

router.put '/accounts/:accountUniqueName', (req, res) ->
  hUrl = settings.envUrl + 'v2/company/' + req.params.companyUniqueName +
      '/accounts/' + encodeURIComponent(req.params.accountUniqueName)
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
      'X-Forwarded-For': res.locales.remoteIp
    data: req.body
  settings.client.put hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

router.post '/groups/:groupUniqueName/accounts', (req, res) ->
  hUrl = settings.envUrl + 'v2/company/' + req.params.companyUniqueName + '/groups/' + req.params.groupUniqueName + '/accounts'
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
      'X-Forwarded-For': res.locales.remoteIp
    data: req.body
  settings.client.post hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

module.exports = router