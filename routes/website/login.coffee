settings = require('../util/settings')
jwt = require('jwt-simple');
router = settings.express.Router()
accessTokenUrl = 'https://accounts.google.com/o/oauth2/token'
peopleApiUrl = 'https://www.googleapis.com/plus/v1/people/me/openIdConnect'

router.post '/google', (req, res, next) ->
  params =
    code: req.body.code
    client_id: req.body.clientId
    client_secret: '9ejAFtIyKTQz2KuAXmD-jN68'
    redirect_uri: req.body.redirectUri
    grant_type: 'authorization_code'
  # Step 1. Exchange authorization code for access token.
  settings.request.post accessTokenUrl, {
    json: true
    form: params
  }, (err, response, token) ->
    accessToken = token.access_token
    headers = Authorization: 'Bearer ' + accessToken
    # Step 2. Retrieve profile information about the current user.
    settings.request.get {
      url: peopleApiUrl
      headers: headers
      json: true
    }, (err, response, profile) ->
      if profile.error
        return res.status(500).send(message: profile.error.message)
      token = jwt.encode(response, params.client_secret)
      #knowing if user is verified in giddh
      authUrl = settings.envUrl + 'users/auth-key?userEmail=' + response.body.email
      args = headers: 'Content-Type': 'application/json'
      userDetailObj = response.body
      settings.client.get authUrl, args, (data, response) ->
        console.log 'In client post by authUrl'
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
