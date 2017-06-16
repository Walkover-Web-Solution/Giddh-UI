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
    console.log 'after upload data is', data
    if data.status == 'success'
      res.send data
    else if data.status == 'error'
      res.status(400).send(data)
    else
      error = {
        message:"Upload failed, please check that size of the file is less than 1mb"
      }
      res.status(400).send(error);


module.exports = router