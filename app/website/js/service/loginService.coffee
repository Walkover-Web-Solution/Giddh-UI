'use strict'

angular.module('giddhApp').service 'loginService', ($resource) ->
  Login = $resource('/contact/submitDetails', {}, {sendInvite: {method: 'POST'}})

  loginService =
    submitUserForm: (user, onSuccess, onFailure) ->
      Login.sendInvite({uFname: user.uFname, uLname: user.uLname, email: user.email, company: user.company, reason: user.reason},
        onSuccess, onFailure)

  loginService