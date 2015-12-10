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

# router.post '/fileUpload/:companyName', (req, res) ->
#   url = settings.envUrl + 'company/' + req.params.companyName + '/import-master'
#   rest.post(url,
#     multipart: true
#     headers:
#       'Auth-Key': req.session.authKey
#       'X-Forwarded-For': res.locales.remoteIp
#     data: 'datafile': rest.file(req.file.path, null, req.file.size, null, req.file.mimetype)).on 'complete', (data) ->
#     console.log 'data is', data
#     if data.status == 'error'
#       res.status 400
#     res.send data

module.exports = router
