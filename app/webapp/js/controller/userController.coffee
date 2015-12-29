"use strict"

userController = ($scope, $rootScope, toastr, userServices) ->
  $scope.userAuthKey = undefined

  $scope.getUserAuthKey = () ->
    if not _.isUndefined($rootScope.basicInfo)
      userServices.getKey($rootScope.basicInfo.uniqueName).then($scope.getUserAuthKeySuccess,
          $scope.getUserAuthKeyFailure)

  $scope.getUserAuthKeySuccess = (res) ->
    $scope.userAuthKey = res.body

  $scope.getUserAuthKeyFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  $scope.regenerateKey = () ->
    userServices.generateKey($rootScope.basicInfo.uniqueName).then($scope.generateKeySuccess,
        $scope.generateKeyFailure)

  $scope.generateKeySuccess = (res) ->
    $scope.userAuthKey = res.body.authKey

  $scope.generateKeyFailure = (res) ->
    toastr.error(res.data.message, res.data.status)

  $scope.$on '$viewContentLoaded', ->
    $scope.getUserAuthKey()

#init angular app
giddh.webApp.controller 'userController', userController