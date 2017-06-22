settings = require('../util/settings')
router = settings.express.Router()

router.post '/', (req, res) ->
  if req.body.data.from != undefined && req.body.data.to != undefined
    hUrl = settings.envUrl + '/magic-link/' + req.body.data.id + '?from=' + req.body.data.from + '&to=' + req.body.data.to
  else
    hUrl = settings.envUrl + '/magic-link/' + req.body.data.id
  settings.client.get hUrl, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

router.post '/download-invoice', (req, res) ->
  hUrl = settings.envUrl + '/magic-link/' + req.body.data.id + '/download-invoice/' + req.body.data.invoiceNum
  settings.client.get hUrl, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

module.exports = router