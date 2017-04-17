settings = require('../util/settings')
router = settings.express.Router({mergeParams: true})

#Get all ledgers for an account, query params are - fromDate/toDate {dd-mm-yyyy}
router.get '/', (req, res) ->
  args =
    headers:
      'Auth-Key': req.session.authKey
      'X-Forwarded-For': res.locales.remoteIp
    parameters:
      to: req.query.toDate
      from: req.query.fromDate
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName +
      '/accounts/' + encodeURIComponent(req.params.accountUniqueName) + '/ledgers'
  settings.client.get hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

#Delete all ledgers of an account
router.delete '/', (req, res) ->
  authHead =
    headers:
      'Auth-Key': req.session.authKey
      'X-Forwarded-For': res.locales.remoteIp
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName +
      '/accounts/' + req.params.accountUniqueName + '/ledgers'
  settings.client.delete hUrl, authHead, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

#download invoice attachement
router.get '/invoice-file', (req, res) ->
  args =
    headers:
      'Auth-Key': req.session.authKey
      'X-Forwarded-For': res.locales.remoteIp
    parameters:
      to: req.query.toDate
      from: req.query.fromDate
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName + '/ledger/upload/' + req.query.fileName
  settings.client.get hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

#get reconciled entries
router.get '/reconcile', (req, res) ->
  authHead =
    headers:
      'Auth-Key': req.session.authKey
      'X-Forwarded-For': res.locales.remoteIp
    parameters:
      to: req.query.to
      from: req.query.from
      chequeNumber:req.query.chequeNumber || ''
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName +
      '/accounts/' + req.params.accountUniqueName + '/ledgers/reconcile'
  settings.client.get hUrl, authHead, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

#Get ledgers
router.get '/:ledgerUniqueName', (req, res) ->
  authHead =
    headers:
      'Auth-Key': req.session.authKey
      'X-Forwarded-For': res.locales.remoteIp
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName +
      '/accounts/' + req.params.accountUniqueName + '/ledgers/' + req.params.ledgerUniqueName
  settings.client.get hUrl, authHead, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

#Create ledgers
router.post '/', (req, res) ->
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName +
      '/accounts/' + req.params.accountUniqueName + '/ledgers'
  req.body.uniqueName = settings.stringUtil.getRandomString(req.params.accountUniqueName, req.params.companyUniqueName)
  args =
    headers:
      'Auth-Key': req.session.authKey
      'X-Forwarded-For': res.locales.remoteIp
      'Content-Type': 'application/json'
    data: req.body
  settings.client.post hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data
    
#Update ledgers
router.put '/:ledgerUniqueName', (req, res) ->
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName +
      '/accounts/' + req.params.accountUniqueName + '/ledgers/' + req.params.ledgerUniqueName
  args =
    headers:
      'Auth-Key': req.session.authKey
      'X-Forwarded-For': res.locales.remoteIp
      'Content-Type': 'application/json'
    data: req.body
  settings.client.put hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

#Delete ledgers
router.delete '/:ledgerUniqueName', (req, res) ->
  authHead =
    headers:
      'Auth-Key': req.session.authKey
      'X-Forwarded-For': res.locales.remoteIp
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName +
      '/accounts/' + req.params.accountUniqueName + '/ledgers/' + req.params.ledgerUniqueName
  settings.client.delete hUrl, authHead, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

router.post '/paymentTransactions', (req, res) ->
  authHead =
    headers:
      'Auth-Key': req.session.authKey
      'X-Forwarded-For': res.locales.remoteIp
    data: req.body
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName +
      '/accounts/' + req.params.accountUniqueName + '/ledgers/paymentTransactions'
  settings.client.post hUrl, authHead, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data


    
module.exports = router