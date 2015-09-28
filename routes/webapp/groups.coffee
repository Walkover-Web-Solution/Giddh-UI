settings = require('../util/settings')
router = settings.express.Router({mergeParams: true})

router.get '/', (req, res) ->
  authHead = headers: 'Auth-Key': req.session.authKey
  hUrl = settings.envUrl + 'company/' + req.params.companyUniqueName + '/groups'
  settings.client.get hUrl, authHead, (data) ->
    console.log data
    res.send data

module.exports = router