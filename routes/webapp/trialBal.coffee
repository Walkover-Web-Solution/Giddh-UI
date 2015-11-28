settings = require('../util/settings')
router = settings.express.Router({mergeParams: true})

#Get trial balance for an account, query params are - fromDate/toDate {dd-mm-yyyy}
router.get '/', (req, res) ->
  console.log req.query, "get trial balance by date", new Date()
  args =
    headers:
      'Auth-Key': req.session.authKey
    parameters:
      to: req.query.toDate
      from: req.query.fromDate
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName  + '/trialBalance'
  settings.client.get hUrl, args, (data, response) ->
    if data.status == 'error'
      res.status(response.statusCode)
    res.send data

module.exports = router