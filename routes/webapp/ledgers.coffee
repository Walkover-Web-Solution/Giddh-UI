settings = require('../util/settings')
router = settings.express.Router({mergeParams: true})

#Get all ledgers for an account, query params are - fromDate/toDate {dd-mm-yyyy}
router.get '/', (req, res) ->
  console.log req.query, "get all ledgers by date", new Date()
  args =
    headers:
      'Auth-Key': req.session.authKey
    parameters:
      to: req.query.toDate
      from: req.query.fromDate
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName +
      '/groups/' + req.params.groupUniqueName + '/accounts/' + req.params.accountUniqueName + '/ledgers'
  settings.client.get hUrl, args, (data, response) ->
    console.log new Date(), "req completed", data
    if data.status == 'error'
      res.status(response.statusCode)
    res.send data

#Delete all ledgers of an account
router.delete '/', (req, res) ->
  authHead =
    headers:
      'Auth-Key': req.session.authKey
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName +
      '/groups/' + req.params.groupUniqueName + '/accounts/' + req.params.accountUniqueName + '/ledgers'
  settings.client.delete hUrl, authHead, (data, response) ->
    if data.status == 'error'
      res.status(response.statusCode)
    res.send data

#Get ledgers
router.get '/:ledgerUniqueName', (req, res) ->
  authHead =
    headers:
      'Auth-Key': req.session.authKey
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName +
      '/groups/' + req.params.groupUniqueName + '/accounts/' + req.params.accountUniqueName +
      '/ledgers/' + req.params.ledgerUniqueName
  settings.client.get hUrl, authHead, (data, response) ->
    if data.status == 'error'
      res.status(response.statusCode)
    res.send data

#Create ledgers
router.post '/', (req, res) ->
  console.log "in create ledgers"
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName +
      '/groups/' + req.params.groupUniqueName + '/accounts/' + req.params.accountUniqueName + '/ledgers'
  req.body.uniqueName = settings.stringUtil.getRandomString(req.params.accountUniqueName, req.params.companyUniqueName)
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
    data: req.body

  console.log args, "args"
  settings.client.post hUrl, args, (data, response) ->
    if data.status == 'error'
      res.status(response.statusCode)
    res.send data
    
#Update ledgers
router.put '/:ledgerUniqueName', (req, res) ->
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName +
      '/groups/' + req.params.groupUniqueName + '/accounts/' + req.params.accountUniqueName +
      '/ledgers/' + req.params.ledgerUniqueName
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
    data: req.body
  settings.client.put hUrl, args, (data, response) ->
    if data.status == 'error'
      res.status(response.statusCode)
    res.send data

#Delete ledgers
router.delete '/:ledgerUniqueName', (req, res) ->
  authHead =
    headers:
      'Auth-Key': req.session.authKey
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName +
      '/groups/' + req.params.groupUniqueName + '/accounts/' + req.params.accountUniqueName +
      '/ledgers/' + req.params.ledgerUniqueName
  settings.client.delete hUrl, authHead, (data, response) ->
    if data.status == 'error'
      res.status(response.statusCode)
    res.send data


module.exports = router