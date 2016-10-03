'use strict'

loginController = ($scope, $rootScope, $http, $timeout, $auth, localStorageService, toastr, $window) ->
  $scope.loginIsProcessing = false
  $scope.captchaKey = '6LcgBiATAAAAAMhNd_HyerpTvCHXtHG6BG-rtcmi'

  $rootScope.homePage = false
  # check string has whitespace
  $scope.hasWhiteSpace = (s) ->
    return /\s/g.test(s)

  $scope.validateEmail = (emailStr)->
    pattern = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
    return pattern.test(emailStr)

  $scope.submitForm =(data)->

    $scope.formProcess = true
    #check and split full name in first and last name
    if($scope.hasWhiteSpace(data.name))
      unameArr = data.name.split(" ")
      data.uFname = unameArr[0]
      data.uLname = unameArr[1]
    else
      data.uFname = data.name
      data.uLname = "  "

    if not($scope.validateEmail(data.email))
      toastr.warning("Enter valid Email ID", "Warning")
      return false

    data.company = ''

    if _.isEmpty(data.message)
      data.message = 'test'

    $http.post('/contact/submitDetails', data).then((response) ->
      $scope.formSubmitted = true
      if(response.status == 200 && _.isUndefined(response.data.status))
        $scope.responseMsg = "Thanks! we will get in touch with you soon"
      else
        $scope.responseMsg = response.data.message
    )

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
        $window.sessionStorage.setItem("_ak", response.data.result.body.authKey)
        window.location = "/app/#/home/"
    ).catch (response) ->
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