settings = require('../util/settings')
router = settings.express.Router({mergeParams: true})

router.post '/:uniqueName', (req, res) ->
  abc = req.params.companyUniqueName + '/proforma/'+req.params.uniqueName
  str = settings.envUrl+ 'company/' + abc
  args =
    headers:
      'Auth-Key': req.session.authKey
      'X-Forwarded-For': res.locales.remoteIp
    data: req.body
  settings.client.post str, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data


module.exports = router