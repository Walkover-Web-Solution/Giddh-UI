module.exports.stringUtil = require('./stringUtil')
module.exports.express = require('express')
module.exports.path = require('path')
module.exports.router = module.exports.express.Router()
Client = require('node-rest-client').Client
module.exports.client = new Client()
module.exports.envUrl = process.env.API_URL || "http://54.169.180.68:8080/giddh-api/"
module.exports.googleKey = process.env.GOOGLE_KEY || "VmX7Zrg3vavZ2tOPP4jl3DYb"
module.exports.request = require('request')

