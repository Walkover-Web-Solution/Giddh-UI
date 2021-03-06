settings = require('../util/settings')
app = settings.express()
router = settings.express.Router()

env = app.get('env')

hitViaSocket = (data) ->
  data = JSON.stringify(data)
  data.environment = app.get('env')
  if env == "PRODUCTION" || env == "production"
    settings.request {
      url: 'https://viasocket.com/t/JUXDVNwBZ6dgPacX9zT/giddh-giddh-new-company?authkey=MbK1oT6x1RCoVf2AqL3y'
      qs:
        from: 'Giddh'
        time: +new Date
      method: 'POST'
      headers:
        'Content-Type': 'application/json'
        'Auth-Key': 'MbK1oT6x1RCoVf2AqL3y'
      body: data
    }, (error, response, body) ->
      if error
        console.log error
      else
        console.log response.statusCode, body, 'from viasocket'
      return
  else
    console.log("not hitting via socket because we are in ", env)

router.get '/states', (req, res) ->
  args =
    headers:
      'X-Forwarded-For': res.locales.remoteIp
  hUrl = settings.envUrl + 'states'
  settings.client.get hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data


router.get '/all', (req, res) ->
  args =
    headers:
      'Auth-Key': req.session.authKey
      'X-Forwarded-For': res.locales.remoteIp
  hUrl = settings.envUrl + 'users/' + req.session.name + '/companies'
  settings.client.get hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
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
    if data.status == 'error' || data.status == undefined
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
    if data.status == 'error' || data.status == undefined
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
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

router.get '/:companyUniqueName/users', (req, res) ->
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName+ '/users'
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
      'X-Forwarded-For': res.locales.remoteIp
  settings.client.get hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
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
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    else
      hitViaSocket(data)
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
    if data.status == 'error' || data.status == undefined
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
    if data.status == 'error' || data.status == undefined
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
    if data.status == 'error' || data.status == undefined
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
    if data.status == 'error' || data.status == undefined
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
    if data.status == 'error' || data.status == undefined
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
    if data.status == 'error' || data.status == undefined
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
    if data.status == 'error' || data.status == undefined
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
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

router.post '/:companyUniqueName/invoice-setting/verify-email', (req, res) ->
  res.sendFile(__dirname + '/public/website/views/verify-email.html')

#get added ebanks list
router.get '/:companyUniqueName/ebanks', (req, res) ->
  authHead =
    headers:
      'Auth-Key': req.session.authKey
      'X-Forwarded-For': res.locales.remoteIp
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName + '/ebanks'
  settings.client.get hUrl, authHead, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

#refresh added banks list
router.get '/:companyUniqueName/ebanks/refresh', (req, res) ->
  authHead =
    headers:
      'Auth-Key': req.session.authKey
      'X-Forwarded-For': res.locales.remoteIp
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName + '/ebanks/refresh'
  settings.client.get hUrl, authHead, (data, response) ->
    if data.status == 'error' || data.status == undefined
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
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

router.delete '/:companyUniqueName/ebanks/:ItemAccountId/unlink', (req,res) ->
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName + '/ebanks/' + req.params.ItemAccountId + '/unlink'
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
      'X-Forwarded-For': res.locales.remoteIp
  settings.client.delete hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
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

    if data.status == 'error' || data.status == undefined
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
    if data.status == 'error' || data.status == undefined
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
    if data.status == 'error' || data.status == undefined
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
    if data.status == 'error' || data.status == undefined
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
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

# switch user
#get audit logs
router.post '/:companyUniqueName/logs/:page', (req, res) ->
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName + '/logs' + '?page=' + req.params.page
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
      'X-Forwarded-For': res.locales.remoteIp
    data: req.body
  settings.client.post hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode).send(data)
    else
      res.send data

#refresh-token
router.get '/:companyUniqueName/login/:loginId/token/refresh', (req, res) ->
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName + '/login/' + req.params.loginId + '/token/refresh'
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
      'X-Forwarded-For': res.locales.remoteIp
  settings.client.get hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

#refresh-token
router.get '/:companyUniqueName/login/:loginId/token/reconnect', (req, res) ->
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName + '/login/' + req.params.loginId + '/token/reconnect'
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
      'X-Forwarded-For': res.locales.remoteIp
  settings.client.get hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data


#delete audit logs
router.delete '/:companyUniqueName/logs/:beforeDate', (req, res) ->
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName + '/logs?beforeDate=' + req.params.beforeDate
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
      'X-Forwarded-For': res.locales.remoteIp
    data: req.body
  settings.client.delete hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

router.get '/:uniqueName/switchUser', (req, res) ->
  hUrl = settings.envUrl + 'company/' + req.params.uniqueName
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
      'X-Forwarded-For': res.locales.remoteIp
  settings.client.patch hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data


# get taxes
router.get '/:companyUniqueName/tax', (req, res) ->
  authHead =
    headers:
      'Auth-Key': req.session.authKey
      'X-Forwarded-For': res.locales.remoteIp
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName + '/tax'
  settings.client.get hUrl, authHead, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

# add taxes
router.post '/:companyUniqueName/tax', (req, res) ->
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName + '/tax?updateEntries=' + req.body.updateEntries
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

# delete tax
router.delete '/:companyUniqueName/tax/:taxUniqueName', (req, res) ->
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName + '/tax/' + req.params.taxUniqueName
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
      'X-Forwarded-For': res.locales.remoteIp
  settings.client.delete hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

#edit/update taxe
router.put '/:companyUniqueName/tax/:taxUniqueName/:updateEntries', (req, res) ->
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName + '/tax/' + req.params.taxUniqueName + '?updateEntries=' + req.params.updateEntries
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


# get Invoice templates
router.get '/:uniqueName/templates', (req, res) ->
  hUrl = settings.envUrl+'company/'+req.params.uniqueName+'/templates'
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
      'X-Forwarded-For': res.locales.remoteIp
  settings.client.get hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data
    
# set default template
router.put '/:uniqueName/templates/:tempUname', (req, res) ->
  hUrl = settings.envUrl+'company/'+req.params.uniqueName+'/invoices/templates/'+req.params.tempUname
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
      'X-Forwarded-For': res.locales.remoteIp
  settings.client.put hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

# set template data
router.put '/:uniqueName/templates', (req, res) ->
  hUrl = settings.envUrl+'company/'+req.params.uniqueName+'/templates'
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

# delete invoice
router.delete '/:uniqueName/invoices/:invoiceUniqueID', (req, res) ->
  hUrl = settings.envUrl+'company/'+req.params.uniqueName+'/invoices/'+req.params.invoiceUniqueID
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
      'X-Forwarded-For': res.locales.remoteIp
  settings.client.delete hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data


# connect banks
router.get '/:uniqueName/ebanks/token', (req, res) ->
  hUrl = settings.envUrl+'company/'+req.params.uniqueName+'/ebanks/token'
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
      'X-Forwarded-For': res.locales.remoteIp
  settings.client.get hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

router.delete '/:companyUniqueName/login/:loginId',(req,res) ->
  hUrl = settings.envUrl + 'company/'+req.params.companyUniqueName+'/login/'+req.params.loginId
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
      'X-Forwarded-For': res.locales.remoteIp
  settings.client.delete hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data


router.get '/:companyUniqueName/cropped-flatten-account', (req,res) ->
  hUrl = settings.envUrl + 'company/'+req.params.companyUniqueName+'/cropped-flatten-accounts'
  if req.query.query != ''
    hUrl = hUrl + '?q='+req.query.query
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
      'X-Forwarded-For': res.locales.remoteIp
  settings.client.get hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

router.post '/:companyUniqueName/cropped-flatten-account', (req,res) ->
  hUrl = settings.envUrl + 'company/'+req.params.companyUniqueName+'/cropped-flatten-accounts'
  if req.query.query != ''
    hUrl = hUrl + '?q='+req.query.query
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
      'X-Forwarded-For': res.locales.remoteIp
  settings.client.post hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

router.get '/:companyUniqueName/settings', (req,res) ->
  hUrl = settings.envUrl + 'company/'+req.params.companyUniqueName + '/settings'
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
      'X-Forwarded-For': res.locales.remoteIp
  settings.client.get hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

router.put '/:companyUniqueName/settings', (req,res) ->
  hUrl = settings.envUrl + 'company/'+req.params.companyUniqueName + '/settings'
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

router.post '/:companyUniqueName/settings/webhooks', (req,res) ->
  hUrl = settings.envUrl + 'company/'+req.params.companyUniqueName + '/settings/webhooks'
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

router.delete '/:companyUniqueName/settings/webhooks/:webhookUniqueName', (req, res) ->
  hUrl = settings.envUrl + 'company/'+req.params.companyUniqueName + '/settings/webhooks/'+req.params.webhookUniqueName
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
      'X-Forwarded-For': res.locales.remoteIp
  settings.client.delete hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data


router.get '/:companyUniqueName/razorpay', (req, res) ->
  hUrl = settings.envUrl + 'company/'+req.params.companyUniqueName + '/razorpay'
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
      'X-Forwarded-For': res.locales.remoteIp
  settings.client.get hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data


router.post '/:companyUniqueName/razorpay', (req, res) ->
  hUrl = settings.envUrl + 'company/'+req.params.companyUniqueName + '/razorpay'
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

router.put '/:companyUniqueName/razorpay', (req, res) ->
  hUrl = settings.envUrl + 'company/'+req.params.companyUniqueName + '/razorpay'
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

router.delete '/:companyUniqueName/razorpay', (req, res) ->
  hUrl = settings.envUrl + 'company/'+req.params.companyUniqueName + '/razorpay'
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
      'X-Forwarded-For': res.locales.remoteIp
  settings.client.delete hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

module.exports = router