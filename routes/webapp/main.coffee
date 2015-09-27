settings = require('../util/settings')
router = settings.express.Router()

dirName = settings.path.resolve(__dirname, '..', '..')

options = {
  root: dirName + '/webapp/views',
  dotfiles: 'deny',
  headers:
    'x-timestamp': Date.now(),
    'x-sent': true
}

router.get '/app/*', (req, res) ->
  if req.session.name != undefined
    res.sendFile 'index.html', options
  else
    res.redirect '/login'

router.get '/thanks', (req, res) ->
  res.sendFile 'thanks.html', options

router.post '/logout', (req, res) ->
  req.session.destroy()
  res.json status: 'success'

module.exports = router
