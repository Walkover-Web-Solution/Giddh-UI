settings = require('../util/settings')
router = settings.express.Router({mergeParams: true})

router.get '/', (req, res) ->
  console.log encodeURIComponent('%')
  authHead =
    headers:
      'Auth-Key': req.session.authKey
      'X-Forwarded-For': res.locales.remoteIp
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName +
      '/accounts'
  settings.client.get hUrl, authHead, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

router.get '/:accountUniqueName', (req, res) ->
  authHead =
    headers:
      'Auth-Key': req.session.authKey
      'X-Forwarded-For': res.locales.remoteIp
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName +
      '/accounts/' + encodeURIComponent(req.params.accountUniqueName)
  settings.client.get hUrl, authHead, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    #console.log res
    res.send data

router.put '/:accountUniqueName', (req, res) ->
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName +
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

router.put '/:accountUniqueName/move', (req, res) ->
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName +
      '/accounts/' + encodeURIComponent(req.params.accountUniqueName) + '/move'
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

router.put '/:accountUniqueName/merge', (req, res) ->
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName +
      '/accounts/' + encodeURIComponent(req.params.accountUniqueName) + '/merge'
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

# router.post '/:accountUniqueName/un-merge', (req, res) ->
#   authHead =
#     headers:
#       'Auth-Key': req.session.authKey
#       'X-Forwarded-For': res.locales.remoteIp
#   hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName +
#       '/accounts/' + req.params.accountUniqueName + '/un-merge'
#   data = req.body
#   settings.client.post hUrl, authHead, (data, response) ->
#     if data.status == 'error'
#       res.status(response.statusCode)
#     res.send data

router.post '/:accountUniqueName/un-merge', (req, res) ->
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName +
      '/accounts/' + encodeURIComponent(req.params.accountUniqueName) + '/un-merge'
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




router.put '/:accountUniqueName/share', (req, res) ->
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName +
      '/accounts/' + encodeURIComponent(req.params.accountUniqueName) + '/share'
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

router.delete '/:accountUniqueName', (req, res) ->
  authHead =
    headers:
      'Auth-Key': req.session.authKey
      'X-Forwarded-For': res.locales.remoteIp
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName +
      '/accounts/' + encodeURIComponent(req.params.accountUniqueName)
  settings.client.delete hUrl, authHead, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

router.get '/:accountUniqueName/shared-with', (req, res) ->
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName +
      '/accounts/' + encodeURIComponent(req.params.accountUniqueName) + '/shared-with'
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
      'X-Forwarded-For': res.locales.remoteIp
  settings.client.get hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

router.put '/:accountUniqueName/unshare', (req, res) ->
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName +
      '/accounts/' + encodeURIComponent(req.params.accountUniqueName) + '/unshare'
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

#map bank transaction
router.put '/:accountUniqueName/eledgers/map/:transactionId', (req, res) ->
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName + '/accounts/' + req.params.accountUniqueName + '/eledgers/' + req.params.transactionId
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

router.get '/:accountUniqueName/export-ledger', (req, res) ->
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName +
      '/accounts/' + encodeURIComponent(req.params.accountUniqueName) + '/v2/export-ledger'
  # if req.query.ltype == 'condensed'
  #   hUrl = hUrl + '-condensed'
  # else
  #   hUrl = hUrl + '-detailed'
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
      'X-Forwarded-For': res.locales.remoteIp
    parameters:
      to: req.query.toDate
      from: req.query.fromDate
      format : req.query.ltype
  settings.client.get hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

# get ledger import list
router.get '/:accountUniqueName/xls-imports', (req, res) ->
  args =
    headers:
      'Auth-Key': req.session.authKey
      'X-Forwarded-For': res.locales.remoteIp
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName +
      '/accounts/' + encodeURIComponent(req.params.accountUniqueName) + '/xls-imports'
  settings.client.get hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

# get eledger transactions
router.get '/:accountUniqueName/eledgers', (req, res) ->
  authHead =
    headers:
      'Auth-Key': req.session.authKey
      'X-Forwarded-For': res.locales.remoteIp
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName +
      '/accounts/' + encodeURIComponent(req.params.accountUniqueName) + '/eledgers'
  settings.client.get hUrl, authHead, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

# trash eLedger transaction
router.delete '/:accountUniqueName/eledgers/:transactionId', (req, res) ->
  authHead =
    headers:
      'Auth-Key': req.session.authKey
      'X-Forwarded-For': res.locales.remoteIp
  hUrl = settings.envUrl + 'eledgers/' + req.params.transactionId
  settings.client.delete hUrl, authHead, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

# mail ledger 
router.post '/:accountUniqueName/mail-ledger', (req, res) ->
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
      'X-Forwarded-For': res.locales.remoteIp
    parameters:
      to: req.query.toDate
      from: req.query.fromDate
      format: req.query.format
    data: req.body

  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName +
      '/accounts/' + encodeURIComponent(req.params.accountUniqueName) + '/mail-ledger'
  settings.client.post hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

# get invoices
router.get '/:accountUniqueName/invoices', (req, res) ->
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName +
      '/accounts/' + encodeURIComponent(req.params.accountUniqueName) + '/invoices'
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
      'X-Forwarded-For': res.locales.remoteIp
    parameters:
      to: req.query.toDate
      from: req.query.fromDate
  settings.client.get hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

# preview Invoice
router.post '/:accountUniqueName/invoices/preview', (req, res) ->
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
      'X-Forwarded-For': res.locales.remoteIp
    data: req.body
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName+'/accounts/' + encodeURIComponent(req.params.accountUniqueName) + '/invoices/preview'
  settings.client.post hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

# Generate Invoice
router.post '/:accountUniqueName/invoices/generate', (req, res) ->
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
      'X-Forwarded-For': res.locales.remoteIp
    data: req.body
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName+'/accounts/' + encodeURIComponent(req.params.accountUniqueName) + '/invoices/generate'
  settings.client.post hUrl, args, (data, response) ->
    # console.log data
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data


# Download Invoice
router.post '/:accountUniqueName/invoices/download', (req, res) ->
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
      'X-Forwarded-For': res.locales.remoteIp
    data: req.body
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName+'/accounts/' + encodeURIComponent(req.params.accountUniqueName) + '/invoices/download'
  settings.client.post hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

# preview of generated invoice
router.get '/:accountUniqueName/invoices/:invoiceUniqueID/preview', (req, res) ->
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName +
      '/accounts/' + encodeURIComponent(req.params.accountUniqueName) + '/invoices/'+req.params.invoiceUniqueID+'/preview'
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
      'X-Forwarded-For': res.locales.remoteIp
  settings.client.get hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

# Sent Invoice by email
router.post '/:accountUniqueName/invoices/mail', (req, res) ->
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
      'X-Forwarded-For': res.locales.remoteIp
    data: req.body
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName+'/accounts/' + encodeURIComponent(req.params.accountUniqueName) + '/invoices/mail'
  settings.client.post hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

# generate magic link
router.post '/:accountUniqueName/magic-link', (req, res) ->
  args =
    headers:
      'Auth-Key': req.session.authKey
      'X-Forwarded-For': res.locales.remoteIp
    parameters:
      to: req.query.to
      from: req.query.from
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName +
      '/accounts/' + encodeURIComponent(req.params.accountUniqueName) + '/magic-link'
  settings.client.post hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

router.get '/:accountUniqueName/tax-hierarchy', (req, res) ->
  hUrl = settings.envUrl + 'company/'+req.params.companyUniqueName + '/accounts/'+ encodeURIComponent(req.params.accountUniqueName) + '/tax-hierarchy'
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
      'X-Forwarded-For': res.locales.remoteIp
  settings.client.get hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data


module.exports = router