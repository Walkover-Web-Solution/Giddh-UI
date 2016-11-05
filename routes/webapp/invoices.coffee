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

router.get '/ledgers', (req, res) ->
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName + '/ledgers?from=' + req.query.from + '&to=' + req.query.to + '&count=' + req.query.count + '&page=' + req.query.page
  args =
    headers:
      'Auth-Key': req.session.authKey
      'X-Forwarded-For': res.locales.remoteIp
      'Content-Type': 'application/json'
    data: req.body
  settings.client.get hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data


module.exports = router