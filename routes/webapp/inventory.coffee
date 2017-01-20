settings = require('../util/settings')
router = settings.express.Router({mergeParams: true})

router.get '/unit-types', (req, res) ->
  hUrl = settings.envUrl + '/stock-units'
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
  hUrl = settings.envUrl + 'company/'+req.params.companyUniqueName + '/flatten-stock-groups-with-stocks?page=' + req.query.page + '&count=' + req.query.count + '&q=' + req.query.q
  console.log(req.query, hUrl)
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
      'X-Forwarded-For': res.locales.remoteIp
  settings.client.get hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

router.get '/groups-with-stocks-hierarchy-min', (req, res) ->
  hUrl = settings.envUrl + 'company/'+req.params.companyUniqueName + '/stock-group'
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
      'X-Forwarded-For': res.locales.remoteIp
  settings.client.get hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

router.put '/update-stock-item', (req, res) ->
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
      'X-Forwarded-For': res.locales.remoteIp
    data:
      req.body
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName + '/stock-group/' + req.query.stockGroupUniqueName + '/stock/' + req.query.stockUniqueName
  settings.client.put hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data


router.put '/:stockGroupUniqueName', (req, res) ->
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
      'X-Forwarded-For': res.locales.remoteIp
    data:
      req.body
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName + '/stock-group/' + req.params.stockGroupUniqueName
  settings.client.put hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

router.get '/:stockGroupUniqueName/stocks', (req, res) ->
  hUrl = settings.envUrl + 'company/'+ req.params.companyUniqueName + '/stock-group/' + req.params.stockGroupUniqueName + '/stocks'
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
      'X-Forwarded-For': res.locales.remoteIp
  settings.client.get hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

router.post '/:stockGroupUniqueName/stock', (req, res) ->
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
      'X-Forwarded-For': res.locales.remoteIp
    data:
      req.body
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName + '/stock-group/' + req.params.stockGroupUniqueName + '/stock'
  settings.client.post hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

router.get '/stocks', (req, res) ->
  if(req.query.q)
    hUrl = settings.envUrl + 'company/'+ req.params.companyUniqueName + '/stocks?q=' + req.query.q + '&page=' + req.query.page + '&count=' + req.query.count
  else
    hUrl = settings.envUrl + 'company/'+ req.params.companyUniqueName + '/stocks'
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
      'X-Forwarded-For': res.locales.remoteIp
  settings.client.get hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

router.get '/hierarchical-stock-groups', (req, res) ->
  hUrl = settings.envUrl + 'company/'+ req.params.companyUniqueName + '/hierarchical-stock-groups?q=' + req.query.q + '&page=' + req.query.page + '&count=' + req.query.count
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
      'X-Forwarded-For': res.locales.remoteIp
  settings.client.get hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

router.get '/get-stock-detail', (req, res) ->
  hUrl = settings.envUrl + 'company/'+ req.params.companyUniqueName + '/stock-group/' + req.query.stockGroupUniqueName + '/stock/' + req.query.stockUniqueName
  console.log(hUrl, req.query, req.params)
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
      'X-Forwarded-For': res.locales.remoteIp
  settings.client.get hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

router.get '/:stockGroupUniqueName', (req, res) ->
  hUrl = settings.envUrl + 'company/'+ req.params.companyUniqueName + '/stock-group/' + req.params.stockGroupUniqueName
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