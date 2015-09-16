'use strict'

loginController = ($scope, $rootScope, $http, loginService) ->
  $scope.notHuman = false
  $scope.login =
    'banner':
      'mainHead': 'Uh, oh!'
      'mainHead1': 'You can\'t go through because the app is invitation only.'

  $scope.form = {}

  $scope.getRandomInt = (min, max) ->
    Math.floor(Math.random() * (max - min + 1)) + min

  $scope.rn1 = $scope.getRandomInt(1, 19)
  $scope.rn2 = $scope.getRandomInt(1, 19)

  $scope.isHuman = ->
    parseInt($scope.user.totalSum) == $scope.rn1 + $scope.rn2

  $scope.hasWhiteSpace = (s) ->
    return /\s/g.test(s)

  $scope.onLoginSuccess = (response) ->
    if(angular.isUndefined(response.message))
      $scope.responseMsg = "Thanks! will get in touch with you soon"
    else
      $scope.responseMsg = response.message

  $scope.onLoginFailure = (response) ->
    console.log "call failed", response

  $scope.submitUserForm = ->
    if $scope.form.$valid
      if($scope.isHuman())
        $scope.responseMsg = "loading... Submitting Form"
        $scope.splitFirstAndLastName($scope.user.name)
        loginService.submitUserForm($scope.user, $scope.onLoginSuccess, $scope.onLoginFailure)
      else
        $scope.notHuman = true
        $scope.notHumanMessage = "You are not a human being!"

  $scope.splitFirstAndLastName = (name) ->
    if($scope.hasWhiteSpace(name))
      unameArr = name.split(" ")
      $scope.user.uFname = unameArr[0]
      $scope.user.uLname = unameArr[1]
    else
      $scope.user.uFname = name
      $scope.user.uLname = "   "

angular.module('giddhApp').controller 'loginController', loginController