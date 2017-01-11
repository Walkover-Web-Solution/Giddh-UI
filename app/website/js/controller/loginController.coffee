'use strict'

loginController = ($scope, $rootScope, $http, $timeout, $auth, localStorageService, toastr, $window, $uibModal, $location) ->
  $scope.showLoginBox = false
  $scope.toggleLoginBox = (e) ->
    $scope.showLoginBox = !$scope.showLoginBox
    e.stopPropagation()
  $scope.loginIsProcessing = false
  $scope.captchaKey = '6LcgBiATAAAAAMhNd_HyerpTvCHXtHG6BG-rtcmi'
  $scope.phoneLoginPopup = false
  $scope.showOtp = false
  $scope.contact = {}
  $scope.countryCode = 91
  $rootScope.homePage = false
  $scope.loginBtnTxt = "Get OTP"
  $scope.loggingIn = false
  $scope.twoWayVfyCode = null
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

  $scope.TwoWayLogin = (code) ->
    @success = (res) ->
      console.log res
      localStorageService.set("_userDetails", res.data.body.user)
      $window.sessionStorage.setItem("_ak", res.data.body.authKey)
      window.location = "/app/#/home/"

    @failure = (res) ->
      toastr.error(res.data.message, "Error")
      $timeout (->
        window.location = "/index"
      ),3000

    $scope.twoWayUserData.oneTimePassword = code
    url = '/verify-number'
    $http.post(url,  $scope.twoWayUserData).then(@success, @failure)

  loginWithTwoWayAuthentication = (res) ->
    $scope.twoWayUserData = {}
    $scope.twoWayUserData.countryCode = res.countryCode
    $scope.twoWayUserData.mobileNumber = res.contactNumber
    modalInstance = $uibModal.open(
      templateUrl: '/public/website/views/twoWayAuthSignIn.html',
      size: "md",
      backdrop: 'static',
      scope: $scope
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
        if response.data.result.body.authKey
          localStorageService.set("_userDetails", response.data.userDetails)
          $window.sessionStorage.setItem("_ak", response.data.result.body.authKey)
          window.location = "/app/#/home/"
        else
          loginWithTwoWayAuthentication(response.data.result.body)
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

  $scope.loginWithMobile = (e) ->
    $scope.phoneLoginPopup = true
    e.stopPropagation()
    
  $scope.signUpWithEmailModal = (e) ->
    modalInstance = $uibModal.open(
      templateUrl: '/public/website/views/signUpEmail.html',
      size: "md",
      backdrop: 'static',
      scope: $scope
    )
    e.stopPropagation()

  $scope.verifyMail = false
  $scope.emailToVerify = ""
  $scope.verifyMailMakeFalse = () ->
    $scope.verifyMail = false

  getOtpSuccess = (res) ->
    $scope.showOtp = true

  getOtpFailure = (res) ->
    toastr.error(res.data.response.code)

  $scope.getOtp = () ->
    $scope.contact.countryCode = $scope.countryCode
    if $scope.contact.mobileNumber != undefined
      $http.post('/get-login-otp', $scope.contact).then(
        getOtpSuccess,
        getOtpFailure
      )
    else
      toastr.error("mobile number cannot be blank")
    $scope.loginBtnTxt = "Resend"
    

  loginUserSuccess = (res) ->
    localStorageService.set("_userDetails", res.data.body.user)
    $window.sessionStorage.setItem("_ak", res.data.body.authKey)
    window.location = "/app/#/home/"

  loginUserFailure = (res) ->
    toastr.error(res.data.message)
    $scope.loggingIn = false

  loginUser = (token) ->
    data = {
      countryCode : $scope.contact.countryCode
      mobileNumber : $scope.contact.mobileNumber
      token : token
    }
    $http.post('/login-with-number', data).then(
      loginUserSuccess,
      loginUserFailure
    )

  verifyOtpSuccess = (res) ->
    refreshToken = res.data.response.refreshToken
    loginUser(refreshToken)

  verifyOtpFailure = (res) ->
    toastr.error(res.data.response.code)
    $scope.loggingIn = false

  $scope.verifyOtp = (otp) ->
    contact = $scope.contact
    contact.oneTimePassword = otp
    $http.post('/verify-login-otp', contact).then(
      verifyOtpSuccess,
      verifyOtpFailure
    )
    $scope.loggingIn = true

  $scope.signUpWithEmail = (emailId, resend) ->
    dataToSend = {
      email: emailId
    }
    $http.post('/signup-with-email', dataToSend).then(
      (res) ->
        $scope.verifyMail = true
        $scope.emailToVerify = emailId
        if resend
          toastr.success(res.data.body)
      (res) ->
        $scope.verifyMail = false
        toastr.error(res.data.message)
    )

  $scope.verifyEmail = (emailId, code) ->
    dataToSend = {
      email: $scope.emailToVerify
      verificationCode: code
    }
    $http.post('/verify-email-now', dataToSend).then(
      verifyEmailSuccess,
      verifyEmailFailure
    )

  verifyEmailSuccess = (res) ->
    $scope.verifyEmail = false
    localStorageService.set("_userDetails", res.data.body.user)
    $window.sessionStorage.setItem("_ak", res.data.body.authKey)
    window.location = '/app/#/home'

  verifyEmailFailure = (res) ->
    toastr.error(res.data.message)
    $scope.verifyMail = true

angular.module('giddhApp').controller 'loginController', loginController