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
var rest = require('restler');

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

var storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, './uploads/')
  },
  filename: function (req, file, cb) {
    console.log("In Multer")
    cb(null, Date.now() + '.xml')
  }
})

app.use(multer({ storage: storage }).single('file'));

app.post('/fileUpload/:companyName',function(req,res){
  var url = "http://localhost:9292/giddh-api/company/" + req.params.companyName + "/import-master"
  rest.post(url, {
    multipart: true,
    headers: {'Auth-Key': req.session.authKey},
    data: {
      'datafile': rest.file(req.file.path, null, req.file.size, null, req.file.mimetype)
    }
  }).on('complete', function(data) {
    console.log("data is",data);
    res.send(data)
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