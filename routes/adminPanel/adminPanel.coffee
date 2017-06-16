settings = require('../util/settings')
router = settings.express.Router({mergeParams: true})


# generate magic link
router.post '/companies', (req, res) ->
  args =
    headers:
      'Auth-Key': req.session.authKey
      'X-Forwarded-For': res.locales.remoteIp
      'Content-Type': 'application/json'
    data: req.body.filters
  hUrl = settings.envUrl + 'admin/companies?page='+req.body.params.page+'&count='+req.body.params.count
  settings.client.post hUrl, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data


module.exports = router