'use strict'

loginController = ($scope, $rootScope, $http, $timeout, $auth, localStorageService) ->
  
  $scope.authenticate = (provider) ->
    $auth.authenticate(provider).then((response) ->
      console.log "in authenticate status", response
      
      if response.data.result.status is "error"
        #user is not registerd with us
        toastr[response.data.result.status](response.data.result.error);
        $timeout (->
          window.location = "/beta"
        ), 3000
      else
        #user is registered and redirect it to app
        localStorageService.set("_userDetails", response.data.userDetails);
        window.location = "/app/"

      

      #window.location = "/app/"
    ).catch (response) ->
      console.log response


  #webpage data
  $scope.login = 'banner':
    'mainHead': 'Welcome to the world of'
    'mainHead1': 'secure and online accounting'

  rand = Math.random() * 4
  window.onload = ->
    alertMsg parseInt(rand)
    return

  alertMsg = ->
    $timeout alertMsg, 5000
    id = parseInt(Math.random() * 3)
    ele = angular.element(document.querySelector('#tipscnt'))
    switch id
      when 0
        ele.html 'Tip : "Every transaction has a statement."'
      when 1
        ele.html 'Tip : "Your account book will never contain your name."'
      when 2
        ele.html 'Tip : "Every statement will have an entry."'
      when 3
        ele.html 'Tip : "Ateast two things will happen in every statement."'
      when 3
        ele.html 'Tip : "Accounting works on double entry system"'
    return

    $timeout alertMsg, 5000


angular.module('giddhApp').controller 'loginController', loginController