settings = require('../util/settings')
router = settings.express.Router()

dirName = settings.path.resolve(__dirname, '..', '..')
options = {
  root: dirName + '/website/views',
  dotfiles: 'deny',
  headers:
    'x-timestamp': Date.now(),
    'x-sent': true
}

router.get '/', (req, res) ->
  res.sendFile 'index.html', options

router.get '/index', (req, res) ->
  res.sendFile 'index.html', options

router.get '/about', (req, res) ->
  res.sendFile 'about.html', options

router.get '/beta', (req, res) ->
  res.sendFile 'beta.html', options

router.get '/pricing', (req, res) ->
  res.sendFile 'pricing.html', options

router.get '/privacy', (req, res) ->
  res.sendFile 'privacy.html', options

router.get '/terms', (req, res) ->
  res.sendFile 'terms.html', options

router.get '/login', (req, res) ->
  res.sendFile 'login.html', options

router.get '/magic', (req, res) ->
  res.sendFile 'magic.html', options

router.get '/payment', (req, res) ->
  res.sendFile 'payment.html', options

router.get '/google87e474bb481dae55.html',(req, res) ->
  res.sendFile('google87e474bb481dae55.html', options)

router.get '/sitemap.xml', (req, res) ->
  res.sendFile 'sitemap.xml', options

router.get '/robots.txt', (req, res) ->
  res.sendFile 'robots.txt', options

router.get '/success', (req, res) ->
  res.sendFile 'success.html', options

router.get '/company/verify-email', (req, res) ->
  res.sendFile 'verifyEmail.html', options

router.get '/refresh-completed', (req, res) ->
  res.sendFile 'refresh-completed.html', options

router.post '/magic-link', (req, res) ->
  if req.body.data.from != undefined && req.body.data.to != undefined
    hUrl = settings.envUrl + '/magic-link/' + req.body.data.id + '?from=' + req.body.data.from + '&to=' + req.body.data.to
  else
    hUrl = settings.envUrl + '/magic-link/' + req.body.data.id
  settings.client.get hUrl, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

router.put '/ebanks/login', (req, res) ->
  hUrl = settings.envUrl + '/ebanks/login/' + req.body.loginId
  settings.client.put hUrl, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

router.post '/verify-email', (req, res) ->
  data = req.body
  hUrl = settings.envUrl + '/company/'+data.companyUname+'/invoice-setting/verify-email?emailAddress='+data.emailAddress+'&scope='+data.scope
  settings.client.get hUrl, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

router.post '/proforma/pay', (req, res) ->
  data = req.body
  hUrl = settings.envUrl + 'company/' + data.companyUniqueName+'/proforma/' + data.uniqueName + '/pay'
  args =
    headers:
      "Content-Type": "application/json"
    data: {
      "paymentId" : data.paymentId
    }
  settings.client.post hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

router.post '/invoice/pay', (req, res) ->
  data = req.body
  hUrl = settings.envUrl + 'company/'+data.companyUniqueName+'/invoices/'+data.uniqueName+'/pay'
  args =
    headers:
      "Content-Type": "application/json"
    data: {
      "paymentId" : data.paymentId
    }
  settings.client.post hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

router.post '/invoice-pay-request', (req, res) ->
  console.log(req.body)
  hUrl = settings.envUrl + 'invoice-pay-request/'+req.body.randomNumber
  console.log(hUrl)
  settings.client.get hUrl, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

router.post '/get-login-otp', (req, res) ->
  data = req.body
  data.getGeneratedOTP = false
  hUrl = "https://sendotp.msg91.com/api/generateOTP"
  args =
    headers:
      "Content-Type": "application/json"
      "application-Key" : settings.getOtpKey
    data: data
  settings.client.post hUrl,args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

router.post '/verify-login-otp', (req, res) ->
  data = req.body
  hUrl = "https://sendotp.msg91.com/api/verifyOTP"
  args =
    headers:
      "Content-Type": "application/json"
      "application-Key" : settings.getOtpKey
    data: data
  settings.client.post hUrl,args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

router.post '/login-with-number', (req, res) ->
  hUrl = hUrl = settings.envUrl + 'login-with-number?' + "countryCode=" + req.body.countryCode + "&mobileNumber=" + req.body.mobileNumber
  args =
    headers:
      "Content-Type": "application/json"
      "Access-Token" : req.body.token
  settings.client.get hUrl,args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    else
      req.session.name = data.body.user.uniqueName
      req.session.authKey = data.body.authKey
    res.send data

module.exports = router
