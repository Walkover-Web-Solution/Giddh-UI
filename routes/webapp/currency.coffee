settings = require('../util/settings')
router = settings.express.Router()

router.get '/', (req, res) ->
  hUrl = settings.envUrl + 'currency'
  args = headers: 'Content-Type': 'application/json'
  settings.client.get hUrl, args, (data) ->
    res.send data

module.exports = router