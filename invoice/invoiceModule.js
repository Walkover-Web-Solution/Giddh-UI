var settings = require('../public/routes/util/settings');
var router = settings.express.Router({mergeParams: true})	
var getTemplates = require('./api/controllers/getTemplatesCtrl')
var invoice = require('./api/controllers/invoice')

router.get('/template/getAll', getTemplates.returnAllWithoutAuth)
router.get('/template/:id',getTemplates.getById)
router.post('/download',invoice.downloadInvoice)

module.exports = router