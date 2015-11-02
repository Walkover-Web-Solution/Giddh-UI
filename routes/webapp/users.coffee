settings = require('../util/settings')
router = settings.express.Router()

router.get '/:uniqueName', (req, res) ->
  console.log "inside user route"
  onlyAuthHead =
    headers:
      'Auth-Key': req.session.authKey
  hUrl = settings.envUrl + 'users/' + req.params.uniqueName
  settings.client.get hUrl, onlyAuthHead, (data, response) ->
    if data.status == 'error'
      res.status(response.statusCode)
    res.send data

router.get '/auth-key', (req, res) ->
  console.log "inside get auth key"
  args =
    parameters:
      uniqueName: req.query.uniqueName
  hUrl = settings.envUrl + 'giddh-api/users/auth-key'
  console.log "url:", hUrl
  settings.client.get hUrl, args, (data, response) ->
    if data.status == 'error'
      res.status(response.statusCode)
    res.send data


module.exports = router