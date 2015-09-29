settings = require('../util/settings')
router = settings.express.Router()

router.get '/search', (req, res) ->
  console.log req.query
  googleApi = 'http://maps.googleapis.com/maps/api/geocode/json?'
  if req.query.country != undefined
    console.log "found country parameter"
    googleApi = googleApi + 'address=' + req.query.queryString + '&components=country:' + req.query.country + '|administrative_area:' + req.query.queryString
  else if req.query.administrator_level != undefined
    googleApi = googleApi + 'address=' + req.query.queryString + '&components=administrative_area:' + req.query.administrator_level
  else
    googleApi = googleApi + 'components=country:' + req.query.queryString
  console.log googleApi
  settings.request.get googleApi, (err, response) ->
    res.send response.body

module.exports = router