settings = require('../util/settings')
router = settings.express.Router({mergeParams: true})

router.post '/', (req, res) ->
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
      'X-Forwarded-For': res.locales.remoteIp
    data:
      req.body
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName + '/stock-group'
  settings.client.post hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

router.get '/groups-with-stocks-flatten', (req, res) ->
  hUrl = settings.envUrl + 'company/'+req.params.companyUniqueName + '/stock-group/groups-with-stocks-flattern'
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
      'X-Forwarded-For': res.locales.remoteIp
  settings.client.get hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

router.get '/groups-with-stocks-hierarchy', (req, res) ->
  hUrl = settings.envUrl + 'company/'+req.params.companyUniqueName + '/stock-group/groups-with-stocks-hierarchy'
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