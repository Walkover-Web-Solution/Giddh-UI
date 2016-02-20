settings = require('../util/settings')
router = settings.express.Router()

router.get '/get-coupon', (req, res) ->
  authHead =
    headers:
      'Auth-Key': req.session.authKey
      'X-Forwarded-For': res.locales.remoteIp
    parameters:
      code: req.query.code
  hUrl = settings.envUrl + 'coupon/get-coupon'
  settings.client.get hUrl, authHead, (data, response) ->
    if data.status == 'error'
      res.status(response.statusCode)
    res.send data

module.exports = router