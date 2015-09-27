settings = require('../shared/settings')

dirName = settings.path.resolve(__dirname, '..', '..')
options = {
  root: dirName + '/website/views',
  dotfiles: 'deny',
  headers:
    'x-timestamp': Date.now(),
    'x-sent': true
}

settings.router.get '/', (req, res) ->
  res.sendFile 'index.html', options

settings.router.get '/index', (req, res) ->
  res.sendFile 'index.html', options

settings.router.get '/beta', (req, res) ->
  res.sendFile 'beta.html', options

settings.router.get '/pricing', (req, res) ->
  res.sendFile 'pricing.html', options

settings.router.get '/privacy', (req, res) ->
  res.sendFile 'privacy.html', options

settings.router.get '/terms', (req, res) ->
  res.sendFile 'terms.html', options

settings.router.get '/why-giddh', (req, res) ->
  res.sendFile 'whyGiddh.html', options


settings.router.get '/login', (req, res) ->
  res.sendFile 'login_back.html', options

module.exports = settings.router
