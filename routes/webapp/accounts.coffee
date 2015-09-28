settings = require('../util/settings')
router = settings.express.Router({mergeParams: true})

router.get '/', (req, res) ->
  authHead = headers: 'Auth-Key': req.session.authKey
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName +
      '/groups/' + req.params.groupUniqueName + '/accounts'
  settings.client.get hUrl, authHead, (data) ->
    res.send data

router.get '/:accountUniqueName', (req, res) ->
  authHead = headers: 'Auth-Key': req.session.authKey
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName +
      '/groups/' + req.params.groupUniqueName + '/accounts/' + req.params.accountUniqueName
  settings.client.get hUrl, authHead, (data) ->
    res.send data

router.put '/:accountUniqueName', (req, res) ->
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName +
      '/groups/' + req.params.groupUniqueName + '/accounts/' + req.params.accountUniqueName
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
    data: req.body
  settings.client.put hUrl, args, (data) ->
    console.log data
    res.send data

router.delete '/:accountUniqueName', (req, res) ->
  authHead = headers: 'Auth-Key': req.session.authKey
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName +
      '/groups/' + req.params.groupUniqueName + '/accounts/' + req.params.accountUniqueName
  settings.client.delete hUrl, authHead, (data) ->
    res.send data

router.post '/', (req, res) ->
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName +
      '/groups/' + req.params.groupUniqueName + '/accounts'
  req.body.uniqueName = settings.stringUtil.getRandomString(req.body.name, req.params.companyUniqueName)
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
    data: req.body
  settings.client.post hUrl, args, (data) ->
    res.send data

module.exports = router