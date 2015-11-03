"use strict"

userController = ($scope, $rootScope, toastr, userServices) ->
  $scope.userAuthKey = undefined

  $scope.getUserAuthKey = () ->
    if not _.isUndefined($rootScope.basicInfo)
      userServices.getKey($rootScope.basicInfo.userUniqueName).then($scope.getUserAuthKeySuccess,
          $scope.getUserAuthKeyFailure)

  $scope.getUserAuthKeySuccess = (result) ->
    $scope.userAuthKey = result.body


  $scope.getUserAuthKeyFailure = (result) ->
    toastr.error(result.body.message, "Error")

  $scope.regenerateKey = () ->
    console.log "we are here to regenerate"
    userServices.generateKey($rootScope.basicInfo.userUniqueName).then($scope.generateKeySuccess,
        $scope.generateKeyFailure)

  $scope.generateKeySuccess = (result) ->
    console.log "generate key success", result
    $scope.userAuthKey = result.body.authKey

  $scope.generateKeyFailure = (result) ->
    toastr.error(result.body.message, "Error")

  $rootScope.$on '$viewContentLoaded', ->
    $scope.getUserAuthKey()

#init angular app
angular.module('giddhWebApp').controller 'userController', userController