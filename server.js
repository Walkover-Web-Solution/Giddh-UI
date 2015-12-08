var settings = require('./public/routes/util/settings');
var favicon = require('serve-favicon');
var logger = require('morgan');
var cookieParser = require('cookie-parser');
var bodyParser = require('body-parser');
var fs = require('fs');
var session = require('express-session');
var engines = require('consolidate');
var request = require('request');
var cors = require('cors')
var requestIp = require('request-ip');
var multer   =  require('multer');

var app = settings.express();

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
app.use(settings.express.static(settings.path.join(__dirname, 'public')));
app.use('/bower_components', settings.express.static(__dirname + '/bower_components'));
app.use('/public', settings.express.static(__dirname + '/public'));

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

global.clientIp = "";
app.use(function (req, res, next) {
  clientIp = requestIp.getClientIp(req);
  res.locales ={
    "siteTitle": "Giddh ~ Accounting at its Rough!",
    "author": "The Mechanic",
    "description": "Giddh App description",
    "remoteIp": requestIp.getClientIp(req),
  }
  next();
});

// do not remove code from this position
var login = require('./public/routes/website/login');
var contact = require('./public/routes/website/contact');
var websiteRoutes = require('./public/routes/website/main');

app.use('/auth', login);
app.use('/contact', contact);
app.use('/', websiteRoutes);

var currency = require('./public/routes/webapp/currency');
var location = require('./public/routes/webapp/location');
var company = require('./public/routes/webapp/company');
var groups = require('./public/routes/webapp/groups');
var accounts = require('./public/routes/webapp/accounts');
var ledgers = require('./public/routes/webapp/ledgers');
var appRoutes = require('./public/routes/webapp/main');
var users = require('./public/routes/webapp/users');
var roles = require('./public/routes/webapp/roles');
var trialBalance = require('./public/routes/webapp/trialBal');

app.use('/currency', currency);
app.use('/users', users);
app.use('/roles', roles);
app.use('/location', location);
app.use('/company', company);
app.use('/company/:companyUniqueName/groups', groups);
app.use('/company/:companyUniqueName/groups/:groupUniqueName/accounts', accounts);
app.use('/company/:companyUniqueName/groups/:groupUniqueName/accounts/:accountUniqueName/ledgers', ledgers);
app.use('/company/:companyUniqueName/trial-balance',trialBalance);
app.use('/', appRoutes);



app.use(multer({ dest: './uploads/'}).single('file'));
app.post('/fileUpload',function(req,res){
  console.log ("response", req.file)
  res.end("File is uploaded")

  // { 
  //   fieldname: 'photo',
  //   originalname: '1-3def184ad8f4755ff269862ea77393dd125-356663713651353333393531Text.csv',
  //   encoding: '7bit',
  //   mimetype: 'text/csv',
  //   destination: './uploads/',
  //   filename: '82af97a2303ea669e71952239fe78502',
  //   path: 'uploads/82af97a2303ea669e71952239fe78502',
  //   size: 85 
  // }

  var formData = {
    // Pass a simple key-value pair 
    my_field: req.file.fieldname,

    // Pass multiple values /w an Array 
    attachments: [
      fs.createReadStream(__dirname + '/' +req.file.path)
    ]
  };
  var options = {
    url: settings.envUrl + 'company/afafagindore14437655102430wduc5/import-master',
    headers: {
      'Auth-Key': req.session.authKey,
      'X-Forwarded-For': res.locales.remoteIp
    },
    formData: formData
  };

  request.post(options, function optionalCallback(err, httpResponse, body) {
    if (err) {
      return console.error('upload failed:', err);
    }
    console.log('Upload successful!  Server responded with:', body);
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
  console.log (err, "error")
  res.status(err.status || 500);
  var filePath = __dirname + '/public/website/views/error';
  res.render(filePath, {
    message: err.message,
    error: {}
  });
});

module.exports = app;