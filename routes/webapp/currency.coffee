settings = require('../util/settings')
router = settings.express.Router()

router.get '/', (req, res) ->
  hUrl = settings.envUrl + 'currency'
  args = 
  	headers: 
  		'Content-Type': 'application/json'
  		'X-Forwarded-For': res.locales.remoteIp
  settings.client.get hUrl, args, (data, response) ->
    if data.status == 'error'
      res.status(response.statusCode)
    res.send data

module.exports = router