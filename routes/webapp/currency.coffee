express = require('express')
path = require('path')
router = express.Router()
Client = require('node-rest-client').Client;
client = new Client();
envUrl = "http://54.169.180.68:8080/giddh-api/";

router.get '/', (req, res) ->
  console.log 'we are here to get currency list'
  hUrl = envUrl + 'currency'
  args = headers: 'Content-Type': 'application/json'
  client.post hUrl, args, (data) ->
    console.log 'currency list we get'
    res.send data

module.exports = router