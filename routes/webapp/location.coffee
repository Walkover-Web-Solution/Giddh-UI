settings = require('../util/settings')
router = settings.express.Router()

router.get '/search', (req, res) ->
  googleApi = 'http://maps.googleapis.com/maps/api/geocode/json?'
  if req.query.country != undefined
    googleApi = googleApi + 'address=' + req.query.queryString + '&components=country:' + req.query.country + '|administrative_area:' + req.query.queryString
  else if req.query.administrator_level != undefined
    googleApi = googleApi + 'address=' + req.query.queryString + '&components=administrative_area:' + req.query.administrator_level
  else
    googleApi = googleApi + 'components=country:' + req.query.queryString
  settings.request.get googleApi, (err, response) ->
    if data.status == 'error'
      res.status(response.statusCode)
    res.send response.body

module.exports = router