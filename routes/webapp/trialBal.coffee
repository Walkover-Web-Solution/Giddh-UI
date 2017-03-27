settings = require('../util/settings')
router = settings.express.Router({mergeParams: true})

#Get trial balance for an account, query params are - fromDate/toDate {dd-mm-yyyy}
router.get '/', (req, res) ->
  args =
    headers:
      'Auth-Key': req.session.authKey
      'X-Forwarded-For': res.locales.remoteIp
    parameters:
      to: req.query.toDate
      from: req.query.fromDate
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName  + '/trial-balance'
  if req.query.refresh == "true"
    args =
      headers:
        'Auth-Key': req.session.authKey
        'X-Forwarded-For': res.locales.remoteIp
      parameters:
        to: req.query.toDate
        from: req.query.fromDate
        refresh: true
  settings.client.get hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

#get balance sheet data
router.get '/balance-sheet', (req, res) ->
  args =
    headers:
      'Auth-Key': req.session.authKey
      'X-Forwarded-For': res.locales.remoteIp
    parameters:
      fy: req.query.fy
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName  + '/balance-sheet'
  if req.query.refresh == "true"
    args =
      headers:
        'Auth-Key': req.session.authKey
        'X-Forwarded-For': res.locales.remoteIp
      parameters:
        fy: req.query.fy
        refresh: true
  settings.client.get hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data 

#get profit loss data
router.get '/profit-loss', (req, res) ->
  args =
    headers:
      'Auth-Key': req.session.authKey
      'X-Forwarded-For': res.locales.remoteIp
    parameters:
      fy: req.query.fy
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName  + '/profit-loss'
  if req.query.refresh == "true"
    args =
      headers:
        'Auth-Key': req.session.authKey
        'X-Forwarded-For': res.locales.remoteIp
      parameters:
        fy: req.query.fy
        refresh: true
  settings.client.get hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data 

module.exports = router