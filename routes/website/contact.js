var express = require('express');
var router = express.Router();
var Client = require('node-rest-client').Client;
var client = new Client();

var hubURL = "https://api.hubapi.com/contacts/v1/contact/?hapikey=41e07798-d4bf-499b-81df-4dfa52317054";

router.post('/submitDetails', function (req, res) {
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

module.exports = router;