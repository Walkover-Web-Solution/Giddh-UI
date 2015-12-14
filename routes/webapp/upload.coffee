settings = require('../util/settings')
rest = require('restler')
router = settings.express.Router()

router.post '/:companyName/master', (req, res) ->
  console.log "Master file is: ", req.file
  url = settings.envUrl + 'company/' + req.params.companyName + '/import-master'
  rest.post(url,
    multipart: true
    headers:
      'Auth-Key': req.session.authKey
      'X-Forwarded-For': res.locales.remoteIp
    data:
      'datafile': rest.file(req.file.path, req.file.path, req.file.size, null, req.file.mimetype)
  ).on 'complete', (data) ->
    console.log 'after upload data is', data
  mRes =
    status: 'Success'
    body: message: 'Uploaded File is being processed, you can check status later'
  res.send mRes

router.post '/:companyName/daybook', (req, res) ->
  console.log "Daybook file is: ", req.file
  url = settings.envUrl + 'company/' + req.params.companyName + '/import-daybook'
  rest.post(url,
    multipart: true
    headers:
      'Auth-Key': req.session.authKey
      'X-Forwarded-For': res.locales.remoteIp
    data:
      'datafile': rest.file(req.file.path, req.file.path, req.file.size, null, req.file.mimetype)
  ).on 'complete', (data) ->
    console.log 'after upload data is', data
  mRes =
    status: 'Success'
    body: message: 'Uploaded File is being processed, you can check status later'
  res.send mRes

module.exports = router