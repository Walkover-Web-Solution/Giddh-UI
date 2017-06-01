
var settings = require('../public/routes/util/settings');
var router = settings.express.Router({mergeParams: true})
	
var getTemplates = require('../invoice/api/controllers/getTemplatesCtrl')
var invoice = require('../invoice/api/controllers/invoice')


//router.post('/make-invoice',);
router.get('/get-templates', getTemplates.returnAllWithoutAuth)
router.post('/get-template',getTemplates.getById)
router.post('/download',invoice.downloadInvoice)

module.exports = router