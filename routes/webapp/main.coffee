settings = require('../shared/settings')

dirName = settings.path.resolve(__dirname, '..', '..')

options = {
  root: dirName + '/webapp/views',
  dotfiles: 'deny',
  headers:
    'x-timestamp': Date.now(),
    'x-sent': true
}

settings.router.get '/app/*', (req, res) ->
  if req.session.name != undefined
    res.sendFile 'index.html', options
  else
    res.redirect '/login'

settings.router.get '/thanks', (req, res) ->
  res.sendFile 'thanks.html', options

settings.router.post '/logout', (req, res) ->
  req.session.destroy()
  res.json status: 'success'

module.exports = settings.router
