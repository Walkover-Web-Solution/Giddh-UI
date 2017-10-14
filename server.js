var settings = require('./public/routes/util/settings');
var favicon = require('serve-favicon');
var logger = require('morgan');
var cookieParser = require('cookie-parser');
var bodyParser = require('body-parser');
var fs = require('fs');
var session = require('express-session');
var engines = require('consolidate');
var request = require('request');
var jwt = require('jwt-simple');

var Client = require('node-rest-client').Client; 
var client = new Client();

//enabling cors
var cors = require('cors')
var requestIp = require('request-ip');
var multer = require('multer');
var rest = require('restler');
// var Raven = require('raven');

var app = settings.express();

app.disable('x-powered-by');

var port = process.env.PORT || 8000;
//enabling cors
//app.use(cors())


//set engine
app.set('public', __dirname + '/public/');
app.engine('html', engines.mustache);
app.set('view engine', 'html');

app.use(favicon(__dirname + '/app/website/images/favicon.ico'));

app.use(logger('dev'));
app.use(bodyParser.json({limit: '10mb'}));
app.use(bodyParser.urlencoded({extended: true}));
app.use(cookieParser());
app.use(settings.express.static(settings.path.join(__dirname, 'public')));
app.use('/app/bower_components', settings.express.static(__dirname + '/bower_components'));
app.use('/bower_components', settings.express.static(__dirname + '/bower_components'));
app.use('/node_modules', settings.express.static(__dirname + '/node_modules'));
app.use('/public', settings.express.static(__dirname + '/public'));

//set ttl for session expiry, format : milliseconds * seconds * minutes
sessionTTL = 1000*60*30

app.use(session({
  secret: "keyboardcat",
  name: "userAuth",
  resave: true,
  saveUninitialized: true,
  cookie: {
    path:'/',
    secure: false,
    maxAge: sessionTTL,
    domain:'giddh.com',
    httpOnly: false
  }
}));

// some global variables
global.clientIp = "";
app.use(function (req, res, next) {
  clientIp = requestIp.getClientIp(req);
  res.locales = {
    "siteTitle": "Giddh ~ Accounting at its Rough!",
    "author": "The Mechanic",
    "description": "Giddh App description",
    "remoteIp": requestIp.getClientIp(req),
  }
  req.session._garbage = Date();
  req.session.touch();
  next();
})

//to allow cookie sharing across subdomains
app.use(function(req, res, next) {
    res.header('Access-Control-Allow-Credentials', true);
    res.header('Access-Control-Allow-Origin', req.headers.origin);
    res.header('Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE,PATCH,OPTIONS');
    res.header('Access-Control-Allow-Headers', 'X-Requested-With, X-HTTP-Method-Override, Content-Type, Accept, authorization');
    next();

});

// do not remove code from this position
var login = require('./public/routes/website/login');
var contact = require('./public/routes/website/contact');
var websiteRoutes = require('./public/routes/website/main');

app.use('/app/auth', login);
app.use('/contact', contact);
app.use('/app/api', websiteRoutes);

global.mStorage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, './uploads/')
  },
  filename: function (req, file, cb) {
    switch (file.mimetype){
      case 'image/*' :
        cb(null, file.originalname)
        break;
      case'application/vnd.ms-excel' : 
        cb(null, Date.now() + '.xls')
        break;
      case'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' : 
        cb(null, Date.now() + '.xlsx')
        break;
      default:
        cb(null, file.originalname)
    }
  }
})


// disable browser cache
app.use(function (req, res, next) {
    res.header('Cache-Control', 'private, no-cache, no-store, must-revalidate');
    res.header('Expires', '-1');
    res.header('Pragma', 'no-cache');
    next()
});



var parseUploads = multer({storage: mStorage}).single('file');

var currency = require('./public/routes/webapp/currency');
var location = require('./public/routes/webapp/location');
var company = require('./public/routes/webapp/company');
var groups = require('./public/routes/webapp/groups');
var accounts = require('./public/routes/webapp/accounts');
var accountsV2 = require('./public/routes/webapp/accountsV2');
var ledgers = require('./public/routes/webapp/ledgers');
var appRoutes = require('./public/routes/webapp/main');
var users = require('./public/routes/webapp/users');
var roles = require('./public/routes/webapp/roles');
var trialBalance = require('./public/routes/webapp/trialBal');
var balanceSheet = require('./public/routes/webapp/balancesheet');
var upload = require('./public/routes/webapp/upload');
var profitLoss = require('./public/routes/webapp/profitLoss')
var reports = require('./public/routes/webapp/reports')
var coupon = require('./public/routes/webapp/coupon')
var yodlee = require('./public/routes/webapp/yodlee')
var ebanks  = require('./public/routes/webapp/ebanks')
var magicLink = require('./public/routes/webapp/magic')
var timetest = require('./public/routes/webapp/timetest')
var invoice = require('./public/routes/webapp/invoices')
var templates = require('./public/routes/webapp/templates')
var proforma = require('./public/routes/webapp/proformas')
var placeholders = require('./public/routes/webapp/placeholders')
var inventory = require('./public/routes/webapp/inventory')
var adminPanel = require('./public/routes/adminPanel/adminPanel')
var recEntry = require('./public/routes/webapp/recurringEntry')
var invoiceUpload = require('./public/routes/webapp/invoiceUpload')
var stateDetails = require('./public/routes/webapp/stateDetails')
var invoiceModule = require('./invoice/invoiceModule')
var voucherModule = require('./voucher/voucherModule')
// var invoicePay = require('./public/routes/website/main')

app.use('/time-test', timetest);
app.use('/currency', currency);
app.use('/users', users);
app.use('/roles', roles);
app.use('/location', location);
app.use('/company', company);
app.use('/app/company/:companyUniqueName/placeholders', placeholders);
app.use('/company/:companyUniqueName/invoices', invoice);
app.use('/company/:companyUniqueName/proforma', proforma);
app.use('/company/:companyUniqueName/groups', groups);
app.use('/company/:companyUniqueName/accounts', accounts);
app.use('/v2/company/:companyUniqueName', accountsV2);
app.use('/company/:companyUniqueName/accounts/:accountUniqueName/ledgers', ledgers);
app.use('/company/:companyUniqueName/trial-balance', trialBalance);
app.use('/company/:companyUniqueName/balance-sheet', balanceSheet);
app.use('/upload-invoice',parseUploads, invoiceUpload);
app.use('/upload', parseUploads, upload);
app.use('/company/:companyUniqueName/stock-group', inventory)
app.use('/company/:companyUniqueName/profit-loss', profitLoss);
app.use('/company/:companyUniqueName/templates', templates);
app.use('/company/:companyUniqueName/recurring-entry', recEntry);
app.use('/company/:companyUniqueName', reports);
app.use('/coupon', coupon);
app.use('/yodlee', yodlee);
app.use('/ebanks', ebanks);
app.use('/admin', adminPanel);
app.use('/state-details', stateDetails);
app.use('/magic-link', magicLink);
app.use('/invoice-pay-request', websiteRoutes);
app.use('/invoice',invoiceModule);
app.use('/voucher',voucherModule);



// delete user session on logout
app.use('/logout', function(req, res){
  if(req.session.name){
    req.session.destroy()
    res.status(200).send({message:'user logged out'})
  }else{
    res.status(403).send({message:'user not found'})
  }
})

//return user-details
app.use('/fetch-user', function(req, res){
  var authHead, hUrl;
  authHead = {
    headers: {
      'Auth-Key': req.session.authKey,
      'Content-Type': 'application/json',
      'X-Forwarded-For': res.locales.remoteIp
    }
  };
  hUrl = settings.envUrl + 'users/' + req.session.name;
  return settings.client.get(hUrl, authHead, function(data, response) {
    if (data.status === 'error' || data.status === void 0) {
      res.status(response.statusCode);
    }
    return res.send(data);
  });
})

// serve verify email from email
app.use('/company/verify-email', function(req, res){
  res.sendFile(__dirname + '/public/website/views/verify-email.html')
});

//serve magic-link page
app.use('/magic', function(req, res){
  res.sendFile(__dirname + '/public/website/views/magic.html')
});

//serve invoice-pay page
app.use('/payment', function(req, res){
  res.sendFile(__dirname + '/public/website/views/payment.html')
});

//get user auth key
app.get('/userak', function(req, res){
  if(req.session.name){
    res.send(req.session.authKey)
  }else{
    res.status(403)
    res.send('Invalid User')
  }
})

// get session id and match with existing session
var getSession = function(req, res, next){
  var sessionId = req.query.sId;
  req.sessionStore.get(sessionId, function(err, session) {
  if (session) {
      // createSession() re-assigns req.session
      req.sessionStore.createSession(req, session)
    }
    next()
  })
}

//serve index.html, this has to come after *ALL* routes are defined
app.use('/', getSession, function(req, res){
  if(req.url.startsWith(settings.giddhPdfPath) && req.url.endsWith(".pdf")) {
    res.sendFile(req.url)
  } else if(req.session.name){
    res.sendFile(__dirname+ '/public/webapp/views/index.html')
  } else{
    res.status(404)
    //redirect according to environment
    res.redirect('http://giddh.com/')
  }
});


/*
 # set all route above this snippet
 # redirecting to 404 if page/route not found
*/
app.use(redirectUnmatched)
function redirectUnmatched(req, res) {
  var options = {
    root: __dirname + '/public/website/views',
    dotfiles: 'deny',
    headers:{
      'x-timestamp': Date.now(),
      'x-sent': true
    }
  }
  res.sendFile('404.html', options)
}

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
  console.log(err, "error")
  res.status(err.status || 500);
  var filePath = __dirname + '/public/website/views/error';
  res.render(filePath, {
    message: err.message,
    error: {}
  });
});


module.exports = app;

// http://stackoverflow.com/questions/6528876/how-to-redirect-404-errors-to-a-page-in-expressjs/9802006#9802006
