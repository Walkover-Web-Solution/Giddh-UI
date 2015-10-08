settings = require('../util/settings')
router = settings.express.Router()

router.get '/all', (req, res) ->
  onlyAuthHead =
    headers:
      'Auth-Key': req.session.authKey
  hUrl = settings.envUrl + 'users/' + req.session.name + '/companies'
  settings.client.get hUrl, onlyAuthHead, (data, response) ->
    if data.status == 'error'
      res.status(response.statusCode)
    res.send data

#delete company
router.delete '/:uniqueName', (req, res) ->
  hUrl = settings.envUrl + 'company/' + req.params.uniqueName
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
  settings.client.delete hUrl, args, (data, response) ->
    if data.status == 'error'
      res.status(response.statusCode)
    res.send data

#update company
router.put '/:uniqueName', (req, res) ->
  console.log req.body
  hUrl = settings.envUrl + 'company/' + req.params.uniqueName
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
    data: req.body
  settings.client.put hUrl, args, (data, response) ->
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
  settings.client.post hUrl, args, (data, response) ->
    if data.status == 'error'
      res.status(response.statusCode)
    res.send data

#get all Roles
router.get '/roles/all', (req, res) ->
  console.log "in getting roles"
  hUrl = settings.envUrl+'/roles/all'
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
  settings.client.get hUrl, args, (data, response) ->
    if data.status == 'error'
      res.status(response.statusCode).send(data)
    else
      res.send data

#get company Shared user list
router.get '/:uniqueName/shared-with', (req, res) ->
  hUrl = settings.envUrl+'company/'+req.params.uniqueName+'/shared-with'
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
  settings.client.get hUrl, args, (data, response) ->
    if data.status == 'error'
      res.status(response.statusCode).send(data)
    else
      res.send data
    

#share company with user
router.put '/:uniqueName/share', (req, res) ->
  hUrl = settings.envUrl + 'company/'+ req.params.uniqueName + '/share'
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
    data: req.body
  settings.client.put hUrl, args, (data, response) ->
    if data.status == 'error'
      res.status(response.statusCode).send(data)
    else
      res.send data

#unShare company with user
router.put '/:uniqueName/unshare', (req, res) ->
  hUrl = settings.envUrl + 'company/'+ req.params.uniqueName + '/unshare'
  args =
    headers:
      'Auth-Key': req.session.authKey
      'Content-Type': 'application/json'
    data: req.body
  settings.client.put hUrl, args, (data, response) ->
    if data.status == 'error'
      res.status(response.statusCode).send(data)
    else
      res.send data

module.exports = router