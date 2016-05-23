'use strict'

loginController = ($scope, $rootScope, $http, $timeout, $auth, localStorageService, toastr) ->
  $scope.loginIsProcessing = false

  $rootScope.homePage = false

  $scope.authenticate = (provider) ->
    $scope.loginIsProcessing = true
    $auth.authenticate(provider).then((response) ->
      if response.data.result.status is "error"
        #user is not registerd with us
        toastr.error(response.data.result.message, "Error")
        $timeout (->
          window.location = "/index"
        ),3000
      else
        #user is registered and redirect it to app
        localStorageService.set("_userDetails", response.data.userDetails)
        window.location = "/app/#/home/"
    ).catch (response) ->
      console.log response
      $scope.loginIsProcessing = false
      #user is not registerd with us
      if response.data.result.status is "error"
        toastr.error(response.data.result.message, "Error")
        $timeout (->
          window.location = "/index"
        ), 3000
      else if response.status is 502
        toastr.error("Something went wrong please reload page", "Error")
      else
        toastr.error("Something went wrong please reload page", "Error")


angular.module('giddhApp').controller 'loginController', loginController