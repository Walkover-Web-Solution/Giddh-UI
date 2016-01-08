settings = require('../util/settings')
router = settings.express.Router({mergeParams: true})

router.post '/', (req, res) ->
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName +
      '/history/'
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
      'X-Forwarded-For': res.locales.remoteIp
    parameters:
      to: req.query.toDate
      from: req.query.fromDate
    data: req.body

  console.log args, hUrl
  settings.client.post hUrl, args, (data, response) ->
    console.log "get graph data by date", new Date()
    if data.status == 'error'
      res.status(response.statusCode)
    res.send data

module.exports = router