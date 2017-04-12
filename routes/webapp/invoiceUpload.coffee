settings = require('../util/settings')
rest = require('restler')
router = settings.express.Router()


# upload logo
router.post '/', (req, res) ->
  url = settings.envUrl + 'company/' + req.body.company + '/ledger/upload'
  rest.post(url,
    multipart: true
    headers:
      'Auth-Key': req.session.authKey
      'X-Forwarded-For': res.locales.remoteIp
    data:
      'file': rest.file(req.file.path, req.file.path, req.file.size, null, req.file.mimetype)
  ).on 'complete', (data) ->
#    console.log 'after upload data is', data
    res.send data


module.exports = router