var express = require('express');
var path = require('path');
var router = express.Router();

__dirname = path.resolve(__dirname, "..");

console.log("page called appusers")

var options = {
  root: __dirname + '/public/webapp/views',
  dotfiles: 'deny',
  headers: {
      'x-timestamp': Date.now(),
      'x-sent': true
  }
};

console.log(options.root, "dir in app user", __dirname)

router.get('/app/*', function (req, res, next) {
  console.log(req.session.name, "in app")
  if (req.session.name != undefined){
    res.sendFile("index.html", options);
  }
  else{
    res.redirect('/login');
  }
});

// thanks page
router.get('/thanks', function(req, res, next) {
  res.sendFile("thanks.html", options);
});

/*logout*/
router.post('/logout', function(req, res, next){
  console.log(req.body, "in logout request")
  req.session.destroy();
  res.json({ status: 'success' });
});



module.exports = router;