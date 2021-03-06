settings = require('../util/settings')
router = settings.express.Router({mergeParams: true})

#download balance sheet data
router.get '/balance-sheet-collapsed-download', (req, res) ->
  args =
    headers:
      'Auth-Key': req.session.authKey
      'X-Forwarded-For': res.locales.remoteIp
    parameters:
      fy: req.query.fy
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName  + '/v2/balance-sheet-collapsed-download'
  settings.client.get hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data    

module.exports = router