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
    console.log "get graph data by date", new Date()
    if data.status == 'error'
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
    if data.status == 'error'
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
    if data.status == 'error'
      res.status(response.statusCode)
    res.send data



module.exports = router