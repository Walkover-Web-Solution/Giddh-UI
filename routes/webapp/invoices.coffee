settings = require('../util/settings')
router = settings.express.Router({mergeParams: true})

router.get '/', (req, res) ->
  console.log("success achieved", req.query)
  abc = req.params.companyUniqueName + '/invoices?from='+req.query.from+'&to='+req.query.to
  str = settings.envUrl+ 'company/' + abc

  console.log(str);
  args =
    headers:
      'Auth-Key': req.session.authKey
      'X-Forwarded-For': res.locales.remoteIp

  settings.client.get str, args, (data, response) ->
    if data.status == 'error' || data.status == undefined
      res.status(response.statusCode)
    res.send data


module.exports = router