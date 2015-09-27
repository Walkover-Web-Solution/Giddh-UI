var express = require('express');
var path = require('path');
var favicon = require('serve-favicon');
var logger = require('morgan');
var cookieParser = require('cookie-parser');
var bodyParser = require('body-parser');
var session = require('express-session');
var engines = require('consolidate');
var request = require('request');
var jwt = require('jwt-simple');

//Example POST method invocation
var Client = require('node-rest-client').Client;
var client = new Client();

//enabling cors
var cors = require('cors')

var app = express();

var userDetailObj = {};
//for test environment
var envUrl = "http://localhost:9292/giddh-api/";

var port = process.env.PORT || 8000;
//enabling cors
app.use(cors())

//set engine
app.set('public', __dirname + '/public/');
app.engine('html', engines.mustache);
app.set('view engine', 'html');

app.use(favicon(__dirname + '/app/website/images/favicon.ico'));

app.use(logger('dev'));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({extended: true}));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));
app.use('/bower_components', express.static(__dirname + '/bower_components'));
app.use('/public', express.static(__dirname + '/public'));


// for session
app.use(cookieParser());
app.use(session({
  secret: "keyboardcat",
  name: "userVerified",
  resave: true,
  saveUninitialized: true,
  cookie: {
    secure: false,
    maxAge: null
  }
}));

// do not remove code from this position
var contact = require('./public/routes/website/contact');
var websiteRoutes = require('./public/routes/website/main');

app.use('/contact', contact);
app.use('/', websiteRoutes);

var currency = require('./public/routes/webapp/currency');
var company = require('./public/routes/webapp/company');
var appRoutes = require('./public/routes/webapp/main');

app.use('/currency', currency);
app.use('/company', company);
app.use('/', appRoutes);

/*
 |--------------------------------------------------------------------------
 | Location using google api
 |--------------------------------------------------------------------------
 */
app.get('/getLocation', function (req, res) {
  console.log(req.query.queryString);
  var googleApi = 'http://maps.googleapis.com/maps/api/geocode/json?callback=JSON_CALLBACK&address=' + req.query.queryString;
  request.get(googleApi, function (err, response) {
    console.log(response.body);
    res.send(response.body);
  });
});

/*
 |--------------------------------------------------------------------------
 | Login with Google
 |--------------------------------------------------------------------------
 */
app.post('/auth/google', function (req, res, next) {
  console.log("in auth google request");
  var accessTokenUrl = 'https://accounts.google.com/o/oauth2/token';
  var peopleApiUrl = 'https://www.googleapis.com/plus/v1/people/me/openIdConnect';
  var params = {
    code: req.body.code,
    client_id: req.body.clientId,
    client_secret: "9ejAFtIyKTQz2KuAXmD-jN68",
    redirect_uri: req.body.redirectUri,
    grant_type: 'authorization_code'
  };

  // Step 1. Exchange authorization code for access token.
  request.post(accessTokenUrl, {json: true, form: params}, function (err, response, token) {
    var accessToken = token.access_token;
    var headers = {Authorization: 'Bearer ' + accessToken};

    // Step 2. Retrieve profile information about the current user.
    request.get({url: peopleApiUrl, headers: headers, json: true}, function (err, response, profile) {
      if (profile.error) {
        return res.status(500).send({message: profile.error.message});
      }
      console.log(response.body, "auth response");
      var token = jwt.encode(response, params.client_secret);

      console.log("in get success")
      //knowing if user is verified in giddh
      var authUrl = envUrl + "users/auth-key?userEmail=" + response.body.email;
      args = {
        headers: {"Content-Type": "application/json"}
      }
      userDetailObj = response.body;

      client.get(authUrl, args, function (data, response) {
        console.log(data, "data in client post by authUrl");

        if (data.status == "error") {
          //do nothing
        }
        else {
          userDetailObj.userUniqueName = data.body.uniqueName;
          req.session.name = data.body.uniqueName
          req.session.authKey = data.body.authKey
          console.log(userDetailObj)
        }
        res.send({
          token: token,
          userDetails: userDetailObj,
          result: data
        });
      });
    });
  });
});

app.listen(port, function () {
  console.log('Express Server running at port', this.address().port);
});

/*
 |--------------------------------------------------------------------------
 | Error Handlers
 |--------------------------------------------------------------------------
 */
// catch 404 and forward to error handler
app.use(function (req, res, next) {
  var err = new Error('Page Not Found');
  err.status = 404;
  next(err);
});

// development error handler
// will print stacktrace
if (app.get('env') === 'development') {
  app.use(function (err, req, res, next) {
    res.status(err.status || 500);
    var filePath = __dirname + '/public/website/views/error';
    res.render(filePath, {
      message: err.message,
      error: err
    });
  });
}

// production error handler
// no stacktraces leaked to user
app.use(function (err, req, res, next) {
  res.status(err.status || 500);
  var filePath = __dirname + '/public/website/views/error';
  res.render(filePath, {
    message: err.message,
    error: {}
  });
});

module.exports = app;