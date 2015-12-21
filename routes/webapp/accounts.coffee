settings = require('../util/settings')
router = settings.express.Router({mergeParams: true})

router.get '/', (req, res) ->
  authHead =
    headers:
      'Auth-Key': req.session.authKey
      'X-Forwarded-For': res.locales.remoteIp
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName +
      '/groups/' + req.params.groupUniqueName + '/accounts'
  settings.client.get hUrl, authHead, (data, response) ->
    if data.status == 'error'
      res.status(response.statusCode)
    res.send data

router.get '/:accountUniqueName', (req, res) ->
  authHead =
    headers:
      'Auth-Key': req.session.authKey
      'X-Forwarded-For': res.locales.remoteIp
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName +
      '/groups/' + req.params.groupUniqueName + '/accounts/' + req.params.accountUniqueName
  settings.client.get hUrl, authHead, (data, response) ->
    if data.status == 'error'
      res.status(response.statusCode)
    res.send data

router.put '/:accountUniqueName', (req, res) ->
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName +
      '/groups/' + req.params.groupUniqueName + '/accounts/' + req.params.accountUniqueName
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
      'X-Forwarded-For': res.locales.remoteIp
    data: req.body
  settings.client.put hUrl, args, (data, response) ->
    if data.status == 'error'
      res.status(response.statusCode)
    res.send data

router.put '/:accountUniqueName/move', (req, res) ->
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName +
      '/groups/' + req.params.groupUniqueName + '/accounts/' + req.params.accountUniqueName + '/move'
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
      'X-Forwarded-For': res.locales.remoteIp
    data: req.body
  settings.client.put hUrl, args, (data, response) ->
    if data.status == 'error'
      res.status(response.statusCode)
    res.send data

router.put '/:accountUniqueName/share', (req, res) ->
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName +
      '/groups/' + req.params.groupUniqueName + '/accounts/' + req.params.accountUniqueName + '/share'
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
      'X-Forwarded-For': res.locales.remoteIp
    data: req.body
  settings.client.put hUrl, args, (data, response) ->
    if data.status == 'error'
      res.status(response.statusCode)
    res.send data

router.delete '/:accountUniqueName', (req, res) ->
  authHead =
    headers:
      'Auth-Key': req.session.authKey
      'X-Forwarded-For': res.locales.remoteIp
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName +
      '/groups/' + req.params.groupUniqueName + '/accounts/' + req.params.accountUniqueName
  settings.client.delete hUrl, authHead, (data, response) ->
    if data.status == 'error'
      res.status(response.statusCode)
    res.send data

router.post '/', (req, res) ->
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName +
      '/groups/' + req.params.groupUniqueName + '/accounts'
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
      'X-Forwarded-For': res.locales.remoteIp
    data: req.body
  settings.client.post hUrl, args, (data, response) ->
    if data.status == 'error'
      res.status(response.statusCode)
    res.send data

router.get '/:accountUniqueName/shared-with', (req, res) ->
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName +
      '/groups/' + req.params.groupUniqueName + '/accounts/' + req.params.accountUniqueName + '/shared-with'
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
      'X-Forwarded-For': res.locales.remoteIp
  settings.client.get hUrl, args, (data, response) ->
    if data.status == 'error'
      res.status(response.statusCode)
    res.send data

router.put '/:accountUniqueName/unshare', (req, res) ->
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName +
      '/groups/' + req.params.groupUniqueName + '/accounts/' + req.params.accountUniqueName + '/unshare'
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
      'X-Forwarded-For': res.locales.remoteIp
    data: req.body
  settings.client.put hUrl, args, (data, response) ->
    if data.status == 'error'
      res.status(response.statusCode)
    res.send data

router.get '/:accountUniqueName/export-ledger', (req, res) ->
  console.log req.query, "ledgers export by date", new Date()
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName +
      '/groups/' + req.params.groupUniqueName + '/accounts/' + req.params.accountUniqueName + '/export-ledger'
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
      'X-Forwarded-For': res.locales.remoteIp
    parameters:
      to: req.query.fromDate
      from: req.query.toDate
  console.log args, hUrl
  settings.client.get hUrl, args, (data, response) ->
    console.log "ledgers export by date completed", new Date()
    if data.status == 'error'
      res.status(response.statusCode)
    res.send data

module.exports = router