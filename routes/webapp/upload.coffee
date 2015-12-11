settings = require('../util/settings')
router = settings.express.Router()

settings.express().use(settings.multer({storage: mStorage }).single('file'));
router.post '/:companyName', (req, res) ->
  url = settings.envUrl + 'company/' + req.params.companyName + '/import-master'
  settings.rest.post(url,
    multipart: true
    headers:
      'Auth-Key': req.session.authKey
      'X-Forwarded-For': res.locales.remoteIp
    data: 'datafile': settings.rest.file(req.file.path, null, req.file.size, null, req.file.mimetype))
  	.on 'complete', (data) ->
    	console.log 'data is', data
	    if data.status == 'error'
	      res.status 400
	    res.send data

module.exports = router