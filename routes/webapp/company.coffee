settings = require('../util/settings')
router = settings.express.Router()

router.get '/all', (req, res) ->
  onlyAuthHead =
    headers:
      'Auth-Key': req.session.authKey
  hUrl = settings.envUrl + 'users/' + req.session.name + '/companies'
  settings.client.get hUrl, onlyAuthHead, (data) ->
    if data.status == 'error'
      res.status(response.statusCode)
    res.send data

router.delete '/:uniqueName', (req, res) ->
  console.log req.params.uniqueName, "in delete company"
  hUrl = settings.envUrl + 'company/'+req.params.uniqueName
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
  settings.client.delete hUrl, args, (data, response) ->
    if data.status == 'error'
      res.status(response.statusCode)
    res.send data

router.get '/:uniqueName', (req, res) ->
  console.log req.params.uniqueName

router.post '/', (req, res) ->
  hUrl = settings.envUrl + 'company/'
  req.body.uniqueName = settings.stringUtil.getRandomString(req.body.name, req.body.city)
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
    data: req.body
  settings.client.post hUrl, args, (data) ->
    if data.status == 'error'
      res.status(response.statusCode)
    res.send data

module.exports = router