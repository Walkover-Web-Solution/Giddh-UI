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
var envUrl = process.env.ENVURL || "http://localhost:9292/giddh-api/";

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


console.log("dir in server", __dirname)

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


/**/
// do not remove code from this position
var appRoutes = require('./routes/webapp/main');
app.use('/', appRoutes);


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

app.get('/', function (req, res, next) {
  res.sendFile("index.html", options1);
});
app.get('/index', function (req, res, next) {
  res.sendFile("index.html", options1);
});
app.get('/beta', function (req, res, next) {
  res.sendFile("beta.html", options1);
});
app.get('/pricing', function (req, res, next) {
  res.sendFile("pricing.html", options1);
});
app.get('/privacy', function (req, res, next) {
  res.sendFile("privacy.html", options1);
});
app.get('/terms', function (req, res, next) {
  res.sendFile("terms.html", options1);
});
app.get('/why-giddh', function (req, res, next) {
  res.sendFile("whyGiddh.html", options1);
});
app.get('/login', function (req, res, next) {
  res.sendFile("login_back.html", options1);
});


/*
 |--------------------------------------------------------------------------
 | Custom functions get random string for company unique name
 |--------------------------------------------------------------------------
 */
function getRandomString(cun, uun) {
  var userUN, cmpUN, d, n, randomGenerate, stringss, randomString;

  userUN = removeSpecialCharacters(uun);
  cmpUN = removeSpecialCharacters(cun);
  d = new Date();
  n = d.getTime().toString();
  randomGenerate = getSixCharRandom();
  stringss = [userUN, cmpUN, n, randomGenerate];
  randomString = stringss.join("");
  return randomString;
}

function removeSpecialCharacters(str) {
  var finalString = str.replace(/[^a-zA-Z0-9]/g, "");
  finalString = finalString.substr(0, 6).toLowerCase();
  return finalString;
}

function getSixCharRandom() {
  var randomGenerate = Math.random().toString(36).replace(/[^a-zA-Z0-9]+/g, '').substr(0, 6);
  return randomGenerate;
}


/*
 |--------------------------------------------------------------------------
 | hit APIs for get data getBasicDetails
 |--------------------------------------------------------------------------
 */
//some universal var for hitting apis
var onlySmpHead = {
  headers: {"Content-Type": "application/json"}
}


app.get('/getCompanyList', function (req, res, next) {
  console.log("in get getCompanyList");
  var onlyAuthHead = {
    headers: {"Auth-Key": req.session.name}
  }
  var hUrl = envUrl + "users/" + userDetailObj.userUniqueName + "/companies";
  http://54.169.180.68:8080/giddh-api/users/ravisoni/companies

      client.get(hUrl, onlyAuthHead, function (data, response) {
        console.log(data, "data in company list for user");
        res.send(data);
      });

});

//get details of a single company
app.get('/getCompanyDetails', function (req, res) {
  console.log("in get getBasicDetails");
});

//create new company
app.post('/createCompany', function (req, res) {
  console.log("in createCompany", req.body)
  hUrl = envUrl + "company/";

  req.body.uniqueName = getRandomString(req.body.name, req.body.city)

  console.log("randomString", req.body.uniqueName)
  args = {
    headers: {
      "Auth-Key": req.session.name,
      "Content-Type": "application/json"
    },
    data: req.body
  }

  console.log("making req", args)
  client.post(hUrl, args, function (data, response) {
    console.log(data, "data in company list for user");
    res.send(data);
  });
})

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
          req.session.name = data.body.authKey
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


/*
 |--------------------------------------------------------------------------
 | Submit contact form in hubspot
 |--------------------------------------------------------------------------
 */
var hubURL = "https://api.hubapi.com/contacts/v1/contact/?hapikey=41e07798-d4bf-499b-81df-4dfa52317054";

app.post('/submitContactDetail', function (req, res) {
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
    headers: {"Content-Type": "application/json"}
  };
  console.log(args, "in args", formData.properties[0].value)

  client.post(hubURL, args, function (data, response) {
    if (Buffer.isBuffer(data)) {
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

app.post('/submitBetaInviteDetails', function (req, res) {
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
    headers: {"Content-Type": "application/json"}
  };
  console.log(args, "in args", formData.properties[0].value)

  client.post(hubURL, args, function (data, response) {
    if (Buffer.isBuffer(data)) {
      data = data.toString('utf-8');
    }
    console.log(data, "data in client post");
    res.send(data);
  });

})


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