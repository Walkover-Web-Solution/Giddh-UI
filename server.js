var express = require('express');
var path = require('path');
var logger = require('morgan');
var cookieParser = require('cookie-parser');
var bodyParser = require('body-parser');
var engines = require('consolidate');
var request = require('request');
var jwt = require('jwt-simple');
/*
//commented not in use modified by sarfaraz
var routes = require('./routes/index');
var users = require('./routes/users');
app.use('/', routes);
app.use('/users', users);
*/

var app = express();



//set engine
app.set('views', __dirname + '/views/');
app.engine('html', engines.mustache);
app.set('view engine', 'html');


app.use(logger('dev'));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));
app.use('/bower_components',  express.static(__dirname + '/bower_components'));
app.use('/public',  express.static(__dirname + '/public'));
app.use('/views',  express.static(__dirname + '/views'));


/*for serve app only templates files after login*/
var options = {
  root: __dirname + '/public/view',
  dotfiles: 'deny',
  headers: {
      'x-timestamp': Date.now(),
      'x-sent': true
  }
};
app.get('/app/*', function (req, res, next) {
  console.log(req.url);
  var fileName = "indexa.html";
  res.sendFile(fileName, options);
});



/*
  defining routes before login static web pages
*/
var options1 = {
  root: __dirname + '/views',
  dotfiles: 'deny',
  headers: {
      'x-timestamp': Date.now(),
      'x-sent': true
  }
};

app.get('/', function(req, res, next) {
  res.sendFile("index.html", options1);
});
app.get('/index', function(req, res, next) {
  res.sendFile("index.html", options1);
});

app.get('/contact', function(req, res, next) {
  res.sendFile("contact.html", options1);
});
app.get('/version', function(req, res, next) {
  res.sendFile("version.html", options1);
});
app.get('/login', function(req, res, next) {
  res.sendFile("login.html", options1);
});
app.get('/pricing', function(req, res, next) {
  res.sendFile("pricing.html", options1);
});
app.get('/privacy', function(req, res, next) {
  res.sendFile("privacy.html", options1);
});
app.get('/terms', function(req, res, next) {
  res.sendFile("terms.html", options1);
});
app.get('/invoice', function(req, res, next) {
  res.sendFile("invoice.html", options1);
});
app.get('/billing', function(req, res, next) {
  res.sendFile("billing.html", options1);
});
app.get('/accountingbook', function(req, res, next) {
  res.sendFile("accountingbook.html", options1);
});
app.get('/accountingsoftware', function(req, res, next) {
  res.sendFile("accountingsoftware.html", options1);
});
/*
 |--------------------------------------------------------------------------
 | Login with Google
 |--------------------------------------------------------------------------
 */
app.post('/auth/google', function(req, res) {
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
  request.post(accessTokenUrl, { json: true, form: params }, function(err, response, token) {
    var accessToken = token.access_token;
    var headers = { Authorization: 'Bearer ' + accessToken };

    // Step 2. Retrieve profile information about the current user.
    request.get({ url: peopleApiUrl, headers: headers, json: true }, function(err, response, profile) {
      if (profile.error) {
        return res.status(500).send({message: profile.error.message});
      }
      console.log(response.body, "auth response");
      var token = jwt.encode(response, params.client_secret);

      //var decoded = jwt.decode(token, params.client_secret);
      //console.log(decoded)
      res.send({ token: token });

    });
  });
});







// app.listen(8000, 'localhost');
// console.log('Server running at http://localhost:8000/');
app.listen(8000, 'localhost', function(){
  console.log('Express Server running at http://localhost and using port', this.address().port);
});

// catch 404 and forward to error handler
app.use(function(req, res, next) {
  var err = new Error('Not Found');
  err.status = 404;
  next(err);
});

// error handlers

// development error handler
// will print stacktrace
if (app.get('env') === 'development') {
  app.use(function(err, req, res, next) {
    res.status(err.status || 500);
    res.render('error', {
      message: err.message,
      error: err
    });
  });
}

// production error handler
// no stacktraces leaked to user
app.use(function(err, req, res, next) {
  res.status(err.status || 500);
  res.render('error', {
    message: err.message,
    error: {}
  });
});


module.exports = app;