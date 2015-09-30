module.exports.stringUtil = require('./stringUtil')
module.exports.express = require('express')
module.exports.path = require('path')
module.exports.router = module.exports.express.Router()
Client = require('node-rest-client').Client;
module.exports.client = new Client()
module.exports.envUrl = "http://localhost:9292/giddh-api/"
module.exports.request = require('request')
