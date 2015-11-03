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

router.get '/auth-key/:uniqueName', (req, res) ->
  console.log "inside get auth key", req.session.authKey
  data = {
    status: "success"
    body: req.session.authKey
  }
  res.send(data)

router.put '/:uniqueName/generate-auth-key', (req, res) ->
  console.log "inside generate auth key"
  onlyAuthHead =
    headers:
      'Auth-Key': req.session.authKey
  hUrl = settings.envUrl + 'users/' + req.params.uniqueName + '/generate-auth-key'
  settings.client.put hUrl, onlyAuthHead, (data, response) ->
    if data.status == 'error'
      res.status(response.statusCode)
    else
      req.session.authKey = data.body.authKey
    console.log "new auth key", req.session.authKey
    res.send data


module.exports = router