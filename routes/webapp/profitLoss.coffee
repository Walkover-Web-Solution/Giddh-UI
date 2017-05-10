settings = require('../util/settings')
router = settings.express.Router({mergeParams: true})

#Get trial balance for an account, query params are - fromDate/toDate {dd-mm-yyyy}
# router.get '/', (req, res) ->
#  console.log req.query, "get profit and loss statement", new Date()
#   authHead =
#     headers:
#       'Auth-Key': req.session.authKey
#       'X-Forwarded-For': res.locales.remoteIp
#     parameters:
#       to: req.query.toDate
#       from: req.query.fromDate
#       interval: req.query.interval
#   hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName + '/profit-loss'
#   settings.client.get hUrl, authHead, (data, response) ->
#     if data.status == 'error' || data.status == undefined
#       res.status(response.statusCode)
#     res.send data

#download profit loss data
router.get '/profit-loss-collapsed-download', (req, res) ->
  args =
    headers:
      'Auth-Key': req.session.authKey
      'X-Forwarded-For': res.locales.remoteIp
    parameters:
      fy: req.query.fy
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName  + '/profit-loss-collapsed-download'
  settings.client.get hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data    

module.exports = router