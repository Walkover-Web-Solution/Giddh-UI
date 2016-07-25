settings = require('../util/settings')
router = settings.express.Router()

router.get '/magic', (req, res) ->
  console.log req
  args =
    headers:
      'X-Forwarded-For': res.locales.remoteIp
  hUrl = settings.envUrl + 'giddh-api/magic-link/'
  settings.client.get hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

module.exports = router