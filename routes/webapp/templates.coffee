settings = require('../util/settings')
router = settings.express.Router({mergeParams: true})

router.post '/', (req, res) ->
  args =
    headers:
      'Auth-Key': req.session.authKey
      'X-Forwarded-For': res.locales.remoteIp
      'Content-Type' :'application/json'
    data: req.body
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName + '/templates'
  settings.client.post hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

router.put '/update/:templateUniqueName', (req, res) ->
  args =
    headers:
      'Auth-Key': req.session.authKey
      'X-Forwarded-For': res.locales.remoteIp
      'Content-Type' :'application/json'
    data: req.body
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName + '/templates/' + req.params.templateUniqueName
  settings.client.put hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

router.get '/all', (req, res) ->
  args =
    headers:
      'Auth-Key': req.session.authKey
      'X-Forwarded-For': res.locales.remoteIp
      'Content-Type' :'application/json'
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName + '/templates/all'
  settings.client.get hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data


router.get '/:templateUniqueName', (req, res) ->
  console.log 'from get'
  args =
    headers:
      'Auth-Key': req.session.authKey
      'X-Forwarded-For': res.locales.remoteIp
      'Content-Type' :'application/json'
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName + '/templates/' + req.params.templateUniqueName + '?operation=' + req.query.operation
  settings.client.get hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

router.delete '/:templateUniqueName', (req, res) ->
  args =
    headers:
      'Auth-Key': req.session.authKey
      'X-Forwarded-For': res.locales.remoteIp
      'Content-Type' :'application/json'
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName + '/templates/' + req.params.templateUniqueName
  console.log(hUrl)
  settings.client.delete hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

router.get '/placeholders', (req, res) ->
  args =
    headers:
      'Auth-Key': req.session.authKey
      'X-Forwarded-For': res.locales.remoteIp
      'Content-Type' :'application/json'
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName + '/placeholders'
  settings.client.post hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

module.exports = router
