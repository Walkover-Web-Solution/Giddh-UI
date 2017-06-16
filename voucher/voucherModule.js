
var settings = require('../public/routes/util/settings');
var router = settings.express.Router({mergeParams: true})
	
var reciept = require('./api/controllers/reciept')


router.post('/reciept/download',reciept.downloadReciept)

module.exports = router