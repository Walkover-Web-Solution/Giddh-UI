settings = require('../util/settings')
router = settings.express.Router({mergeParams: true})

router.get '/', (req, res) ->
  authHead = headers: 'Auth-Key': req.session.authKey
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName + '/groups'
  settings.client.get hUrl, authHead, (data) ->
    res.send data

router.get '/with-accounts', (req, res) ->
  authHead = headers: 'Auth-Key': req.session.authKey
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName + '/groups-with-accounts'
  settings.client.get hUrl, authHead, (data) ->
    res.send data

router.put '/:groupUniqueName', (req, res) ->
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName + '/groups/' + req.params.groupUniqueName
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
    data: req.body
  settings.client.put hUrl, args, (data) ->
    console.log data
    res.send data

router.delete '/:groupUniqueName', (req, res) ->
  authHead = headers: 'Auth-Key': req.session.authKey
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName + '/groups/' + req.params.groupUniqueName
  settings.client.delete hUrl, authHead, (data) ->
    res.send data

router.post '/', (req, res) ->
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName + '/groups'
  req.body.uniqueName = settings.stringUtil.getRandomString(req.body.name, req.params.companyUniqueName)
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
    data: req.body
  settings.client.post hUrl, args, (data) ->
    res.send data

module.exports = router