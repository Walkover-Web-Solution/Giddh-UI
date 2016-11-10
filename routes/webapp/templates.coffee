settings = require('../util/settings')
router = settings.express.Router()

router.post '/', (req, res) ->
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
      'X-Forwarded-For': res.locales.remoteIp
    data: req.body
  hUrl = settings.envUrl + 'company/' + req.body.company + '/templates'

  settings.client.post hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data
    console.log hUrl

module.exports = router