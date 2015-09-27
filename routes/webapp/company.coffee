settings = require('../shared/settings')

settings.router.get '/all', (req, res) ->
  onlyAuthHead = headers: 'Auth-Key': req.session.authKey
  hUrl = settings.envUrl + 'users/' + req.session.name + '/companies'
  settings.client.get hUrl, onlyAuthHead, (data) ->
    res.send data

settings.router.post '/', (req, res) ->
  hUrl = settings.envUrl + 'company/'
  req.body.uniqueName = settings.utils.getRandomString(req.body.name, req.body.city)
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
    data: req.body
  settings.client.post hUrl, args, (data) ->
    res.send data

module.exports = settings.router