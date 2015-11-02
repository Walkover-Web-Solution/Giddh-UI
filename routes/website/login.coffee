settings = require('../util/settings')
jwt = require('jwt-simple');
router = settings.express.Router()
accessTokenUrl = 'https://accounts.google.com/o/oauth2/token'
loginUrl = settings.envUrl + 'login-with-google'

router.post '/google', (req, res, next) ->
  params =
    code: req.body.code
    client_id: req.body.clientId
    client_secret: settings.googleKey
    redirect_uri: req.body.redirectUri
    grant_type: 'authorization_code'
  # Step 1. Login in Giddh API.
  settings.request.post accessTokenUrl, {
    json: true
    form: params
  }, (err, response, token) ->
    accessToken = token.access_token
    userDetailObj = {}
    args =
      headers:
        'Content-Type': 'application/json'
        'Access-Token': accessToken
    # Step 2. Retrieve profile information about the current user.
    settings.client.get loginUrl, args, (data, response) ->
      if data.status == 'error'
        res.status(response.statusCode)
      else
        userDetailObj.userUniqueName = data.body.uniqueName
        req.session.name = data.body.uniqueName
        req.session.authKey = data.body.authKey
        console.log userDetailObj
      res.send
        token: token
        userDetails: userDetailObj
        result: data

module.exports = router
