var express = require('express');
var path = require('path');
var router = express.Router();

__dirname = path.resolve(__dirname, "..", "..");

var options = {
  root: __dirname + '/public/webapp/views',
  dotfiles: 'deny',
  headers: {
    'x-timestamp': Date.now(),
    'x-sent': true
  }
};
console.log(options.root, "webapp views Route*******************************")
router.get('/app/*', function (req, res, next) {
  if (req.session.name != undefined) {
    res.sendFile("index.html", options);
  }
  else {
    res.redirect('/login');
  }
});

// thanks page
router.get('/thanks', function (req, res, next) {
  res.sendFile("thanks.html", options);
});

/*logout*/
router.post('/logout', function (req, res, next) {
  req.session.destroy();
  res.json({status: 'success'});
});

module.exports = router;