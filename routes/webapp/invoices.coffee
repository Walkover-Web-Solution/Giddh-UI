settings = require('../util/settings')
router = settings.express.Router({mergeParams: true})

router.post '/', (req, res) ->
  abc = req.params.companyUniqueName + '/invoices?from='+req.query.from+'&to='+req.query.to + '&count=' + req.query.count + '&page=' + req.query.page
  str = settings.envUrl+ 'company/' + abc
  args =
    headers:
      'Auth-Key': req.session.authKey
      'X-Forwarded-For': res.locales.remoteIp
      'Content-Type': 'application/json'
    data: req.body
  settings.client.post str, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

router.post '/bulk-generate', (req, res) ->
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName + '/invoices/bulk-generate?combined=' + req.query.combined
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

router.post '/ledgers', (req, res) ->
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName + '/ledgers?from=' + req.query.from + '&to=' + req.query.to + '&count=' + req.query.count + '&page=' + req.query.page
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

# get all proforma
router.get '/proforma/all', (req, res) ->
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName + '/proforma/list?from=' + req.query.from + '&to=' + req.query.to + '&page=' + req.query.page + '&count=' + req.query.count
  hUrl = ""
  if req.body.fromDate == undefined && req.body.toDate != undefined
    hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName + '/proforma/list?to=' + req.query.to + '&page=' + req.query.page + '&count=' + req.query.count
  else if req.body.toDate == undefined && req.body.fromDate != undefined
    hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName + '/proforma/list?from=' + req.query.from + '&page=' + req.query.page + '&count=' + req.query.count
  else if req.body.toDate == undefined && req.body.fromDate == undefined
    hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName + '/proforma/list?page=' + req.query.page + '&count=' + req.query.count
  else
    hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName + '/proforma/list?from=' + req.query.from + '&to=' + req.query.to + '&page=' + req.query.page + '&count=' + req.query.count
  args =
    headers:
      'Auth-Key': req.session.authKey
      'X-Forwarded-For': res.locales.remoteIp
      'Content-Type': 'application/json'
  settings.client.get hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

router.post '/action', (req, res) ->
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName + '/invoices/' + req.query.invoiceUniqueName + '/action'
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


router.post '/proforma/all', (req, res) ->
  hUrl = ""
  if req.body.fromDate == undefined && req.body.toDate != undefined
    hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName + '/proforma/list?to=' + req.body.toDate + '&page=' + req.body.page + '&count=' + req.body.count
  else if req.body.toDate == undefined && req.body.fromDate != undefined
    hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName + '/proforma/list?from=' + req.body.fromDate + '&page=' + req.body.page + '&count=' + req.body.count
  else if req.body.toDate == undefined && req.body.fromDate == undefined
    hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName + '/proforma/list?page=' + req.body.page + '&count=' + req.body.count
  else
    hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName + '/proforma/list?from=' + req.body.fromDate + '&to=' + req.body.toDate + '&page=' + req.body.page + '&count=' + req.body.count

  args =
    headers:
      'Auth-Key': req.session.authKey
      'X-Forwarded-For': res.locales.remoteIp
      'Content-Type': 'application/json'
    data: req.body
  console.log(hUrl)
  settings.client.post hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

router.delete '/proforma/delete', (req, res) ->
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName + '/proforma/' + req.query.proforma
  args =
    headers:
      'Auth-Key': req.session.authKey
      'X-Forwarded-For': res.locales.remoteIp
      'Content-Type': 'application/json'
  settings.client.delete hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

router.post '/proforma/updateBalanceStatus', (req, res) ->
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName + '/proforma/' + req.body.proformaUniqueName + '/action'
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

router.post '/proforma/link-account', (req, res) ->
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName + '/proforma/' + req.body.proformaUniqueName + '/link-account'
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

router.post '/proforma', (req, res) ->
  console.log req.body
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName + '/proforma'
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

router.put '/proforma/update', (req, res) ->
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName + '/proforma/' + req.body.proforma
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

router.get '/proforma/templates', (req, res) ->
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName + '/templates/all'
  args =
    headers:
      'Auth-Key': req.session.authKey
      'X-Forwarded-For': res.locales.remoteIp
      'Content-Type': 'application/json'
  settings.client.get hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

router.post '/proforma/get', (req, res) ->
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName + '/proforma/' + req.body.proforma 
  args =
    headers:
      'Auth-Key': req.session.authKey
      'X-Forwarded-For': res.locales.remoteIp
      'Content-Type': 'application/json'
  settings.client.get hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

router.post '/proforma/mail', (req, res) ->
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName + '/proforma/mail'
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

router.post '/proforma/download', (req, res) ->
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName + '/proforma/download'
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

router.put '/proforma/templates/default', (req, res) ->
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName + '/templates/'+ req.body.templateUniqueName + '/default'
  console.log hUrl
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


module.exports = router