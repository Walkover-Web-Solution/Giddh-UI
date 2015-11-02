"use strict"

userController = ($scope, $rootScope, localStorageService, toastr, userServices) ->
  $scope.userAuthKey = undefined

  $scope.getUserAuthKey = ->
    userServices.getAuthKey($rootScope.basicInfo.userUniqueName).then($scope.getUserAuthKeySuccess,
        $scope.getUserAuthKeyFailure)

  $scope.getUserAuthKeySuccess = (result) ->
    $scope.userAuthKey = result.body.authKey


  $scope.getUserAuthKeyFailure = (result) ->
    toastr.error(result.body.message, "Error")

  $rootScope.$on '$viewContentLoaded', ->
    $scope.getUserAuthKey()

#init angular app
angular.module('giddhWebApp').controller 'userController', userController