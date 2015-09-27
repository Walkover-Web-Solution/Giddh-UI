settings = require('../shared/settings')

settings.router.get '/', (req, res) ->
  hUrl = settings.envUrl + 'currency'
  args = headers: 'Content-Type': 'application/json'
  settings.client.post hUrl, args, (data) ->
    res.send data

module.exports = settings.router