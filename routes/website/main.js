var express = require('express');
var path = require('path');
var router = express.Router();

__dirname = path.resolve(__dirname, "..", "..");

var options = {
  root: __dirname + '/public/website/views',
  dotfiles: 'deny',
  headers: {
    'x-timestamp': Date.now(),
    'x-sent': true
  }
};

router.get('/', function (req, res) {
  res.sendFile("index.html", options);
});
router.get('/index', function (req, res) {
  res.sendFile("index.html", options);
});
router.get('/beta', function (req, res) {
  res.sendFile("beta.html", options);
});
router.get('/pricing', function (req, res) {
  res.sendFile("pricing.html", options);
});
router.get('/privacy', function (req, res) {
  res.sendFile("privacy.html", options);
});
router.get('/terms', function (req, res) {
  res.sendFile("terms.html", options);
});
router.get('/why-giddh', function (req, res) {
  res.sendFile("whyGiddh.html", options);
});
router.get('/login', function (req, res) {
  res.sendFile("login_back.html", options);
});

module.exports = router;