settings = require('../util/settings')
router = settings.express.Router({mergeParams: true})

router.get '/', (req, res) ->
  authHead = headers:
    'Auth-Key': req.session.authKey
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName + '/groups'
  settings.client.get hUrl, authHead, (data, response) ->
    if data.status == 'error'
      res.status(response.statusCode)
    res.send data

router.get '/with-accounts', (req, res) ->
  authHead = headers:
    'Auth-Key': req.session.authKey
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName + '/groups-with-accounts'
  settings.client.get hUrl, authHead, (data, response) ->
    if data.status == 'error'
      res.status(response.statusCode)
    res.send data

router.put '/:groupUniqueName', (req, res) ->
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName + '/groups/' + req.params.groupUniqueName
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
    data: req.body
  settings.client.put hUrl, args, (data, response) ->
    if data.status == 'error'
      res.status(response.statusCode)
    res.send data

router.put '/:groupUniqueName/move', (req, res) ->
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName + '/groups/' + req.params.groupUniqueName + '/move'
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
    data: req.body
  settings.client.put hUrl, args, (data, response) ->
    if data.status == 'error'
      res.status(response.statusCode)
    res.send data

router.put '/:groupUniqueName/share', (req, res) ->
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName + '/groups/' + req.params.groupUniqueName + '/share'
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
    data: req.body
  settings.client.put hUrl, args, (data, response) ->
    if data.status == 'error'
      res.status(response.statusCode)
    res.send data

router.put '/:groupUniqueName/unshare', (req, res) ->
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName + '/groups/' + req.params.groupUniqueName + '/unshare'
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
    data: req.body
  settings.client.put hUrl, args, (data, response) ->
    if data.status == 'error'
      res.status(response.statusCode)
    res.send data


router.get '/:groupUniqueName/shared-with', (req, res) ->
  console.log "in list of shared-with", req.params
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName + '/groups/' + req.params.groupUniqueName + '/shared-with'
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'

  settings.client.get hUrl, args, (data, response) ->
    if data.status == 'error'
      res.status(response.statusCode)
    res.send data



router.delete '/:groupUniqueName', (req, res) ->
  console.log req.session.authKey
  authHead = headers:
    'Auth-Key': req.session.authKey
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName + '/groups/' + req.params.groupUniqueName
  settings.client.delete hUrl, authHead, (data, response) ->
    if data.status == 'error'
      res.status(response.statusCode)
    res.send data

router.post '/', (req, res) ->
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName + '/groups'
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
    data: req.body
  settings.client.post hUrl, args, (data, response) ->
    if data.status == 'error'
      res.status(response.statusCode)
    res.send data

module.exports = router