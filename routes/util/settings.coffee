module.exports.stringUtil = require('./stringUtil')
module.exports.express = require('express')
module.exports.path = require('path')
module.exports.router = module.exports.express.Router()
Client = require('node-rest-client').Client
module.exports.client = new Client()

# for live open below line
module.exports.giddhPdfPath = "/home/app-downloads/"
# for dev open below line
# module.exports.giddhPdfPath = "/tmp/"

module.exports.envUrl = process.env.API_URL || "http://apidev.giddh.com/"
# module.exports.envUrl = "http://apidev.giddh.com/"
#module.exports.envUrl = "http://localapi.giddh.com/"
module.exports.googleKey = process.env.GOOGLE_KEY || "eWzLFEb_T9VrzFjgE40Bz6_l"
module.exports.twitterKey = process.env.TWITTER_KEY || "w64afk3ZflEsdFxd6jyB9wt5j"
module.exports.twitterSecret = process.env.TWITTER_SECRET || "62GfvL1A6FcSEJBPnw59pjVklVI4QqkvmA1uDEttNLbUl2ZRpy"
module.exports.cdnUrl = process.env.CDN_URL || ""
module.exports.linkedinKey = process.env.LINKEDIN_KEY || "75urm0g3386r26"
module.exports.linkedinSecret = process.env.LINKEDIN_SECRET || "3AJTvaKNOEG4ISJ0"
module.exports.sendGridKey = 'SG.5FId5yqnSL-_oKb-_enkQg.iV8QkRJKyKK0NScGRRq-SyiHNEFCdN_kKkJ8DYS4ZUI'
module.exports.mongoUrl = process.env.MONGODB_URL || 'mongodb://localhost/giddhDB'
module.exports.getOtpKey = "73k6G_GDzvhy4XE33EQCaKUnC0PHwEZBvf0qsZ3Q9S3ZBcXH-f_6JT_4fH-Qx1Y5LxIIwzqy7cFQVMoyUSXBfLL5WBX6oQWifweWIQlJQ8YkRZ1lAmu3oqwvNJXP1Y5ZTXDHO1IV5-Q63zwNbzxTFw=="
module.exports.geoIp = require('geoip-lite')
module.exports.request = require('request')