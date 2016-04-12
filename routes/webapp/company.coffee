settings = require('../util/settings')
router = settings.express.Router()

router.get '/all', (req, res) ->
  args =
    headers:
      'Auth-Key': req.session.authKey
      'X-Forwarded-For': res.locales.remoteIp
  hUrl = settings.envUrl + 'users/' + req.session.name + '/companies'
  settings.client.get hUrl, args, (data, response) ->
    if data.status == 'error'
      res.status(response.statusCode)
    res.send data

#delete company
router.delete '/:uniqueName', (req, res) ->
  hUrl = settings.envUrl + 'company/' + req.params.uniqueName
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
      'X-Forwarded-For': res.locales.remoteIp
  settings.client.delete hUrl, args, (data, response) ->
    if data.status == 'error'
      res.status(response.statusCode)
    res.send data

#update company
router.put '/:uniqueName', (req, res) ->
  hUrl = settings.envUrl + 'company/' + req.params.uniqueName
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

router.get '/:uniqueName/imports', (req, res) ->
  hUrl = settings.envUrl + 'company/' + req.params.uniqueName+ '/imports'
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
      'X-Forwarded-For': res.locales.remoteIp
  settings.client.get hUrl, args, (data, response) ->
    if data.status == 'error'
      res.status(response.statusCode)
    res.send data

router.post '/', (req, res) ->
  hUrl = settings.envUrl + 'company/'
  req.body.uniqueName = settings.stringUtil.getRandomString(req.body.name, req.body.city)
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

#get all Roles
router.get '/:uniqueName/shareable-roles', (req, res) ->
  hUrl = settings.envUrl + 'company/' + req.params.uniqueName + '/shareable-roles'
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
      'X-Forwarded-For': res.locales.remoteIp
  settings.client.get hUrl, args, (data, response) ->
    if data.status == 'error'
      res.status(response.statusCode).send(data)
    else
      res.send data

#get company Shared user list
router.get '/:uniqueName/shared-with', (req, res) ->
  hUrl = settings.envUrl + 'company/' + req.params.uniqueName + '/shared-with'
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
      'X-Forwarded-For': res.locales.remoteIp
  settings.client.get hUrl, args, (data, response) ->
    if data.status == 'error'
      res.status(response.statusCode).send(data)
    else
      res.send data

#share company with user
router.put '/:uniqueName/share', (req, res) ->
  hUrl = settings.envUrl + 'company/' + req.params.uniqueName + '/share'
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
      'X-Forwarded-For': res.locales.remoteIp
    data: req.body
  settings.client.put hUrl, args, (data, response) ->
    if data.status == 'error'
      res.status(response.statusCode).send(data)
    else
      res.send data

#unShare company with user
router.put '/:uniqueName/unshare', (req, res) ->
  hUrl = settings.envUrl + 'company/' + req.params.uniqueName + '/unshare'
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
      'X-Forwarded-For': res.locales.remoteIp
    data: req.body
  settings.client.put hUrl, args, (data, response) ->
    if data.status == 'error'
      res.status(response.statusCode).send(data)
    else
      res.send data

#get company transaction list
router.get '/:uniqueName/transactions', (req, res) ->
  hUrl = settings.envUrl + 'company/' + req.params.uniqueName + '/transactions'
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
      'X-Forwarded-For': res.locales.remoteIp
    parameters:
      page: req.query.page
  settings.client.get hUrl, args, (data, response) ->
    if data.status == 'error'
      res.status(response.statusCode).send(data)
    else
      res.send data

#update company subscription
router.put '/:uniqueName/subscription-update', (req, res) ->
  hUrl = settings.envUrl + 'company/' + req.params.uniqueName + '/subscription-update'
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

#pay bill via wallet
router.post '/:uniqueName/pay-via-wallet', (req, res) ->
  hUrl = settings.envUrl + 'company/' + req.params.uniqueName + '/pay-via-wallet'
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

# verify MFA
router.post '/:companyUniqueName/ebanks/:ItemAccountId/verify-mfa', (req, res) ->
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName + '/ebanks/'+req.params.ItemAccountId+'/verify-mfa'
  authHead =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
      'X-Forwarded-For': res.locales.remoteIp
    data: req.body
  settings.client.post hUrl, authHead, (data, response) ->
    if data.status == 'error'
      res.status(response.statusCode)
    res.send data

#get added ebanks list
router.get '/:companyUniqueName/ebanks', (req, res) ->
  authHead =
    headers:
      'Auth-Key': req.session.authKey
      'X-Forwarded-For': res.locales.remoteIp
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName + '/ebanks'
  settings.client.get hUrl, authHead, (data, response) ->
    if data.status == 'error'
      res.status(response.statusCode)
    res.send data

#refresh added banks list
router.get '/:companyUniqueName/ebanks', (req, res) ->
  authHead =
    headers:
      'Auth-Key': req.session.authKey
      'X-Forwarded-For': res.locales.remoteIp
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName + '/ebanks' + req.params.refresh
  settings.client.get hUrl, authHead, (data, response) ->
    if data.status == 'error'
      res.status(response.statusCode)
    res.send data

#login to ebank

router.delete '/:companyUniqueName/ebanks/:memSiteAccId/remove', (req, res) ->
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName + '/ebanks/' + req.params.memSiteAccId + '/remove'
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
      'X-Forwarded-For': res.locales.remoteIp
  settings.client.delete hUrl, args, (data, response) ->
    if data.status == 'error'
      res.status(response.statusCode)
    res.send data


router.post '/:companyUniqueName/ebanks', (req, res) ->
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName + '/ebanks'
  authHead =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
      'X-Forwarded-For': res.locales.remoteIp
    data: req.body
  settings.client.post hUrl, authHead, (data, response) ->

    if data.status == 'error'
      res.status(response.statusCode)
    res.send data

router.delete '/:companyUniqueName/ebanks/:ItemAccountId/:linkedAccount', (req, res) ->
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName + '/ebanks/' + req.params.ItemAccountId + '/?linkedAccount=' + req.params.linkedAccount
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
      'X-Forwarded-For': res.locales.remoteIp
    data: req.body
  settings.client.delete hUrl, args, (data, response) ->
    if data.status == 'error'
      res.status(response.statusCode)
    res.send data

router.put '/:companyUniqueName/ebanks/:ItemAccountId', (req, res) ->
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName + '/ebanks/' + req.params.ItemAccountId
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

router.put '/:companyUniqueName/ebanks/:ItemAccountId/eledgers/:date', (req, res) ->
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName + '/ebanks/' + req.params.ItemAccountId + '/eledgers?from=' + req.params.date
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

# retry upload tally xml master
router.put '/:uniqueName/retry', (req, res) ->
  hUrl = settings.envUrl + 'company/' + req.params.uniqueName+ '/imports/'+req.body.requestId+'/retry'
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
      'X-Forwarded-For': res.locales.remoteIp
  settings.client.put hUrl, args, (data, response) ->
    if data.status == 'error'
      res.status(response.statusCode)
    res.send data

# switch user
router.GET '/:uniqueName/switchUser', (req, res) ->
  hUrl = settings.envUrl + 'company/' + req.params.uniqueName
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
      'X-Forwarded-For': res.locales.remoteIp
  settings.client.patch hUrl, args, (data, response) ->
    if data.status == 'error'
      res.status(response.statusCode)
    res.send data


module.exports = router