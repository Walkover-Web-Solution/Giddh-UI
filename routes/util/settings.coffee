module.exports.stringUtil = require('./stringUtil')
module.exports.express = require('express')
module.exports.path = require('path')
module.exports.router = module.exports.express.Router()
Client = require('node-rest-client').Client
module.exports.client = new Client()
module.exports.envUrl = process.env.API_URL || "http://54.169.180.68:8080/giddh-api/"
module.exports.googleKey = process.env.GOOGLE_KEY || "eWzLFEb_T9VrzFjgE40Bz6_l"
module.exports.twitterKey = process.env.TWITTER_KEY || "w64afk3ZflEsdFxd6jyB9wt5j"
module.exports.twitterSecret = process.env.TWITTER_SECRET || "62GfvL1A6FcSEJBPnw59pjVklVI4QqkvmA1uDEttNLbUl2ZRpy"

module.exports.linkedinKey = process.env.LINKEDIN_KEY || "75urm0g3386r26"
module.exports.linkedinSecret = process.env.LINKEDIN_SECRET || "3AJTvaKNOEG4ISJ0"

module.exports.request = require('request')
