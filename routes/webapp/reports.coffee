settings = require('../util/settings')
router = settings.express.Router({mergeParams: true})

router.post '/history', (req, res) ->
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
      'X-Forwarded-For': res.locales.remoteIp
    parameters:
      to: req.query.toDate
      from: req.query.fromDate
      interval: req.query.interval
    data: req.body
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName +
          '/history'
  settings.client.post hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

router.post '/group-history', (req, res) ->
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
      'X-Forwarded-For': res.locales.remoteIp
    parameters:
      to: req.query.toDate
      from: req.query.fromDate
      interval: req.query.interval
    data: req.body
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName +
      '/group-history'
  settings.client.post hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

router.get '/profit-loss-history', (req, res) ->
  authHead = 
    headers:
      'Auth-Key': req.session.authKey
      'X-Forwarded-For': res.locales.remoteIp
    parameters:
      to: req.query.toDate
      from: req.query.fromDate
      interval: req.query.interval 
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName + '/profit-loss-history'
  settings.client.get hUrl, authHead, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

router.get '/profit-loss', (req, res) ->
  authHead =
    headers:
      'Auth-Key': req.session.authKey
      'X-Forwarded-For': res.locales.remoteIp
    parameters:
      to: req.query.toDate
      from: req.query.fromDate
      interval: req.query.interval
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName + '/profit-loss'
  settings.client.get hUrl, authHead, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

router.get '/networth-history', (req, res) ->
  authHead = 
    headers:
      'Auth-Key': req.session.authKey
      'X-Forwarded-For': res.locales.remoteIp
    parameters:
      to: req.query.toDate
      from: req.query.fromDate
      interval: req.query.interval 
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName + '/networth-history'
  settings.client.get hUrl, authHead, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

router.get '/networth', (req, res) ->
  authHead =
    headers:
      'Auth-Key': req.session.authKey
      'X-Forwarded-For': res.locales.remoteIp
    parameters:
      to: req.query.toDate
      from: req.query.fromDate
      interval: req.query.interval
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName + '/networth'
  settings.client.get hUrl, authHead, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

router.get '/sms-key', (req, res) ->
  authHead = 
    headers:
      'Auth-Key': req.session.authKey
      'X-Forwarded-For': res.locales.remoteIp 
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName + '/sms-key'
  settings.client.get hUrl, authHead, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

router.get '/email-key', (req, res) ->
  authHead = 
    headers:
      'Auth-Key': req.session.authKey
      'X-Forwarded-For': res.locales.remoteIp
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName + '/email-key'
  settings.client.get hUrl, authHead, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

router.get '/financial-year', (req, res) ->
  authHead = 
    headers:
      'Auth-Key': req.session.authKey
      'X-Forwarded-For': res.locales.remoteIp
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName + '/financial-year'
  settings.client.get hUrl, authHead, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

router.put '/financial-year', (req, res) ->
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
      'X-Forwarded-For': res.locales.remoteIp
    data: req.body
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName + '/financial-year'
  settings.client.put hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

router.post '/financial-year', (req, res) ->
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
      'X-Forwarded-For': res.locales.remoteIp
    data: req.body
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName + '/financial-year'
  settings.client.post hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

router.patch '/active-financial-year', (req, res) ->
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
      'X-Forwarded-For': res.locales.remoteIp
    data: req.body
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName + '/active-financial-year'
  settings.client.patch hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

router.patch '/financial-year-lock', (req, res) ->
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
      'X-Forwarded-For': res.locales.remoteIp
    data: req.body
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName + '/financial-year-lock'
  settings.client.patch hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

router.patch '/financial-year-unlock', (req, res) ->
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
      'X-Forwarded-For': res.locales.remoteIp
    data: req.body
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName + '/financial-year-unlock'
  settings.client.patch hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

router.post '/sms-key', (req, res) ->
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
      'X-Forwarded-For': res.locales.remoteIp
    data: req.body
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName +
      '/sms-key'
  settings.client.post hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

router.post '/email-key', (req, res) ->
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
      'X-Forwarded-For': res.locales.remoteIp
    data: req.body
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName +
      '/email-key'
  settings.client.post hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

router.post '/accounts/bulk-sms', (req, res) ->
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
      'X-Forwarded-For': res.locales.remoteIp
    data: req.body
    parameters:
      to:req.query.to
      from:req.query.from
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName +
      '/accounts/bulk-sms'
  settings.client.post hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

router.post '/accounts/bulk-email', (req, res) ->
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
      'X-Forwarded-For': res.locales.remoteIp
    data: req.body
    parameters:
      to:req.query.to
      from:req.query.from
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName +
      '/accounts/bulk-email'
  settings.client.post hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data


router.post '/subgroups-with-accounts', (req, res) ->
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName + '/groups-with-accounts'
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

# update generated invoice
router.put '/invoices', (req, res) ->
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
      'X-Forwarded-For': res.locales.remoteIp
    data: req.body
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName + '/invoices'
  settings.client.put hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

router.post '/tax/assign', (req,res) ->
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
      'X-Forwarded-For': res.locales.remoteIp
    data: req.body
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName + '/tax/assign'
  settings.client.post hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

router.put '/invoice-setting', (req, res) ->
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
      'X-Forwarded-For': res.locales.remoteIp
    data: req.body
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName + '/invoice-setting'
  settings.client.put hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data



module.exports = router