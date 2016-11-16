settings = require('../util/settings')
router = settings.express.Router({mergeParams: true})

router.post '/', (req, res) ->
  console.log "from templates"
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

module.exports = router
