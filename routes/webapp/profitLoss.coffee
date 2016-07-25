settings = require('../util/settings')
router = settings.express.Router({mergeParams: true})

#Get trial balance for an account, query params are - fromDate/toDate {dd-mm-yyyy}
router.get '/', (req, res) ->
  console.log req.query, "get profit and loss statement", new Date()
  to = if req.query.to == undefined then '' else req.query.to
  from = if req.query.from == undefined then '' else req.query.to
  args =
    headers:
      'Auth-Key': req.session.authKey
      'X-Forwarded-For': res.locales.remoteIp
    parameters:
      to: to
      from: from
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName  + '/profit-loss'
  settings.client.get hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

module.exports = router