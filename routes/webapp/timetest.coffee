settings = require('../util/settings')
router = settings.express.Router({mergeParams: true})

router.get '/', (req, res) ->
  console.log("we are here")
  authHead =
    headers:
      'Auth-Key': req.session.authKey
      'X-Forwarded-For': res.locales.remoteIp
  data = {envUrl: settings.envUrl}
  res.send data





module.exports = router