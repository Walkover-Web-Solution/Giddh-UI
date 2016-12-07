settings = require('../util/settings')
router = settings.express.Router({mergeParams: true})
himalaya = require('himalaya')



router.post '/', (req, res) ->
	console.log "parser"
	json = himalaya.parse(req.body.html)

	# createModel = (elem, index) ->
	# 	section = {}
	# 	section.styles = elem.attributes['style'] || ''
	# 	@recurse = (children) ->
	# 		elements = []
	# 		children.forEach(
	# 			(child) ->
	# 				element = {}
	# 				element.styles = child.attributes['style'] || ''
	# 				element.type = child.
	# 		)
					


	# json.forEach((elem, index)-> 


	# )



	res.send json


module.exports = router