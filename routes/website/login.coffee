settings = require('../util/settings')
app = settings.express()
jwt = require('jwt-simple')
qs = require('qs')
router = settings.express.Router()
googleLoginUrl = settings.envUrl + 'signup-with-google'
linkedinLoginUrl =  settings.envUrl + 'signup-with-linkedIn'
twitterLoginUrl =  settings.envUrl + 'signup-with-twitter'

hitViaSocket = (data) ->
  data = JSON.stringify(data)
  data.environment = app.get('env')
  if data.isNewUser
    settings.request {
      url: 'https://viasocket.com/t/fDR1TMJLvMQgwyjBUMVs/giddh-giddh-login?authkey=MbK1oT6x1RCoVf2AqL3y'
      qs:
        from: 'Giddh'
        time: +new Date
      method: 'POST'
      headers:
        'Content-Type': 'application/json'
        'Auth-Key': 'MbK1oT6x1RCoVf2AqL3y'
      body: data.user
    }, (error, response, body) ->
      if error
        console.log error
      else
        console.log response.statusCode, body, 'from viasocket'
      return


###
 |--------------------------------------------------------------------------
 | login with google
 |--------------------------------------------------------------------------
####

router.post '/google', (req, res, next) ->
  googleAccessTokenUrl = 'https://accounts.google.com/o/oauth2/token'
  params =
    code: req.body.code
    client_id: req.body.clientId
    client_secret: settings.googleKey
    redirect_uri: req.body.redirectUri
    grant_type: 'authorization_code'
  # Step 1. Login in Giddh API.
  settings.request.post googleAccessTokenUrl, {
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
    settings.client.get googleLoginUrl, args, (data, response) ->
      if data.status == 'error' || data.status == undefined
        res.status(response.statusCode)
      else
        if data.body.authKey
          userDetailObj = data.body.user
          req.session.name = data.body.user.uniqueName
          req.session.authKey = data.body.authKey
          data.body.sId = req.sessionID
          hitViaSocket(data.body)
      res.send
        token: token
        userDetails: userDetailObj
        result: data

###
 |--------------------------------------------------------------------------
 | Login with Twitter
 |--------------------------------------------------------------------------
###

router.post '/twitter', (req, res) ->
  requestTokenUrl = 'https://api.twitter.com/oauth/request_token'
  twitterAccessTokenUrl = 'https://api.twitter.com/oauth/access_token'
  profileUrl = 'https://api.twitter.com/1.1/users/show.json?screen_name='
  # Part 1 of 2: Initial request from Satellizer.
  if !req.body.oauth_token or !req.body.oauth_verifier
    requestTokenOauth = 
      consumer_key: settings.twitterKey
      consumer_secret: settings.twitterSecret
      callback: req.body.redirectUri
    # Step 1. Obtain request token for the authorization popup.
    settings.request.post {
      url: requestTokenUrl
      oauth: requestTokenOauth
    }, (err, response, body) ->
      oauthToken = qs.parse(body)
      # Step 2. Send OAuth token back to open the authorization screen.
      res.send oauthToken
  else
    # Part 2 of 2: Second request after Authorize app is clicked.
    accessTokenOauth = 
      consumer_key: settings.twitterKey
      consumer_secret: settings.twitterSecret
      token: req.body.oauth_token
      verifier: req.body.oauth_verifier
    # Step 3. Exchange oauth token and oauth verifier for access token.
    settings.request.post {
      url: twitterAccessTokenUrl
      oauth: accessTokenOauth
    }, (err, response, accessToken) ->
      accessToken = qs.parse(accessToken)
      userDetailObj = {}
      # Step 4 hit our java api
      args =
        headers:
          'Content-Type': 'application/json'
          'Access-Token': accessToken.oauth_token
          'Access-Secret': accessToken.oauth_token_secret
      settings.client.get twitterLoginUrl, args, (data, response) ->
        if data.status == 'error' || data.status == undefined
          res.status(response.statusCode)
        else
          if data.body.authKey
            userDetailObj = data.body.user
            req.session.name = data.body.user.uniqueName
            req.session.authKey = data.body.authKey
            data.body.sId = req.sessionID
        res.send
          token: accessToken.oauth_token
          userDetails: userDetailObj
          result: data
      

###
 |--------------------------------------------------------------------------
 | Login with LinkedIn
 |--------------------------------------------------------------------------
###
router.post '/linkedin/callback', (req, res) ->
  console.log req, "callback"


router.post '/linkedin', (req, res) ->
  linkedinAccessTokenUrl = 'https://www.linkedin.com/uas/oauth2/accessToken'
  peopleApiUrl = 'https://api.linkedin.com/v1/people/~:(id,first-name,last-name,email-address,picture-url)'
  params = 
    code: req.body.code
    client_id: req.body.clientId
    client_secret: settings.linkedinSecret
    redirect_uri: req.body.redirectUri
    grant_type: 'authorization_code'
  # Step 1. Exchange authorization code for access token.
  settings.request.post linkedinAccessTokenUrl, {
    form: params
    json: true
  }, (err, response, body) ->
    `var params`
    if response.statusCode != 200
      return res.status(response.statusCode).send(message: body.error_description)
    userDetailObj = {}
    args =
      headers:
        'Content-Type': 'application/json'
        'Access-Token': body.access_token
    # Step 2. Retrieve profile information about the current user.
    settings.client.get linkedinLoginUrl, args, (data, response) ->
      if data.status == 'error' || data.status == undefined
        res.status(response.statusCode)
      else
        if data.body.authKey
          userDetailObj = data.body.user
          req.session.name = data.body.user.uniqueName
          req.session.authKey = data.body.authKey
          data.body.sId = req.sessionID
      res.send
        token: body.access_token
        userDetails: userDetailObj
        result: data
            

module.exports = router