express = require('express')
path = require('path')
router = express.Router()

dirName = path.resolve(__dirname, '..', '..')

options = {
  root: dirName + '/webapp/views',
  dotfiles: 'deny',
  headers:
    'x-timestamp': Date.now(),
    'x-sent': true
}

router.get '/app/*', (req, res, next) ->
  if req.session.name != undefined
    res.sendFile 'index.html', options
  else
    res.redirect '/login'

router.get '/thanks', (req, res, next) ->
  res.sendFile 'thanks.html', options

router.post '/logout', (req, res, next) ->
  req.session.destroy()
  res.json status: 'success'

module.exports = router
