'use strict'

loginController = ($scope, $rootScope, $http, loginService) ->

  $scope.login =
    'banner':
      'mainHead': 'Uh, oh!'
      'mainHead1': 'You can\'t go through because the app is invitation only.'

  $scope.form = {}

  $scope.hasWhiteSpace = (s) ->
    return /\s/g.test(s);

  $scope.onLoginSuccess = (response) ->
    $scope.user = {}
    if(angular.isUndefined(response.message))
      $scope.responseMsg = "Thanks! will get in touch with you soon"
    else
      $scope.responseMsg = response.message

  $scope.onLoginFailure = (response) ->
    console.log "call failed", response

  $scope.submitUserForm = ->
    $scope.responseMsg = "loading... Submitting Form"
    if $scope.form.$valid
      $scope.splitFirstAndLastName($scope.user.name)
      loginService.submitUserForm($scope.user, $scope.onLoginSuccess, $scope.onLoginFailure)

  $scope.splitFirstAndLastName = (name) ->
    if($scope.hasWhiteSpace(name))
      unameArr = name.split(" ");
      $scope.user.uFname = unameArr[0]
      $scope.user.uLname = unameArr[1]
    else
      $scope.user.uFname = name
      $scope.user.uLname = "   "

angular.module('giddhApp').controller 'loginController', loginController