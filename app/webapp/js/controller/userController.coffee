"use strict"

userController = ($scope, $rootScope, localStorageService, toastr, userServices) ->
  $scope.userAuthKey = undefined

  $scope.getUserAuthKey = () ->
    userServices.getKey($rootScope.basicInfo.userUniqueName).then($scope.getUserAuthKeySuccess, $scope.getUserAuthKeyFailure)

  $scope.getUserAuthKeySuccess = (result) ->
    console.log "getUserAuthKeySuccess", result
    $scope.userAuthKey = result.body


  $scope.getUserAuthKeyFailure = (result) ->
    console.log result, "getUserAuthKeyFailure"
    # toastr.error(result.body.message, "Error")

  $rootScope.$on '$viewContentLoaded', ->
    $scope.getUserAuthKey()

#init angular app
angular.module('giddhWebApp').controller 'userController', userController