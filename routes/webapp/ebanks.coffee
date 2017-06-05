settings = require('../util/settings')
router = settings.express.Router()


router.post '/', (req, res) ->
  hUrl = settings.envUrl + 'ebanks'
  authHead =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
      'X-Forwarded-For': res.locales.remoteIp
    data: req.body
    parameters:
      name: req.query.name
  settings.client.post hUrl, authHead, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

router.delete '/:companyUniqueName/login/:loginId',(req,res) ->
  hUrl = settings.envUrl + 'company/'+req.params.companyUniqueName+'/ebanks/login/'+req.params.loginId
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
      'X-Forwarded-For': res.locales.remoteIp
  settings.client.delete hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data

module.exports = router