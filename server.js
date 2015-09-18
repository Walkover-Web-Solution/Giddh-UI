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

/*
//commented not in use modified by sarfaraz
var routes = require('./routes/index');
var users = require('./routes/users');
app.use('/', routes);
app.use('/users', users);
*/






//Example POST method invocation 
var Client = require('node-rest-client').Client; 
var client = new Client();

//enabling cors
var cors = require('cors')

var app = express();

var userDetailObj = {};
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
app.use(bodyParser.urlencoded({ extended: true }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));
app.use('/bower_components',  express.static(__dirname + '/bower_components'));
app.use('/public',  express.static(__dirname + '/public'));


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



/*
  defining routes before login static web pages
*/
var options1 = {
  root: __dirname + '/public/website/views/',
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
app.get('/beta', function(req, res, next) {
  res.sendFile("beta.html", options1);
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
app.get('/why-giddh', function(req, res, next) {
  res.sendFile("whyGiddh.html", options1);
});
app.get('/login', function(req, res, next) {
  res.sendFile("login_back.html", options1);
});

/*
 |--------------------------------------------------------------------------
 | for serve app only templates files after login
 |--------------------------------------------------------------------------
*/
var options = {
  root: __dirname + '/public/webapp/views',
  dotfiles: 'deny',
  headers: {
      'x-timestamp': Date.now(),
      'x-sent': true
  }
};
app.get('/app/*', function (req, res, next) {
  console.log(req.session.name, "in app", userDetailObj)
  if (req.session.name != undefined){
    res.sendFile("index.html", options);
  }
  else{
    res.redirect('/login');
  }
});


/*
 |--------------------------------------------------------------------------
 | Login with Google
 |--------------------------------------------------------------------------
*/
app.post('/reports', function(req, res, next){
  console.log("reports loading", req.session.name);
});

app.post('/auth/google', function(req, res) {
  console.log("in request");
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
      userDetailObj = response.body;
      req.session.name = response.body.email
      res.send({ token: token, userDetails : response.body });

    });
  });
});


/*
 |--------------------------------------------------------------------------
 | Submit contact form in hubspot
 |--------------------------------------------------------------------------
*/
var hubURL = "https://api.hubapi.com/contacts/v1/contact/?hapikey=41e07798-d4bf-499b-81df-4dfa52317054";

app.post('/submitContactDetail', function(req, res) {
  console.log(req.body, "in submitContactDetail");
  var formData = {
    "properties": [
      {
        "property": "email",
        "value": req.body.email
      },
      {
        "property": "firstname",
        "value": req.body.uFname
      },
      {
        "property": "lastname",
        "value": req.body.uLname
      },
      {
        "property": "phone",
        "value": req.body.number
      },
      {
        "property": "message",
        "value": req.body.msg
      },
    ]
  }
  var args = {
    data: formData,
    headers:{"Content-Type": "application/json"}
  };
  console.log(args, "in args", formData.properties[0].value)
  
  client.post(hubURL, args, function(data,response) {
      if(Buffer.isBuffer(data)){
          data = data.toString('utf-8');
      }
      console.log(data, "data in client post");
      res.send(data);
  });
  

})

/*
 |--------------------------------------------------------------------------
 | Submit beta invites
 |--------------------------------------------------------------------------
*/
var hubURL = "https://api.hubapi.com/contacts/v1/contact/?hapikey=41e07798-d4bf-499b-81df-4dfa52317054";

app.post('/submitBetaInviteDetails', function(req, res) {
  console.log(req.body, "in submitBetaInviteDetails");
  var formData = {
    "properties": [
      {
        "property": "email",
        "value": req.body.email
      },
      {
        "property": "firstname",
        "value": req.body.uFname
      },
      {
        "property": "lastname",
        "value": req.body.uLname
      },
      {
        "property": "company",
        "value": req.body.company
      },
      {
        "property": "message",
        "value": req.body.reason
      },
    ]
  }
  var args = {
    data: formData,
    headers:{"Content-Type": "application/json"}
  };
  console.log(args, "in args", formData.properties[0].value)
  
  client.post(hubURL, args, function(data,response) {
      if(Buffer.isBuffer(data)){
          data = data.toString('utf-8');
      }
      console.log(data, "data in client post");
      res.send(data);
  });
  
})


app.listen(port, function(){
  console.log('Express Server running at port', this.address().port);
});



/*
 |--------------------------------------------------------------------------
 | Error Handlers
 |--------------------------------------------------------------------------
*/

// catch 404 and forward to error handler
app.use(function(req, res, next) {
  var err = new Error('Page Not Found');
  err.status = 404;
  next(err);
});

// development error handler
// will print stacktrace
if (app.get('env') === 'development') {
  app.use(function(err, req, res, next) {
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
app.use(function(err, req, res, next) {
  res.status(err.status || 500);
  var filePath = __dirname + '/public/website/views/error';
  res.render(filePath, {
    message: err.message,
    error: {}
  });
});

module.exports = app;