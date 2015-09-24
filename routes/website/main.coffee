express = require('express')
path = require('path')
router = express.Router()
dirName = path.resolve(__dirname, '..', '..')
console.log __dirname
console.log dirName

options = {
  root: dirName + '/website/views',
  dotfiles: 'deny',
  headers:
    'x-timestamp': Date.now(),
    'x-sent': true
}

router.get '/', (req, res) ->
  res.sendFile 'index.html', options

router.get '/index', (req, res) ->
  res.sendFile 'index.html', options

router.get '/beta', (req, res) ->
  res.sendFile 'beta.html', options

router.get '/pricing', (req, res) ->
  res.sendFile 'pricing.html', options

router.get '/privacy', (req, res) ->
  res.sendFile 'privacy.html', options

router.get '/terms', (req, res) ->
  res.sendFile 'terms.html', options

router.get '/why-giddh', (req, res) ->
  res.sendFile 'whyGiddh.html', options


router.get '/login', (req, res) ->
  res.sendFile 'login_back.html', options

module.exports = router
