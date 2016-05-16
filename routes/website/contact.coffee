settings = require('../util/settings')
router = settings.express.Router()
# sendgrid
sendgrid  = require('sendgrid')(settings.sendGridKey);

# hubURL = 'https://api.hubapi.com/contacts/v1/contact/?hapikey=41e07798-d4bf-499b-81df-4dfa52317054'

# send email to user
sendEmailToUser =(data) ->
  console.log "user email", data
  email = new (sendgrid.Email)(
    to: data.email
    toname: data.name
    from: 'shubhendra@giddh.com'
    fromname: 'Shubhendra Agrawal'
    subject: 'Giddh Team'
    html: '<p>Dear '+data.uFname+',</p><p>Thanks for showing your interest</p><p>We will get in touch with you shortly!</p><p></p>'
    )
  sendgrid.send email, (err, json) ->
    if err
      return console.error(err)
    console.log "sendEmailToUser:", json

# send email to user
sendEmailToGiddhTeam =(data) ->
  console.log "sendEmailToGiddhTeam", data
  email = new (sendgrid.Email)(
    to: 'shubhendra@giddh.com'
    from: data.email
    fromname: data.name
    subject: 'Contact Form Query from website'
    html: '<p>Name: '+data.name+'</p><p>Number: '+data.number+'</p><p>Message: '+data.message+'</p>'
  )
  sendgrid.send email, (err, json) ->
    if err
      return console.error(err)
    console.log "sendEmailToGiddhTeam:", json

router.post '/submitDetails', (req, res) ->
  # send email by sendgrid to user
  sendEmailToUser(req.body)
  sendEmailToGiddhTeam(req.body)
  data =
    status: "success"
    message: "Form submitted successfully! We will get in touch with you soon"
  res.send(data)



  # hubspot commented
  # formData =
  #   'properties': [
  #     {
  #       'property': 'email',
  #       'value': req.body.email
  #     }
  #     {
  #       'property': 'firstname',
  #       'value': req.body.uFname
  #     }
  #     {
  #       'property': 'lastname',
  #       'value': req.body.uLname
  #     }
  #     {
  #       'property': 'company',
  #       'value': req.body.company
  #     }
  #     {
  #       'property': 'message',
  #       'value': req.body.message
  #     }
  #   ]
  # args = {
  #   data: formData
  #   headers:
  #     'Content-Type': 'application/json'
  # }

  # settings.client.post hubURL, args, (data) ->
  #   if Buffer.isBuffer(data)
  #     data = data.toString('utf-8')
  #   res.send data

module.exports = router
