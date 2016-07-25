settings = require('../util/settings')
router = settings.express.Router()

router.get '/', (req, res) ->
  onlyAuthHead =
    headers:
      'Auth-Key': req.session.authKey
      'X-Forwarded-For': res.locales.remoteIp
  hUrl = settings.envUrl + 'roles'
  settings.client.get hUrl, onlyAuthHead, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

module.exports = router