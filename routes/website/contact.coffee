settings = require('../util/settings')
router = settings.express.Router()

hubURL = 'https://api.hubapi.com/contacts/v1/contact/?hapikey=41e07798-d4bf-499b-81df-4dfa52317054'

router.post '/submitDetails', (req, res) ->
  formData =
    'properties': [
      {
        'property': 'email',
        'value': req.body.email
      }
      {
        'property': 'firstname',
        'value': req.body.uFname
      }
      {
        'property': 'lastname',
        'value': req.body.uLname
      }
      {
        'property': 'company',
        'value': req.body.company
      }
      {
        'property': 'message',
        'value': req.body.reason
      }
    ]
  args = {
    data: formData
    headers:
      'Content-Type': 'application/json'
  }

  settings.client.post hubURL, args, (data) ->
    if Buffer.isBuffer(data)
      data = data.toString('utf-8')
    res.send data

module.exports = router
