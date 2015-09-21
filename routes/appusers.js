var express = require('express');
var router = express.Router();

console.log("page called appusers")

var options = {
  root: __dirname + '/public/webapp/views',
  dotfiles: 'deny',
  headers: {
      'x-timestamp': Date.now(),
      'x-sent': true
  }
};
router.get('/app/*', function (req, res, next) {
  console.log(req.session.name, "in app", userDetailObj)
  if (req.session.name != undefined){
    res.sendFile("index.html", options);
  }
  else{
    res.redirect('/login');
  }
});

/*logout*/
router.post('/logout', function(req, res, next){
  console.log(req.body, "in logout request")
  req.session.destroy();
  res.json({ status: 'success' });
});


module.exports = router;
